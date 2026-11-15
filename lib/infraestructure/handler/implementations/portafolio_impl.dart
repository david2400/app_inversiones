import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/config/registro.dart';
import 'package:inversiones/domain/entity/portafolio_entity.dart';
import 'package:inversiones/domain/entity/tipo_transaccion_entity.dart';
import 'package:inversiones/domain/models/periodicidad.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/recurrente_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/page/gestion/portafolio/dto/aporte_programado_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/domain/mappers/portafolio_mapper.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/domain/schema/meta_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/domain/mappers/saldo_portafolio_mapper.dart';
import 'package:inversiones/page/gestion/portafolio/dto/saldo_portafolio_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/vencimiento_dto.dart';
import 'package:inversiones/domain/models/calculadora_rendimiento.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';

class PortafolioHandler implements IPortafolio {
  static const descripcionSaldoInicial = 'Saldo inicial';

  @override
  Future<int> createPortafolio(PortafolioDto portafolioDto,
          {int saldoInicial = 0, AporteProgramadoDto? aporteProgramado}) =>
      // Portafolio, saldo inicial y aporte programado se crean juntos o no
      // se crea nada.
      DatabaseHelper().enTransaccion(() async {
        final id = await _crearPortafolio(portafolioDto, saldoInicial);
        if (aporteProgramado != null) {
          await RecurrenteHandler()
              .guardarAporteProgramado(id, aporteProgramado);
        }
        return id;
      });

  /// El vencimiento no puede ser anterior a la apertura.
  static void _validarPlazo(String? apertura, String? vencimiento) {
    final desde = DateTime.tryParse(apertura ?? '');
    final hasta = DateTime.tryParse(vencimiento ?? '');
    if (desde != null && hasta != null && hasta.isBefore(desde)) {
      throw Exception('La fecha de vencimiento es anterior a la de apertura');
    }
  }

  Future<int> _crearPortafolio(
      PortafolioDto portafolioDto, int saldoInicial) async {
    if (saldoInicial < 0) {
      throw Exception('El saldo inicial no puede ser negativo');
    }
    _validarPlazo(portafolioDto.fechaApertura, portafolioDto.fechaVencimiento);
    if ((portafolioDto.proyectoId == null) == (portafolioDto.cuentaId == null)) {
      throw Exception(
          'El portafolio debe pertenecer a una cuenta o a un proyecto');
    }
    if (portafolioDto.cuentaId != null) {
      // El 4x1000 lo define la cuenta: sus portafolios heredan la exención.
      final cuenta = await CuentaSchema().getById(portafolioDto.cuentaId!);
      if (cuenta == null) throw Exception('La cuenta no existe');
      portafolioDto.exentaImpuesto = CuentaSchema.exencionEfectiva(cuenta);
    } else {
      portafolioDto.esPrincipal = false;
    }
    // Se valida antes de crear el portafolio para no dejarlo a medias.
    TipoTransaccion? tipoIngreso;
    if (saldoInicial > 0) {
      tipoIngreso = await TipoTransaccionSchema()
          .getPrimeroPorFuente(TipoFuente.ingreso);
      if (tipoIngreso == null) {
        throw Exception(
            'Crea primero un tipo de transacción de ingreso para registrar el saldo inicial');
      }
    }

    final mappr = PortafolioMapprImpl();
    PortafolioSchema portafolioSchema = PortafolioSchema();

    Portafolio portafolio = mappr.fromModel(portafolioDto);
    int resultInsert = await portafolioSchema.insert(portafolio);

    if (resultInsert == 0) {
      throw Exception('No se pudo realizar el registro');
    }
    if (tipoIngreso != null) {
      await TransaccionHandler().createTransaccion(TransaccionDto(
        valor: saldoInicial,
        tipoTransferenciaId: tipoIngreso.idTipoTransaccion!,
        portafolioId: resultInsert,
        descripcion: descripcionSaldoInicial,
        createdAt: portafolioDto.createdAt,
      ));
    }
    return resultInsert;
  }

