import 'package:inversiones/page/agenda/dto/agenda_dto.dart';

/// Arma la agenda día a día y proyecta el saldo disponible a partir de un
/// saldo inicial y los eventos esperados. Es puro: no consulta la base.
class ProyectorFlujo {
  ProyectorFlujo._();

  static DateTime _dia(DateTime f) => DateTime(f.year, f.month, f.day);

  /// Orden dentro del día: primero lo que entra, luego lo que sale.
  static int _orden(EventoAgendaDto a, EventoAgendaDto b) {
    final porEfecto = b.efecto.sign.compareTo(a.efecto.sign);
    if (porEfecto != 0) return porEfecto;
    return a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase());
  }

  static AgendaDto proyectar({
    required int saldoInicial,
    required List<EventoAgendaDto> eventos,
    required DateTime desde,
    required DateTime hasta,
  }) {
    final inicio = _dia(desde);
    final fin = _dia(hasta);
    final porDia = <DateTime, List<EventoAgendaDto>>{};
    for (final e in eventos) {
      final dia = _dia(e.fecha);
      if (dia.isAfter(fin)) continue;
      // Lo atrasado se muestra hoy.
      porDia.putIfAbsent(dia.isBefore(inicio) ? inicio : dia, () => []).add(e);
    }

    var saldo = saldoInicial;
    var entradas = 0;
    var salidas = 0;
    var minimo = saldoInicial;
    var fechaMinimo = inicio;
    DateTime? primerNegativo = saldoInicial < 0 ? inicio : null;
    int? finDeMes;
    final dias = <DiaAgendaDto>[];

    for (final fecha in porDia.keys.toList()..sort()) {
      // El cierre de mes es el saldo antes del primer día del mes siguiente.
      if (finDeMes == null &&
          (fecha.year > inicio.year || fecha.month > inicio.month)) {
        finDeMes = saldo;
      }
      final lista = porDia[fecha]!..sort(_orden);
      final efecto = lista.fold<int>(0, (s, e) => s + e.efecto);
      for (final e in lista) {
        if (e.efecto > 0) entradas += e.efecto;
        if (e.efecto < 0) salidas -= e.efecto;
      }
      saldo += efecto;
      if (saldo < minimo) {
        minimo = saldo;
        fechaMinimo = fecha;
      }
      if (saldo < 0) primerNegativo ??= fecha;
      dias.add(DiaAgendaDto(
          fecha: fecha, eventos: lista, efecto: efecto, saldo: saldo));
    }

    return AgendaDto(
      desde: inicio,
      hasta: fin,
      saldoInicial: saldoInicial,
      dias: dias,
      entradas: entradas,
      salidas: salidas,
      saldoFinal: saldo,
      saldoFinDeMes: finDeMes ?? saldo,
      saldoMinimo: minimo,
      fechaSaldoMinimo: fechaMinimo,
      primerNegativo: primerNegativo,
    );
  }
}
