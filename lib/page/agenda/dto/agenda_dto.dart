/// Qué origina un evento de la agenda.
enum TipoEventoAgenda {
  /// Fijo de ingreso (salario, arriendo recibido...).
  ingreso,

  /// Fijo de egreso (servicios, arriendo...).
  gasto,

  /// Fijo de transferencia: aporte programado, ahorro, pago a otra cuenta.
  transferencia,

  /// Pago de tarjeta o cuota de préstamo.
  deuda,

  /// Vencimiento de un CDT o inversión a término.
  vencimiento,

  /// Fecha objetivo de una meta de ahorro (solo informativo).
  meta;

  String get clave => 'agenda_tipo_$name';
}

/// Un compromiso o ingreso esperado en una fecha.
class EventoAgendaDto {
  final DateTime fecha;
  final String titulo;
  final String? detalle;
  final TipoEventoAgenda tipo;

  /// Valor del movimiento (positivo).
  final int valor;

  /// Cómo cambia el saldo disponible: + entra, − sale, 0 no lo toca
  /// (p. ej. un traslado entre cuentas propias o una meta).
  final int efecto;

  /// Debía registrarse antes de hoy y sigue pendiente.
  final bool atrasado;

  /// Valor aproximado (rendimiento de un CDT, pago total de una tarjeta).
  final bool estimado;

  final int? idRecurrente;
  final int? idCuenta;
  final int? idPortafolio;
  final int? idMeta;

  const EventoAgendaDto({
    required this.fecha,
    required this.titulo,
    this.detalle,
    required this.tipo,
    required this.valor,
    required this.efecto,
    this.atrasado = false,
    this.estimado = false,
    this.idRecurrente,
    this.idCuenta,
    this.idPortafolio,
    this.idMeta,
  });
}

/// Eventos de un día con el saldo disponible proyectado al cerrar el día.
class DiaAgendaDto {
  final DateTime fecha;
  final List<EventoAgendaDto> eventos;
  final int efecto;
  final int saldo;

  const DiaAgendaDto({
    required this.fecha,
    required this.eventos,
    required this.efecto,
    required this.saldo,
  });
}

/// Agenda y flujo de caja proyectado de [desde] a [hasta].
class AgendaDto {
  final DateTime desde;
  final DateTime hasta;

  /// Saldo disponible hoy: cuentas de ahorro, corrientes, digitales y
  /// efectivo (sin tarjetas, préstamos ni inversiones).
  final int saldoInicial;
  final List<DiaAgendaDto> dias;
  final int entradas;
  final int salidas;
  final int saldoFinal;

  /// Saldo proyectado al cierre del mes actual.
  final int saldoFinDeMes;
  final int saldoMinimo;
  final DateTime fechaSaldoMinimo;

  /// Primer día en que el saldo disponible queda negativo (o `null`).
  final DateTime? primerNegativo;

  const AgendaDto({
    required this.desde,
    required this.hasta,
    required this.saldoInicial,
    required this.dias,
    required this.entradas,
    required this.salidas,
    required this.saldoFinal,
    required this.saldoFinDeMes,
    required this.saldoMinimo,
    required this.fechaSaldoMinimo,
    required this.primerNegativo,
  });

  int get atrasados =>
      dias.fold(0, (n, d) => n + d.eventos.where((e) => e.atrasado).length);
}
