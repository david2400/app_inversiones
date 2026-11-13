import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/config/registro.dart';
import 'package:inversiones/domain/entity/cuenta_entity.dart';
import 'package:inversiones/domain/mappers/cuenta_mapper.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/schema/condiciones_credito_schema.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/domain/schema/recurrente_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';

class CuentaHandler implements ICuenta {
  static const longitudMaximaNombre = 80;
  static const _valoresExencion = ['S', 'N'];

  final CuentaSchema _cuentaSchema;
  final PortafolioSchema _portafolioSchema;
  final TransferenciaShema _transferenciaShema;
  final IPortafolio _portafolioHandler;

  CuentaHandler({
    CuentaSchema? cuentaSchema,
    PortafolioSchema? portafolioSchema,
    TransferenciaShema? transferenciaShema,
    IPortafolio? portafolioHandler,
  })  : _cuentaSchema = cuentaSchema ?? CuentaSchema(),
        _portafolioSchema = portafolioSchema ?? PortafolioSchema(),
        _transferenciaShema = transferenciaShema ?? TransferenciaShema(),
        _portafolioHandler = portafolioHandler ?? PortafolioHandler();

  @override
  Future<List<CuentaDto>> listarCuentas() async {
    try {
      final mappr = CuentaMapprImpl();
      final cuentas = await _cuentaSchema.getAll();
      final saldos = await _portafolioHandler.listarSaldos();
      final resultado = <CuentaDto>[];
      for (final cuenta in cuentas) {
        resultado.add(await _completar(mappr.fromDto(cuenta), saldos: [
          for (final s in saldos)
            if (s.cuentaId == cuenta.idCuenta) s.saldo
        ]));
      }
      return resultado;
    } catch (e, pila) {
      Registro.error('CuentaHandler: error en consulta', e, pila);
      rethrow;
    }
  }

  @override
  Future<CuentaDto> obtenerCuenta(int idCuenta) async {
    final cuenta = await _cuentaSchema.getById(idCuenta);
    if (cuenta == null) throw Exception('La cuenta no existe');
    final saldos = await _portafolioHandler.listarSaldos();
    return _completar(CuentaMapprImpl().fromDto(cuenta), saldos: [
      for (final s in saldos)
        if (s.cuentaId == idCuenta) s.saldo
    ]);
  }

  /// Agrega saldo, portafolio principal y cantidad de portafolios.
  Future<CuentaDto> _completar(CuentaDto dto,
      {required List<int> saldos}) async {
    final portafolios = await _portafolioSchema.getByCuenta(dto.idCuenta!);
    dto.saldo = saldos.fold(0, (total, s) => total + s);
    dto.cantidadPortafolios = portafolios.length;
    for (final p in portafolios) {
      if (p.esPrincipal) dto.idPortafolioPrincipal = p.idPortafolio;
    }
    return dto;
  }

  @override
  Future<int> guardarCuenta(CuentaDto dto, {int saldoInicial = 0}) =>
      DatabaseHelper().enTransaccion(() => _guardar(dto, saldoInicial));

  Future<int> _guardar(CuentaDto dto, int saldoInicial) async {
    final nombre = dto.nombre.trim();
    if (nombre.isEmpty) throw Exception('El nombre de la cuenta es obligatorio');
    if (nombre.length > longitudMaximaNombre) {
      throw Exception(
          'El nombre no puede superar $longitudMaximaNombre caracteres');
    }
    if (dto.idCuenta == CuentaSchema.idEfectivo) {
      // La cuenta de efectivo siempre es de tipo efectivo.
      dto.tipoCuenta = TipoCuenta.efectivo;
    }
    if (!TipoCuenta.esValido(dto.tipoCuenta)) {
      throw Exception('El tipo de cuenta no es válido');
    }
    if (!_valoresExencion.contains(dto.exentaImpuesto)) {
      throw Exception('Indica si la cuenta está exenta del 4x1000');
    }
    dto
      ..nombre = nombre
      ..entidad = _textoOpcional(dto.entidad)
      ..nroCuenta = _textoOpcional(dto.nroCuenta)
      ..descripcion = _textoOpcional(dto.descripcion);

    final cuenta = CuentaMapprImpl().fromModel(dto);
    final exencion = CuentaSchema.exencionEfectiva(cuenta);

    if (dto.idCuenta == null) {
      final idCuenta = await _cuentaSchema.insert(cuenta);
      await _portafolioHandler.createPortafolio(
        PortafolioDto(
          nombre: nombre,
          cuentaId: idCuenta,
          esPrincipal: true,
          interes: 0,
          exentaImpuesto: exencion,
        ),
        saldoInicial: saldoInicial,
      );
      return idCuenta;
    }

    if (saldoInicial != 0) {
      throw Exception(
          'El saldo inicial solo se indica al crear la cuenta; usa "Ajustar saldo"');
    }
    final actualizados = await _cuentaSchema.update(cuenta);
    if (actualizados == 0) throw Exception('La cuenta no existe');
    await _portafolioSchema.renombrarPrincipal(dto.idCuenta!, nombre);
    await _portafolioSchema.sincronizarExencionDeCuenta(
        dto.idCuenta!, exencion);
    return dto.idCuenta!;
  }

