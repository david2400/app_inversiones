import 'package:inversiones/domain/models/tipo_fuente.dart';

/// Movimiento fijo (cada N meses) con su estado en el mes consultado.
class RecurrenteDto {
  int idRecurrente;
  String nombre;
  String tipo;
  String tipoFuente;
  String origen;
  String? destino;
  String? motivo;
  String? tercero;
  int valor;
  int diaMes;
  bool activo;
  bool registradoEnMes;
  bool automatico;

  /// Cada cuántos meses se repite (ver `Periodicidad`).
  int periodoMeses;

  /// Fecha (yyyy-MM-dd) desde la que cuenta el periodo; nula si toca
  /// todos los meses.
  String? inicio;

  /// Portafolio del que es aporte programado, si lo es.
  int? aportePortafolioId;

  /// Si le corresponde registrarse en el mes consultado (la asigna el
  /// handler; los fijos mensuales siempre tocan).
  bool tocaEnMes;

  /// Fecha esperada en el mes consultado, o la próxima si este mes no
  /// toca (la asigna el handler).
  DateTime? fechaProgramada;

  RecurrenteDto({
    required this.idRecurrente,
    required this.nombre,
    required this.tipo,
    required this.tipoFuente,
    required this.origen,
    this.destino,
    this.motivo,
    this.tercero,
    required this.valor,
    required this.diaMes,
    required this.activo,
    required this.registradoEnMes,
    this.automatico = false,
    this.periodoMeses = 1,
    this.inicio,
    this.aportePortafolioId,
    this.tocaEnMes = true,
    this.fechaProgramada,
  });

  bool get pendiente => activo && tocaEnMes && !registradoEnMes;

  bool get esAporte => aportePortafolioId != null;

  /// Recorrido legible, igual que en las listas de movimientos.
  String get flujo {
    const sinDato = '—';
    if (tipoFuente == TipoFuente.ingreso) {
      return '${tercero ?? motivo ?? sinDato} → $origen';
    }
    return '$origen → ${destino ?? tercero ?? motivo ?? sinDato}';
  }
}
