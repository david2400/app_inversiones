import 'package:inversiones/domain/models/tipo_fuente.dart';

/// Movimiento fijo mensual con su estado en el mes consultado.
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

  /// Fecha esperada en el mes consultado (la asigna el handler).
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
    this.fechaProgramada,
  });

  bool get pendiente => activo && !registradoEnMes;

  /// Recorrido legible, igual que en las listas de movimientos.
  String get flujo {
    const sinDato = '—';
    if (tipoFuente == TipoFuente.ingreso) {
      return '${tercero ?? motivo ?? sinDato} → $origen';
    }
    return '$origen → ${destino ?? tercero ?? motivo ?? sinDato}';
  }
}