  @override
  Future<int> actualizarPortafolio(PortafolioDto portafolioDto,
          {AporteProgramadoDto? aporteProgramado, bool quitarAporte = false}) =>
      DatabaseHelper().enTransaccion(() async {
        final id = portafolioDto.idPortafolio;
        if (id == null) throw Exception('Falta el portafolio a editar');
        final schema = PortafolioSchema();
        final actual = await schema.getById(id);
        if (actual == null) throw Exception('El portafolio no existe');
        if (actual.esPrincipal) {
          throw Exception(
              'El portafolio principal se edita desde la cuenta');
        }
        final nombre = portafolioDto.nombre.trim();
        if (nombre.isEmpty) throw Exception('El nombre es obligatorio');
        _validarPlazo(
            portafolioDto.fechaApertura, portafolioDto.fechaVencimiento);

        String? exenta = portafolioDto.exentaImpuesto;
        if (actual.cuentaId != null) {
          final cuenta = await CuentaSchema().getById(actual.cuentaId!);
          if (cuenta == null) throw Exception('La cuenta no existe');
          exenta = CuentaSchema.exencionEfectiva(cuenta);
        }
        final rendimientos =
            portafolioDto.cuentaDestinoId == portafolioDto.cuentaAportesId
                ? null
                : portafolioDto.cuentaDestinoId;

        final resultado = await schema.actualizarDatos(Portafolio(
          idPortafolio: id,
          nombre: nombre,
          nroCuenta: portafolioDto.nroCuenta,
          tipoRenta: _textoONulo(portafolioDto.tipoRenta),
          tipoPortafolioId: _idONulo(portafolioDto.tipoPortafolioId),
          interes: portafolioDto.interes,
          exentaImpuesto: exenta,
          periodicidadRendimientos:
              Periodicidad.esDeRendimientos(portafolioDto.periodicidadRendimientos)
                  ? portafolioDto.periodicidadRendimientos
                  : null,
          descripcion: portafolioDto.descripcion,
          cuentaAportesId: portafolioDto.cuentaAportesId,
          cuentaDestinoId: rendimientos,
          fechaApertura: _textoONulo(portafolioDto.fechaApertura),
          fechaVencimiento: _textoONulo(portafolioDto.fechaVencimiento),
        ));
        if (resultado != 1) throw Exception('No se pudo actualizar');
        final recurrentes = RecurrenteHandler();
        if (aporteProgramado != null) {
          await recurrentes.guardarAporteProgramado(id, aporteProgramado);
        } else if (quitarAporte) {
          await recurrentes.guardarAporteProgramado(id, null);
        } else {
          await recurrentes.sincronizarAporteProgramado(id);
        }
        return resultado;
      });

  /// Los formularios usan 0 / '' como "sin selección".
  static int? _idONulo(int? id) => (id ?? 0) > 0 ? id : null;
  static String? _textoONulo(String? texto) {
    final limpio = texto?.trim() ?? '';
    return limpio.isEmpty ? null : limpio;
  }

  @override
  Future<int> deletePortafolio(int id) =>
      DatabaseHelper().enTransaccion(() => _eliminarPortafolio(id));

  Future<int> _eliminarPortafolio(int id) async {
    PortafolioSchema portafolioSchema = PortafolioSchema();
    TransferenciaShema transferenciaShema = TransferenciaShema();

    final usos = await transferenciaShema.contarActivosPor(
            TransferenciaShema.portafolioId, id) +
        await transferenciaShema.contarActivosPor(
            TransferenciaShema.destino, id);
    if (usos > 0) {
      throw Exception(
          'No se puede eliminar: el portafolio tiene $usos movimientos asociados');
    }

    // El aporte programado no tiene sentido sin su portafolio.
    await RecurrenteHandler().guardarAporteProgramado(id, null);
    // Ni su vínculo con una meta de ahorro.
    await MetaPortafolioSchema().quitarPortafolio(id);

    var result = await portafolioSchema.deleteById(id);
    if (result != 1) {
      throw Exception('No se encontro el registro');
    }

    return result;
  }

