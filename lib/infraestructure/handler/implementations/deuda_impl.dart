import 'dart:math' as math;

import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/entity/condiciones_credito_entity.dart';
import 'package:inversiones/domain/entity/motivos_entity.dart';
import 'package:inversiones/domain/entity/recurrente_entity.dart';
import 'package:inversiones/domain/mappers/condiciones_credito_mapper.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/models/calculadora_credito.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/condiciones_credito_schema.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/recurrente_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/deuda_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/cuentas/dto/deuda_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';

class DeudaHandler implements IDeuda {
  static const motivoCuotaManejo = 'Cuota de manejo';
  static const motivoIntereses = 'Intereses';
  static const diaMinimo = 1;
  static const diaMaximo = 31;

  final ICuenta _cuentaHandler;
  final IPortafolio _portafolioHandler;
  final ITransaccion _transaccionHandler;
  final CondicionesCreditoSchema _condicionesSchema;
  final PortafolioSchema _portafolioSchema;
  final RecurrenteSchema _recurrenteSchema;

  DeudaHandler({
    ICuenta? cuentaHandler,
    IPortafolio? portafolioHandler,
    ITransaccion? transaccionHandler,
    CondicionesCreditoSchema? condicionesSchema,
    PortafolioSchema? portafolioSchema,
    RecurrenteSchema? recurrenteSchema,
  })  : _cuentaHandler = cuentaHandler ?? CuentaHandler(),
        _portafolioHandler = portafolioHandler ?? PortafolioHandler(),
        _transaccionHandler = transaccionHandler ?? TransaccionHandler(),
        _condicionesSchema = condicionesSchema ?? CondicionesCreditoSchema(),
        _portafolioSchema = portafolioSchema ?? PortafolioSchema(),
        _recurrenteSchema = recurrenteSchema ?? RecurrenteSchema();

  // ---------------------------------------------------------------------------
  // Alta y edición
  // ---------------------------------------------------------------------------

  @override
  Future<int> guardarTarjeta(
          CuentaDto cuenta, CondicionesCreditoDto condiciones) =>
      DatabaseHelper().enTransaccion(() async {
        if ((condiciones.cupo ?? 0) <= 0) {
          throw Exception('El cupo de la tarjeta debe ser mayor a cero');
        }
        _validarCondiciones(condiciones);
        cuenta
          ..tipoCuenta = TipoCuenta.tarjetaCredito
          ..exentaImpuesto = 'S';
        final idCuenta = await _cuentaHandler.guardarCuenta(cuenta);
        final principal = await _principal(idCuenta);

        final existente = await _condicionesSchema.getById(idCuenta);
        final entidad = CondicionesCreditoMapprImpl().fromModel(
            condiciones..idCuenta = idCuenta);
        entidad.recurrenteManejoId = await _sincronizarCuotaManejo(
          nombreTarjeta: cuenta.nombre.trim(),
          idPortafolio: principal,
          cuotaManejo: condiciones.cuotaManejo ?? 0,
          dia: condiciones.diaCorte ?? diaMinimo,
          idRecurrente: existente?.recurrenteManejoId,
        );
        if (existente == null) {
          await _condicionesSchema.insert(entidad);
        } else {
          entidad.createdAt = existente.createdAt;
          await _condicionesSchema.update(entidad);
        }
        return idCuenta;
      });

  @override
  Future<int> crearPrestamo(
          CuentaDto cuenta, CondicionesCreditoDto condiciones,
          {required int idCuentaDesembolso, String? fecha}) =>
      DatabaseHelper().enTransaccion(() async {
        final monto = condiciones.cupo ?? 0;
        if (monto <= 0) throw Exception('El monto del préstamo debe ser mayor a cero');
        if ((condiciones.plazoMeses ?? 0) <= 0) {
          throw Exception('El plazo debe ser de al menos un mes');
        }
        _validarCondiciones(condiciones);
        cuenta
          ..idCuenta = null
          ..tipoCuenta = TipoCuenta.prestamo
          ..exentaImpuesto = 'S';
        final idCuenta = await _cuentaHandler.guardarCuenta(cuenta);
        final principal = await _principal(idCuenta);
        final destino = await _principal(idCuentaDesembolso);

        await _condicionesSchema.insert(CondicionesCreditoMapprImpl()
            .fromModel(condiciones
              ..idCuenta = idCuenta
              ..cuotaManejo = null
              ..recurrenteManejoId = null
              ..fechaDesembolso = (fecha ?? Auditoria.ahora()).substring(0, 10)));

        // Desembolso: el dinero llega a la cuenta y nace la deuda.
        await _transaccionHandler.createTransaccion(TransaccionDto(
          valor: monto,
          tipoTransferenciaId: await _tipo(TipoFuente.transferencia),
          portafolioId: principal,
          destinoCuenta: destino,
          descripcion: 'Desembolso ${cuenta.nombre.trim()}',
          createdAt: fecha,
        ));
        return idCuenta;
      });

