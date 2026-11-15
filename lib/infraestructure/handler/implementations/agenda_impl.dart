import 'dart:math';

import 'package:inversiones/config/registro.dart';
import 'package:inversiones/domain/entity/portafolio_entity.dart';
import 'package:inversiones/domain/entity/recurrente_entity.dart';
import 'package:inversiones/domain/models/calculadora_gmf.dart';
import 'package:inversiones/domain/models/proyector_flujo.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/recurrente_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/deuda_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/meta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/recurrente_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/agenda_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/deuda_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/meta_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/recurrente_interface.dart';
import 'package:inversiones/page/agenda/dto/agenda_dto.dart';

class AgendaHandler implements IAgenda {
  final IRecurrente _recurrentes;
  final IDeuda _deudas;
  final IPortafolio _portafolios;
  final IMeta _metas;

  AgendaHandler(
      {IRecurrente? recurrentes,
      IDeuda? deudas,
      IPortafolio? portafolios,
      IMeta? metas})
      : _recurrentes = recurrentes ?? RecurrenteHandler(),
        _deudas = deudas ?? DeudaHandler(),
        _portafolios = portafolios ?? PortafolioHandler(),
        _metas = metas ?? MetaHandler();

  @override
  Future<AgendaDto> proyectar({DateTime? hoy, int meses = 3}) async {
    try {
      final ahora = hoy ?? DateTime.now();
      final desde = DateTime(ahora.year, ahora.month, ahora.day);
      final hasta = DateTime(desde.year, desde.month + meses, desde.day);
      final liquidez = await _Liquidez.cargar();

      final eventos = <EventoAgendaDto>[
        ...await _fijos(desde, hasta, liquidez),
        ...await _pagosDeDeudas(desde, hasta, liquidez),
        ...await _vencimientos(desde, hasta, liquidez),
        ...await _fechasDeMetas(desde, hasta),
      ];
      return ProyectorFlujo.proyectar(
        saldoInicial: liquidez.saldoDisponible,
        eventos: eventos,
        desde: desde,
        hasta: hasta,
      );
    } catch (e, pila) {
      Registro.error('AgendaHandler: error al proyectar', e, pila);
      rethrow;
    }
  }

  @override
  Future<int> registrarFijo(int idRecurrente, {DateTime? fecha}) =>
      _recurrentes.registrar(idRecurrente, fecha: fecha);

  /// Fijos activos de cada mes del horizonte que aún no se registran. Los
  /// del mes actual cuyo día ya pasó quedan como atrasados.
  Future<List<EventoAgendaDto>> _fijos(
      DateTime desde, DateTime hasta, _Liquidez liquidez) async {
    final eventos = <EventoAgendaDto>[];
    for (var mes = DateTime(desde.year, desde.month);
        !mes.isAfter(hasta);
        mes = DateTime(mes.year, mes.month + 1)) {
      for (final f in await _recurrentes.listar(fecha: mes)) {
        final fecha = f.fechaProgramada;
        if (!f.activo || !f.tocaEnMes || f.registradoEnMes || fecha == null) {
          continue;
        }
        if (fecha.isAfter(hasta)) continue;
        final plantilla = liquidez.recurrentes[f.idRecurrente];
        if (plantilla == null) continue;
        eventos.add(EventoAgendaDto(
          fecha: fecha,
          titulo: f.nombre,
          detalle: f.destino == null ? f.origen : '${f.origen} → ${f.destino}',
          tipo: switch (f.tipoFuente) {
            TipoFuente.ingreso => TipoEventoAgenda.ingreso,
            TipoFuente.egreso => TipoEventoAgenda.gasto,
            _ => TipoEventoAgenda.transferencia,
          },
          valor: f.valor,
          efecto: liquidez.efecto(
              tipoFuente: f.tipoFuente,
              valor: f.valor,
              origen: plantilla.portafolioId,
              destino: plantilla.destinoCuenta),
          atrasado: fecha.isBefore(desde),
          idRecurrente: f.idRecurrente,
        ));
      }
    }
    return eventos;
  }

  /// Próximo pago de cada tarjeta (deuda total, estimado) y cuotas de cada
  /// préstamo. Se omiten las deudas que ya tienen un fijo que las paga.
  Future<List<EventoAgendaDto>> _pagosDeDeudas(
      DateTime desde, DateTime hasta, _Liquidez liquidez) async {
    final eventos = <EventoAgendaDto>[];
    for (final cuenta in liquidez.cuentasDeuda) {
      final principal = liquidez.principalDe[cuenta];
      if (principal != null && liquidez.destinosDeFijos.contains(principal)) {
        continue;
      }
      final r = await _deudas.resumen(cuenta, hoy: desde);
      final pago = r.proximoPago;
      if (r.deuda <= 0 || pago == null) continue;
      final esTarjeta = r.tipoCuenta == TipoCuenta.tarjetaCredito;
      if (esTarjeta) {
        if (pago.isAfter(hasta)) continue;
        eventos.add(EventoAgendaDto(
          fecha: pago,
          titulo: r.nombre,
          tipo: TipoEventoAgenda.deuda,
          valor: r.deuda,
          efecto: -r.deuda,
          estimado: true,
          idCuenta: cuenta,
        ));
        continue;
      }
      final cuota = r.cuotaFija ?? 0;
      if (cuota <= 0) continue;
      var pendiente = r.deuda;
      // Mismo día de pago cada mes (en meses cortos, el último día).
      final dia = r.condiciones.diaPago ?? pago.day;
      for (var fecha = pago;
          !fecha.isAfter(hasta) && pendiente > 0;
          fecha = RecurrenteHandler.fechaEnMes(
              DateTime(fecha.year, fecha.month + 1), dia)) {
        final valor = min(cuota, pendiente + r.interesEstimado);
        eventos.add(EventoAgendaDto(
          fecha: fecha,
          titulo: r.nombre,
          tipo: TipoEventoAgenda.deuda,
          valor: valor,
          efecto: -valor,
          idCuenta: cuenta,
        ));
        pendiente -= cuota;
      }
    }
    return eventos;
  }