  @override
  Future<void> eliminarCuenta(int idCuenta) =>
      DatabaseHelper().enTransaccion(() async {
        if (idCuenta == CuentaSchema.idEfectivo) {
          throw Exception(
              'La cuenta "Efectivo / Sin definir" no se puede eliminar');
        }
        final portafolios = await _portafolioSchema.getByCuenta(idCuenta);
        final otros = portafolios.where((p) => !p.esPrincipal).length;
        if (otros > 0) {
          throw Exception(
              'Primero elimina o mueve sus $otros portafolios (cajitas, bolsillos, CDTs)');
        }
        for (final p in portafolios) {
          final movimientos = await _transferenciaShema.contarActivosPor(
                  TransferenciaShema.portafolioId, p.idPortafolio!) +
              await _transferenciaShema.contarActivosPor(
                  TransferenciaShema.destino, p.idPortafolio!);
          if (movimientos > 0) {
            throw Exception(
                'No se puede eliminar: la cuenta tiene $movimientos movimientos');
          }
        }
        await _portafolioSchema.quitarReferenciasACuenta(idCuenta);
        // Deudas: se eliminan sus condiciones y la cuota de manejo.
        final condiciones = await CondicionesCreditoSchema().getById(idCuenta);
        if (condiciones != null) {
          if (condiciones.recurrenteManejoId != null) {
            await RecurrenteSchema().deleteById(condiciones.recurrenteManejoId!);
          }
          await CondicionesCreditoSchema().deleteById(idCuenta);
        }
        for (final p in portafolios) {
          await _portafolioSchema.deleteById(p.idPortafolio!);
        }
        final result = await _cuentaSchema.deleteById(idCuenta);
        if (result != 1) throw Exception('La cuenta no existe');
      });

  @override
  Future<int> convertirPortafolioEnCuenta(int idPortafolio,
          {required String tipoCuenta, String? entidad}) =>
      DatabaseHelper().enTransaccion(() async {
        if (!TipoCuenta.esValido(tipoCuenta)) {
          throw Exception('El tipo de cuenta no es válido');
        }
        final portafolio = await _portafolioSchema.getById(idPortafolio);
        if (portafolio == null) throw Exception('El portafolio no existe');
        if (portafolio.cuentaId != null) {
          throw Exception('Este portafolio ya pertenece a una cuenta');
        }
        final cuenta = Cuenta(
          nombre: portafolio.nombre,
          tipoCuenta: tipoCuenta,
          entidad: _textoOpcional(entidad),
          nroCuenta: portafolio.nroCuenta,
          exentaImpuesto: portafolio.exentaImpuesto == 'S' ? 'S' : 'N',
          descripcion: portafolio.descripcion,
        );
        final idCuenta = await _cuentaSchema.insert(cuenta);
        await _portafolioSchema.asignarComoPrincipal(idPortafolio, idCuenta);
        await _portafolioSchema.sincronizarExencionDeCuenta(
            idCuenta, CuentaSchema.exencionEfectiva(cuenta));
        return idCuenta;
      });

  static String? _textoOpcional(String? texto) {
    final limpio = texto?.trim();
    return (limpio == null || limpio.isEmpty) ? null : limpio;
  }
}
