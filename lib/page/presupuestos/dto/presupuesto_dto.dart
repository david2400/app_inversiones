/// Estado de un presupuesto según el porcentaje gastado.
enum EstadoPresupuesto { normal, alerta, excedido }

/// Presupuesto mensual de un motivo y su ejecución en el mes.
class EjecucionPresupuestoDto {
  /// Desde este porcentaje se considera en alerta.
  static const porcentajeAlerta = 80;

  int idPresupuesto;
  int motivoId;
  String motivo;
  int montoMensual;
  int gastado;

  /// Cuenta a la que se limita (nula = todas las cuentas).
  int? cuentaId;
  String? cuenta;

  EjecucionPresupuestoDto({
    required this.idPresupuesto,
    required this.motivoId,
    required this.motivo,
    required this.montoMensual,
    required this.gastado,
    this.cuentaId,
    this.cuenta,
  });

  int get disponible => montoMensual - gastado;

  int get porcentaje =>
      montoMensual <= 0 ? 0 : (gastado * 100 / montoMensual).round();

  EstadoPresupuesto get estado {
    if (gastado > montoMensual) return EstadoPresupuesto.excedido;
    if (porcentaje >= porcentajeAlerta) return EstadoPresupuesto.alerta;
    return EstadoPresupuesto.normal;
  }
}
