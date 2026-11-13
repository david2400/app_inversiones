/// Presupuesto de un motivo con lo gastado en un periodo.
class EjecucionPresupuesto {
  int idPresupuesto;
  int motivoId;
  String motivo;
  int montoMensual;
  int gastado;
  int? cuentaId;
  String? cuenta;

  EjecucionPresupuesto({
    required this.idPresupuesto,
    required this.motivoId,
    required this.motivo,
    required this.montoMensual,
    required this.gastado,
    this.cuentaId,
    this.cuenta,
  });

  factory EjecucionPresupuesto.fromJson(Map<String, dynamic> json) =>
      EjecucionPresupuesto(
        idPresupuesto: json["id_presupuesto"],
        motivoId: json["motivo_id"],
        motivo: json["motivo"],
        montoMensual: json["monto_mensual"],
        gastado: json["gastado"] ?? 0,
        cuentaId: json["cuenta_id"],
        cuenta: json["cuenta"],
      );
}