  void _validarCondiciones(CondicionesCreditoDto c) {
    if (c.tasaMensual < 0) throw Exception('La tasa no puede ser negativa');
    for (final dia in [c.diaCorte, c.diaPago]) {
      if (dia != null && (dia < diaMinimo || dia > diaMaximo)) {
        throw Exception('Los días deben estar entre $diaMinimo y $diaMaximo');
      }
    }
    if ((c.cuotaManejo ?? 0) < 0) {
      throw Exception('La cuota de manejo no puede ser negativa');
    }
  }

  /// Crea, actualiza o pausa el movimiento fijo automático de la cuota de
  /// manejo. Retorna su id (o el existente si quedó pausado).
  Future<int?> _sincronizarCuotaManejo({
    required String nombreTarjeta,
    required int idPortafolio,
    required int cuotaManejo,
    required int dia,
    int? idRecurrente,
  }) async {
    final actual =
        idRecurrente == null ? null : await _recurrenteSchema.getById(idRecurrente);
    if (cuotaManejo <= 0) {
      if (actual != null && actual.activo) {
        actual.activo = false;
        await _recurrenteSchema.update(actual);
      }
      return actual?.idRecurrente;
    }
    final nombre = '$motivoCuotaManejo $nombreTarjeta';
    if (actual != null) {
      actual
        ..nombre = nombre
        ..valor = cuotaManejo
        ..diaMes = dia
        ..activo = true
        ..automatico = true;
      await _recurrenteSchema.update(actual);
      return actual.idRecurrente;
    }
    return _recurrenteSchema.insert(Recurrente(
      nombre: nombre,
      tipoTransferenciaId: await _tipo(TipoFuente.egreso),
      portafolioId: idPortafolio,
      motivoId: await _motivo(motivoCuotaManejo),
      valor: cuotaManejo,
      diaMes: dia,
      automatico: true,
    ));
  }

  @override
  Future<CondicionesCreditoDto?> obtenerCondiciones(int idCuenta) async {
    final condiciones = await _condicionesSchema.getById(idCuenta);
    return condiciones == null
        ? null
        : CondicionesCreditoMapprImpl().fromDto(condiciones);
  }

  // ---------------------------------------------------------------------------
  // Consulta
  // ---------------------------------------------------------------------------

  @override
  Future<ResumenDeudaDto> resumen(int idCuenta, {DateTime? hoy}) async {
    final fecha = hoy ?? DateTime.now();
    final cuenta = await _cuentaHandler.obtenerCuenta(idCuenta);
    if (!TipoCuenta.esPasivo(cuenta.tipoCuenta)) {
      throw Exception('La cuenta no es una deuda');
    }
    final entidad = await _condicionesSchema.getById(idCuenta) ??
        CondicionesCredito(idCuenta: idCuenta);
    final condiciones = CondicionesCreditoMapprImpl().fromDto(entidad);
    final deuda = math.max(-cuenta.saldo, 0);
    final esTarjeta = cuenta.tipoCuenta == TipoCuenta.tarjetaCredito;

    int? cuotaFija;
    var amortizacion = const <CuotaAmortizacion>[];
    if (!esTarjeta) {
      cuotaFija = CalculadoraCredito.cuotaFija(condiciones.cupo ?? 0,
          condiciones.tasaMensual, condiciones.plazoMeses ?? 0);
      amortizacion = CalculadoraCredito.tablaAmortizacion(
          deuda: deuda, tasaMensual: condiciones.tasaMensual, cuota: cuotaFija);
    }

    return ResumenDeudaDto(
      idCuenta: idCuenta,
      nombre: cuenta.nombre,
      tipoCuenta: cuenta.tipoCuenta,
      condiciones: condiciones,
      deuda: deuda,
      saldoAFavor: math.max(cuenta.saldo, 0),
      disponible: esTarjeta && condiciones.cupo != null
          ? condiciones.cupo! - deuda
          : null,
      interesEstimado:
          CalculadoraCredito.interesMensual(deuda, condiciones.tasaMensual),
      proximoCorte: _proximaFecha(fecha, condiciones.diaCorte),
      proximoPago: _proximaFecha(fecha, condiciones.diaPago),
      cuotaFija: cuotaFija,
      amortizacion: amortizacion,
      comprasACuotas: esTarjeta
          ? await _comprasACuotas(cuenta.idPortafolioPrincipal, fecha)
          : const [],
    );
  }

