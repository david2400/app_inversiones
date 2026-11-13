import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/mappers/total_mensual_mapper.dart';
import 'package:inversiones/domain/models/filtro_movimientos.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/resultado_movimientos_dto.dart';
import 'package:inversiones/config/registro.dart';
import 'package:inversiones/domain/mappers/transaccion_mapper.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/schema/condiciones_credito_schema.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/domain/entity/tipo_transaccion_entity.dart';
import 'package:inversiones/domain/models/calculadora_gmf.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/domain/consultas/transaccion_balance_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/domain/consultas/transaccion_portafolio_dto.dart';
import 'package:inversiones/domain/consultas/transacciones_details_dto.dart';
import 'package:inversiones/domain/entity/transferencia_entity.dart';

class TransaccionHandler implements ITransaccion {
  /// Si es `true`, no se permite que un egreso o transferencia deje el
  /// portafolio origen con saldo negativo.
  static const validarSaldoSuficiente = true;

  @override
  Future<int> createTransaccion(TransaccionDto transaccionDto) =>
      // Validación de saldo e inserción en una sola transacción.
      DatabaseHelper().enTransaccion(() => _crearTransaccion(transaccionDto));

  Future<int> _crearTransaccion(TransaccionDto transaccionDto) async {
    try {
      if (transaccionDto.valor <= 0) {
        throw Exception('El valor debe ser mayor a cero');
      }

      TipoTransaccion? tipo = await TipoTransaccionSchema()
          .getById(transaccionDto.tipoTransferenciaId);
      if (tipo == null || !TipoFuente.esValido(tipo.tipoFuente)) {
        throw Exception('El tipo de transacción no es válido');
      }

      IPortafolio portafolioHandler = PortafolioHandler();
      PortafolioDto origen = await portafolioHandler
          .obtenerPortafolioById(transaccionDto.portafolioId);

      // Los formularios usan 0 como "sin selección".
      if ((transaccionDto.destinoCuenta ?? 0) <= 0) {
        transaccionDto.destinoCuenta = null;
      }
      if ((transaccionDto.motivoId ?? 0) <= 0) {
        transaccionDto.motivoId = null;
      }
      if ((transaccionDto.terceroId ?? 0) <= 0) {
        transaccionDto.terceroId = null;
      }
      if ((transaccionDto.recurrenteId ?? 0) <= 0) {
        transaccionDto.recurrenteId = null;
      }

      if (tipo.tipoFuente == TipoFuente.transferencia) {
        await _validarDestino(transaccionDto, portafolioHandler);
        // Entre cuentas propias no hay tercero; solo hacia cuentas externas.
        if (transaccionDto.destinoCuenta != null) {
          transaccionDto.terceroId = null;
        } else {
          transaccionDto.destinoAlternativo =
              transaccionDto.destinoAlternativo?.trim();
        }
      } else {
        // Solo las transferencias tienen portafolio destino.
        transaccionDto.destinoCuenta = null;
      }

      int impuesto = calcularGmf(
          valor: transaccionDto.valor,
          tipoFuente: tipo.tipoFuente,
          exentaImpuesto: origen.exentaImpuesto);

      if (validarSaldoSuficiente &&
          TipoFuente.debitaOrigen(tipo.tipoFuente)) {
        int saldo =
            await portafolioHandler.obtenerSaldo(transaccionDto.portafolioId);
        int requerido = transaccionDto.valor + impuesto;
        final limite = await _deudaPermitida(origen);
        if (limite != null && saldo - requerido < -limite) {
          if (limite == 0) {
            throw Exception(
                'Saldo insuficiente: disponible $saldo, requerido $requerido (incluye GMF $impuesto)');
          }
          throw Exception(
              'Supera el cupo de la tarjeta: disponible ${limite + saldo}, requerido $requerido');
        }
      }

      transaccionDto.impuesto = impuesto;

      final mappr = TransaccionMapprImpl();
      TransferenciaShema transferenciaShema = TransferenciaShema();
      Transaccion transaccion = mappr.fromModel(transaccionDto);
      int resultInsert = await transferenciaShema.insert(transaccion);

      if (resultInsert == 0) {
        throw Exception('No se pudo realizar el registro');
      }

      return resultInsert;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> registrarAporte(int idPortafolio, int valor,
          {String? descripcion, String? fecha, int? motivoId}) =>
      DatabaseHelper().enTransaccion(() async {
        final destino =
            await PortafolioHandler().obtenerPortafolioById(idPortafolio);
        if (destino.esPrincipal) {
          throw Exception(
              'Los aportes se hacen a un portafolio de inversión, no a la cuenta');
        }
        final origen = await _principalDeCuenta(
            destino.cuentaAportesId ?? CuentaSchema.idEfectivo);
        if (origen == idPortafolio) {
          throw Exception('El portafolio no puede aportarse a sí mismo');
        }
        final tipo = await _tipoPorFuente(TipoFuente.transferencia);
        return _crearTransaccion(TransaccionDto(
          valor: valor,
          tipoTransferenciaId: tipo,
          portafolioId: origen,
          destinoCuenta: idPortafolio,
          motivoId: motivoId,
          descripcion: _texto(descripcion) ?? 'Aporte a ${destino.nombre}',
          createdAt: fecha,
        ));
      });

  @override
  Future<int> registrarRendimiento(int idPortafolio, int valor,
          {String? descripcion,
          String? fecha,
          int? motivoId,
          bool reinvertir = false}) =>
      DatabaseHelper().enTransaccion(() async {
        final portafolio =
            await PortafolioHandler().obtenerPortafolioById(idPortafolio);
        final texto =
            _texto(descripcion) ?? 'Rendimiento de ${portafolio.nombre}';
        final idIngreso = await _crearTransaccion(TransaccionDto(
          valor: valor,
          tipoTransferenciaId: await _tipoPorFuente(TipoFuente.ingreso),
          portafolioId: idPortafolio,
          motivoId: motivoId,
          descripcion: texto,
          createdAt: fecha,
        ));
        if (reinvertir || portafolio.esPrincipal) return idIngreso;

        final idCuentaDestino = portafolio.cuentaDestinoId ??
            portafolio.cuentaAportesId ??
            portafolio.cuentaId ??
            CuentaSchema.idEfectivo;
        final destino = await _principalDeCuenta(idCuentaDestino);
        if (destino != idPortafolio) {
          await _crearTransaccion(TransaccionDto(
            valor: valor,
            tipoTransferenciaId: await _tipoPorFuente(TipoFuente.transferencia),
            portafolioId: idPortafolio,
            destinoCuenta: destino,
            motivoId: motivoId,
            descripcion: texto,
            createdAt: fecha,
          ));
        }
        return idIngreso;
      });

  Future<int> _principalDeCuenta(int idCuenta) async {
    final principal = await PortafolioSchema().getPrincipalDeCuenta(idCuenta);
    if (principal == null) {
      throw Exception('La cuenta no tiene portafolio principal');
    }
    return principal.idPortafolio!;
  }

  Future<int> _tipoPorFuente(String fuente) async {
    final tipo = await TipoTransaccionSchema().getPrimeroPorFuente(fuente);
    if (tipo == null) {
      throw Exception('Falta un tipo de transacción de '
          '${fuente == TipoFuente.ingreso ? 'ingreso' : 'transferencia'}');
    }
    return tipo.idTipoTransaccion!;
  }

  static String? _texto(String? valor) {
    final limpio = valor?.trim();
    return (limpio == null || limpio.isEmpty) ? null : limpio;
  }

  /// Cuánto puede quedar en negativo el portafolio [origen]: 0 en cuentas
  /// normales, el cupo en tarjetas de crédito y sin límite (`null`) en
  /// préstamos, donde el desembolso crea la deuda.
  Future<int?> _deudaPermitida(PortafolioDto origen) async {
    if (origen.cuentaId == null) return 0;
    final cuenta = await CuentaSchema().getById(origen.cuentaId!);
    if (cuenta == null || !TipoCuenta.esPasivo(cuenta.tipoCuenta)) return 0;
    if (cuenta.tipoCuenta == TipoCuenta.prestamo) return null;
    final condiciones =
        await CondicionesCreditoSchema().getById(origen.cuentaId!);
    return condiciones?.cupo ?? 0;
  }

  Future<void> _validarDestino(
      TransaccionDto transaccionDto, IPortafolio portafolioHandler) async {
    final destino = transaccionDto.destinoCuenta;
    final destinoExterno = transaccionDto.destinoAlternativo?.trim() ?? '';

    if (destino == null && destinoExterno.isEmpty) {
      throw Exception('Una transferencia requiere un portafolio o cuenta destino');
    }
    if (destino != null) {
      if (destino == transaccionDto.portafolioId) {
        throw Exception('El portafolio origen y destino no pueden ser el mismo');
      }
      // Lanza excepción si el destino no existe o fue eliminado.
      await portafolioHandler.obtenerPortafolioById(destino);
    }
  }

  @override
  Future<int> updateTransaccion(TransaccionDto transaccionDto) async {
    final mappr = TransaccionMapprImpl();
    TransferenciaShema transferenciaShema = TransferenciaShema();

    Transaccion transaccion = mappr.fromModel(transaccionDto);
    int resultInsert = await transferenciaShema.update(transaccion);

    if (resultInsert == 0) {
      throw Exception('No se pudo realizar el registro');
    }

    return resultInsert;
  }

  @override
  Future<int> deleteTransaccion(int id) async {
    TransferenciaShema transferenciaShema = TransferenciaShema();

    var result = await transferenciaShema.deleteById(id);
    if (result != 1) {
      throw Exception('No se encontro el registro');
    }

    return result;
  }

  @override
  Future<List<TransaccionDto>> listaTransacciones() async {
    try {
      final mappr = TransaccionMapprImpl();
      TransferenciaShema transferenciaShema = TransferenciaShema();

      List<Transaccion> listTransacciones = await transferenciaShema.getAll();

      List<TransaccionDto> listTransaccionesDto =
          listTransacciones.map((transaccion) {
        return mappr.fromDto(transaccion);
      }).toList();

      return listTransaccionesDto;
    } catch (e, pila) {
      Registro.error('TransaccionHandler: error en consulta', e, pila);
      rethrow;
    }
  }

  Future<List<TransaccionBalanceDto>> getBalanceByProyectoId(
      int proyectoId) async {
    try {
      TransferenciaShema transferenciaShema = TransferenciaShema();
      List<TransaccionBalanceDto> list =
          await transferenciaShema.getBalanceByProyectoId(proyectoId);

      return list;
    } catch (e, pila) {
      Registro.error('TransaccionHandler: error en consulta', e, pila);
      rethrow;
    }
  }

  Future<List<TransaccionPortafolioDto>> listaTransaccionByPortafolioId(
      int portafolioId) async {
    try {
      TransferenciaShema transferenciaShema = TransferenciaShema();
      List<TransaccionPortafolioDto> list =
          await transferenciaShema.getTransaccionByPortafolioId(portafolioId);
      return list;
    } catch (e, pila) {
      Registro.error('TransaccionHandler: error en consulta', e, pila);
      rethrow;
    }
  }

  @override
  Future<List<TransaccionDto>> listaTransaccionesByPortafolio(int id) async {
    try {
      final mappr = TransaccionMapprImpl();
      TransferenciaShema transferenciaShema = TransferenciaShema();

      List<Transaccion> listTransacciones =
          await transferenciaShema.getByPortafolioId(id);

      List<TransaccionDto> listTransaccionesDto =
          listTransacciones.map((transaccion) {
        return mappr.fromDto(transaccion);
      }).toList();

      return listTransaccionesDto;
    } catch (e, pila) {
      Registro.error('TransaccionHandler: error en consulta', e, pila);
      rethrow;
    }
  }

  @override
  Future<TransaccionDto> findTransaccion(int id) async {
    final mappr = TransaccionMapprImpl();
    TransferenciaShema transferenciaShema = TransferenciaShema();

    Transaccion? result = await transferenciaShema.getById(id);

    if (result == null) {
      throw Exception('Transacción con ID $id no encontrada');
    }

    return mappr.fromDto(result);
  }

  @override
  Future<TransaccionDetailsDto> findTransaccionDetails(int id) async {
    try {
      TransferenciaShema transferenciaShema = TransferenciaShema();

      TransaccionDetailsDto? result =
          await transferenciaShema.getTransaccionDetails(id);

      if (result == null) {
        throw Exception('Transacción con ID $id no encontrada');
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TransaccionBalanceDto>> findTransaccionesByMesAndAnio(
      String year, String month) async {
    try {
      TransferenciaShema transferenciaShema = TransferenciaShema();

      List<TransaccionBalanceDto> listTransaccionesDto =
          await transferenciaShema.getTransaccionesByMesAndAnio(year, month);

      return listTransaccionesDto;
    } catch (e, pila) {
      Registro.error('TransaccionHandler: error en consulta', e, pila);
      rethrow;
    }
  }

  @override
  int calcularGmf(
      {required int valor,
      required String tipoFuente,
      required String? exentaImpuesto}) {
    return CalculadoraGmf.calcular(
        valor: valor, tipoFuente: tipoFuente, exentaImpuesto: exentaImpuesto);
  }

  @override
  Future<ResultadoMovimientosDto> buscarMovimientos(
      FiltroMovimientos filtro) async {
    try {
      final schema = TransferenciaShema();
      final movimientos = await schema.buscarMovimientos(filtro);
      final totales = await schema.totalizarMovimientos(filtro);
      return ResultadoMovimientosDto(
        movimientos: movimientos,
        totales: TotalMensualMapprImpl().fromDto(totales),
        cantidadTotal: totales.cantidad,
      );
    } catch (e, pila) {
      Registro.error('TransaccionHandler: error en búsqueda', e, pila);
      rethrow;
    }
  }

  static const descripcionAjuste = 'Ajuste de saldo';

  @override
  Future<int> ajustarSaldo(int idPortafolio, int saldoReal) async {
    try {
      final saldoActual = await PortafolioHandler().obtenerSaldo(idPortafolio);
      final diferencia = saldoReal - saldoActual;
      if (diferencia == 0) {
        throw Exception('El saldo ya coincide; no hay nada que ajustar');
      }
      final fuente = diferencia > 0 ? TipoFuente.ingreso : TipoFuente.egreso;
      final tipo = await TipoTransaccionSchema().getPrimeroPorFuente(fuente);
      if (tipo == null) {
        throw Exception('No hay un tipo de transacción para registrar el ajuste');
      }
      // El ajuste corrige el registro, no es un movimiento real: sin GMF ni
      // validación de saldo.
      return await TransferenciaShema().insert(Transaccion(
        valor: diferencia.abs(),
        impuesto: 0,
        tipoTransferenciaId: tipo.idTipoTransaccion!,
        portafolioId: idPortafolio,
        descripcion: descripcionAjuste,
      ));
    } catch (e, pila) {
      Registro.error('TransaccionHandler: error al ajustar saldo', e, pila);
      rethrow;
    }
  }
}