  @override
  Future<List<PortafolioDto>> listarPortafolioByProyecto(int idProyecto) async {
    try {
      final mappr = PortafolioMapprImpl();

      PortafolioSchema portafolioSchema = PortafolioSchema();
      List<Portafolio> listPortafolio =
          await portafolioSchema.getByIdProyecto(idProyecto);

      // List<PortafolioDto> listPortafolioDto = mappr.convertList<Portafolio,PortafolioDto>(listPortafolio);
      List<PortafolioDto> listPortafolioDto = listPortafolio.map((portafolio) {
        return mappr.fromDto(portafolio);
      }).toList();

      return listPortafolioDto;
    } catch (e, pila) {
      Registro.error('PortafolioHandler: error en consulta', e, pila);
      rethrow;
    }
  }

  @override
  Future<PortafolioDto> obtenerPortafolioById(int idProyecto) async {
    try {
      final mappr = PortafolioMapprImpl();

      PortafolioSchema portafolioSchema = PortafolioSchema();
      Portafolio? portafolio = await portafolioSchema.getById(idProyecto);
      if (portafolio == null) {
        throw Exception('El portafolio $idProyecto no existe');
      }
      PortafolioDto listPortafolioDto = mappr.fromDto(portafolio);

      // List<PortafolioDto> listPortafolioDto = mappr.convertList<Portafolio,PortafolioDto>(listPortafolio);

      return listPortafolioDto;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PortafolioDto>> listarPortafolios() async {
    try {
      final mappr = PortafolioMapprImpl();
      PortafolioSchema portafolioSchema = PortafolioSchema();

      List<Portafolio> listTransacciones = await portafolioSchema.getAll();

      List<PortafolioDto> listPortafolio = listTransacciones.map((transaccion) {
        return mappr.fromDto(transaccion);
      }).toList();

      return listPortafolio;
    } catch (e, pila) {
      Registro.error('PortafolioHandler: error en consulta', e, pila);
      rethrow;
    }
  }

  @override
  Future<List<PortafolioDto>> listarPortafoliosDeCuenta(int idCuenta) async {
    final mappr = PortafolioMapprImpl();
    final portafolios = await PortafolioSchema().getByCuenta(idCuenta);
    return portafolios.map(mappr.fromDto).toList();
  }

  @override
  Future<int> obtenerSaldo(int idPortafolio) async {
    TransferenciaShema transferenciaShema = TransferenciaShema();
    final saldos =
        await transferenciaShema.obtenerSaldos(idPortafolio: idPortafolio);
    if (saldos.isEmpty) {
      throw Exception('El portafolio $idPortafolio no existe');
    }
    return saldos.first.saldo;
  }

  @override
  Future<List<VencimientoDto>> listarVencimientos(
      {DateTime? hoy, int dias = 30}) async {
    final fecha = hoy ?? DateTime.now();
    final saldos = {
      for (final s in await listarSaldos()) s.idPortafolio: s.saldo,
    };
    final lista = <VencimientoDto>[];
    for (final p in await PortafolioSchema().getAll()) {
      final vence = DateTime.tryParse(p.fechaVencimiento ?? '');
      final saldo = saldos[p.idPortafolio] ?? 0;
      if (vence == null || saldo <= 0) continue;
      final restantes = CalculadoraRendimiento.diasEntre(fecha, vence);
      if (restantes > dias) continue;
      lista.add(VencimientoDto(
        idPortafolio: p.idPortafolio!,
        nombre: p.nombre,
        proyectoId: p.proyectoId,
        fechaVencimiento: vence,
        diasRestantes: restantes,
        saldo: saldo,
        rendimientoEstimado: CalculadoraRendimiento.rendimiento(
            capital: saldo, tasaEa: p.interes ?? 0, dias: restantes),
      ));
    }
    lista.sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
    return lista;
  }

  @override
  Future<List<SaldoPortafolioDto>> listarSaldos() async {
    final mappr = SaldoPortafolioMapprImpl();
    TransferenciaShema transferenciaShema = TransferenciaShema();
    final saldos = await transferenciaShema.obtenerSaldos();
    return saldos.map(mappr.fromDto).toList();
  }
}