  Future<List<CompraCuotasDto>> _comprasACuotas(
      int? idPortafolio, DateTime hoy) async {
    if (idPortafolio == null) return const [];
    final compras = await TransferenciaShema().comprasACuotas(idPortafolio);
    return [
      for (final c in compras)
        if (c.createdAt != null)
          _compra(c.idTransferencia!, c.descripcion, c.valor, c.numeroCuotas!,
              DateTime.parse(c.createdAt!), hoy),
    ];
  }

  CompraCuotasDto _compra(int id, String? descripcion, int valor, int cuotas,
      DateTime fecha, DateTime hoy) {
    // Se cuenta una cuota pagada por cada mes transcurrido desde la compra.
    final meses = (hoy.year - fecha.year) * 12 + hoy.month - fecha.month;
    return CompraCuotasDto(
      idTransferencia: id,
      descripcion: descripcion ?? '',
      fecha: fecha,
      valor: valor,
      numeroCuotas: cuotas,
      cuotasPagadas: meses.clamp(0, cuotas),
      cuotaMensual: (valor / cuotas).ceil(),
    );
  }

  /// Próxima fecha (hoy o después) con el día [dia]; en meses cortos, el
  /// último día del mes.
  static DateTime? _proximaFecha(DateTime hoy, int? dia) {
    if (dia == null) return null;
    DateTime enMes(int anio, int mes) {
      final ultimo = DateTime(anio, mes + 1, 0).day;
      return DateTime(anio, mes, math.min(dia, ultimo));
    }

    final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
    final esteMes = enMes(hoy.year, hoy.month);
    return esteMes.isBefore(hoySinHora) ? enMes(hoy.year, hoy.month + 1) : esteMes;
  }

  // ---------------------------------------------------------------------------
  // Movimientos
  // ---------------------------------------------------------------------------

  @override
  Future<int> registrarCompra(int idTarjeta, int valor,
      {int numeroCuotas = 1,
      String? descripcion,
      int? motivoId,
      int? terceroId,
      String? fecha}) async {
    if (numeroCuotas < 1) throw Exception('El número de cuotas debe ser al menos 1');
    await _exigirTipo(idTarjeta, TipoCuenta.tarjetaCredito);
    return _transaccionHandler.createTransaccion(TransaccionDto(
      valor: valor,
      tipoTransferenciaId: await _tipo(TipoFuente.egreso),
      portafolioId: await _principal(idTarjeta),
      motivoId: motivoId,
      terceroId: terceroId,
      numeroCuotas: numeroCuotas > 1 ? numeroCuotas : null,
      descripcion: descripcion,
      createdAt: fecha,
    ));
  }

  @override
  Future<int> pagar(int idDeuda,
      {required int idCuentaOrigen, required int valor, String? fecha}) async {
    final deuda = await _cuentaHandler.obtenerCuenta(idDeuda);
    if (!TipoCuenta.esPasivo(deuda.tipoCuenta)) {
      throw Exception('La cuenta destino no es una deuda');
    }
    return _transaccionHandler.createTransaccion(TransaccionDto(
      valor: valor,
      tipoTransferenciaId: await _tipo(TipoFuente.transferencia),
      portafolioId: await _principal(idCuentaOrigen),
      destinoCuenta: deuda.idPortafolioPrincipal,
      descripcion: 'Pago ${deuda.nombre}',
      createdAt: fecha,
    ));
  }