  /// CDT que vencen en el horizonte (o ya vencieron): se espera recibir su
  /// saldo más el rendimiento estimado.
  Future<List<EventoAgendaDto>> _vencimientos(
      DateTime desde, DateTime hasta, _Liquidez liquidez) async {
    final lista = await _portafolios.listarVencimientos(
        hoy: desde, dias: hasta.difference(desde).inDays);
    return [
      for (final v in lista)
        if (v.saldo > 0)
          EventoAgendaDto(
            fecha: v.fechaVencimiento,
            titulo: v.nombre,
            tipo: TipoEventoAgenda.vencimiento,
            valor: v.saldo + v.rendimientoEstimado,
            efecto: liquidez.esLiquido(v.idPortafolio)
                ? 0
                : v.saldo + v.rendimientoEstimado,
            atrasado: v.vencido,
            estimado: v.rendimientoEstimado > 0,
            idPortafolio: v.idPortafolio,
          ),
    ];
  }

  /// Fechas objetivo de las metas activas sin completar (informativo).
  Future<List<EventoAgendaDto>> _fechasDeMetas(
      DateTime desde, DateTime hasta) async {
    final metas = await _metas.listar(hoy: desde);
    return [
      for (final m in metas)
        if (m.activo &&
            !m.completada &&
            m.fechaObjetivo != null &&
            !m.fechaObjetivo!.isBefore(desde) &&
            !m.fechaObjetivo!.isAfter(hasta))
          EventoAgendaDto(
            fecha: m.fechaObjetivo!,
            titulo: m.nombre,
            tipo: TipoEventoAgenda.meta,
            valor: m.falta,
            efecto: 0,
            idMeta: m.idMeta,
          ),
    ];
  }
}

/// Qué portafolios son dinero disponible (cuentas que no son tarjetas ni
/// préstamos) y cómo afecta cada movimiento a ese saldo.
class _Liquidez {
  final Map<int, Portafolio> portafolios;
  final Set<int> liquidos;
  final int saldoDisponible;
  final Map<int, Recurrente> recurrentes;
  final List<int> cuentasDeuda;
  final Map<int, int> principalDe;
  final Set<int> destinosDeFijos;

  _Liquidez(this.portafolios, this.liquidos, this.saldoDisponible,
      this.recurrentes, this.cuentasDeuda, this.principalDe,
      this.destinosDeFijos);

  static Future<_Liquidez> cargar() async {
    final cuentas = await CuentaSchema().getAll();
    final pasivas = {
      for (final c in cuentas)
        if (TipoCuenta.esPasivo(c.tipoCuenta) && c.idCuenta != null)
          c.idCuenta!
    };
    final portafolios = {
      for (final p in await PortafolioSchema().getAll()) p.idPortafolio!: p,
    };
    final liquidos = {
      for (final p in portafolios.values)
        if (p.cuentaId != null && !pasivas.contains(p.cuentaId))
          p.idPortafolio!
    };
    var saldo = 0;
    for (final s in await TransferenciaShema().obtenerSaldos()) {
      if (liquidos.contains(s.idPortafolio)) saldo += s.saldo;
    }
    final recurrentes = {
      for (final r in await RecurrenteSchema().getAll()) r.idRecurrente!: r,
    };
    final principalDe = {
      for (final p in portafolios.values)
        if (p.esPrincipal && p.cuentaId != null) p.cuentaId!: p.idPortafolio!
    };
    final destinos = {
      for (final r in recurrentes.values)
        if (r.activo && r.destinoCuenta != null) r.destinoCuenta!
    };
    return _Liquidez(portafolios, liquidos, saldo, recurrentes,
        pasivas.toList(), principalDe, destinos);
  }

  bool esLiquido(int? idPortafolio) =>
      idPortafolio != null && liquidos.contains(idPortafolio);

  /// Cambio del saldo disponible por un movimiento: ingresos suman si
  /// llegan a una cuenta; egresos y transferencias restan (con 4x1000) si
  /// salen de una cuenta, y una transferencia suma si llega a una cuenta.
  int efecto(
      {required String tipoFuente,
      required int valor,
      required int origen,
      int? destino}) {
    if (tipoFuente == TipoFuente.ingreso) {
      return esLiquido(origen) ? valor : 0;
    }
    final gmf = CalculadoraGmf.calcular(
        valor: valor,
        tipoFuente: tipoFuente,
        exentaImpuesto: portafolios[origen]?.exentaImpuesto);
    var efecto = esLiquido(origen) ? -(valor + gmf) : 0;
    if (tipoFuente == TipoFuente.transferencia && esLiquido(destino)) {
      efecto += valor;
    }
    return efecto;
  }
}