  @override
  Future<int> registrarIntereses(int idDeuda, int valor, {String? fecha}) async {
    final deuda = await _cuentaHandler.obtenerCuenta(idDeuda);
    if (!TipoCuenta.esPasivo(deuda.tipoCuenta)) {
      throw Exception('La cuenta no es una deuda');
    }
    return _transaccionHandler.createTransaccion(TransaccionDto(
      valor: valor,
      tipoTransferenciaId: await _tipo(TipoFuente.egreso),
      portafolioId: deuda.idPortafolioPrincipal!,
      motivoId: await _motivo(motivoIntereses),
      descripcion: '$motivoIntereses ${deuda.nombre}',
      createdAt: fecha,
    ));
  }

  @override
  Future<void> pagarCuotaPrestamo(int idPrestamo,
          {required int idCuentaOrigen, String? fecha}) =>
      DatabaseHelper().enTransaccion(() async {
        final resumen = await this.resumen(idPrestamo);
        if (resumen.tipoCuenta != TipoCuenta.prestamo) {
          throw Exception('La cuenta no es un préstamo');
        }
        if (resumen.deuda <= 0) throw Exception('El préstamo ya está pagado');
        final interes = resumen.interesEstimado;
        final capital =
            math.min(math.max((resumen.cuotaFija ?? 0) - interes, 0), resumen.deuda);
        if (capital <= 0) {
          throw Exception('La cuota no alcanza para cubrir los intereses');
        }
        final origen = await _principal(idCuentaOrigen);
        await _transaccionHandler.createTransaccion(TransaccionDto(
          valor: capital,
          tipoTransferenciaId: await _tipo(TipoFuente.transferencia),
          portafolioId: origen,
          destinoCuenta: (await _principal(idPrestamo)),
          descripcion: 'Abono a capital ${resumen.nombre}',
          createdAt: fecha,
        ));
        if (interes > 0) {
          await _transaccionHandler.createTransaccion(TransaccionDto(
            valor: interes,
            tipoTransferenciaId: await _tipo(TipoFuente.egreso),
            portafolioId: origen,
            motivoId: await _motivo(motivoIntereses),
            descripcion: '$motivoIntereses ${resumen.nombre}',
            createdAt: fecha,
          ));
        }
      });

  // ---------------------------------------------------------------------------
  // Apoyo
  // ---------------------------------------------------------------------------

  Future<void> _exigirTipo(int idCuenta, String tipo) async {
    final cuenta = await CuentaSchema().getById(idCuenta);
    if (cuenta == null || cuenta.tipoCuenta != tipo) {
      throw Exception(tipo == TipoCuenta.tarjetaCredito
          ? 'La cuenta no es una tarjeta de crédito'
          : 'La cuenta no es un préstamo');
    }
  }

  Future<int> _principal(int idCuenta) async {
    final principal = await _portafolioSchema.getPrincipalDeCuenta(idCuenta);
    if (principal == null) throw Exception('La cuenta no existe');
    return principal.idPortafolio!;
  }

  Future<int> _tipo(String fuente) async {
    final tipo = await TipoTransaccionSchema().getPrimeroPorFuente(fuente);
    if (tipo == null) throw Exception('Falta un tipo de transacción base');
    return tipo.idTipoTransaccion!;
  }

  /// Id del motivo [nombre]; lo crea si no existe.
  Future<int> _motivo(String nombre) async {
    final schema = MotivosSchema();
    for (final m in await schema.getAll()) {
      if (m.nombre.toLowerCase() == nombre.toLowerCase()) return m.idMotivo!;
    }
    return schema.insert(Motivos(nombre: nombre, descripcion: ''));
  }

  /// Usado por la UI para saber si queda deuda de un portafolio.
  Future<int> saldoDePortafolio(int idPortafolio) =>
      _portafolioHandler.obtenerSaldo(idPortafolio);
}
