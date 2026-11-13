/// Límite mensual de gasto para un motivo (categoría).
class Presupuesto {
  int? idPresupuesto;
  int motivoId;
  int montoMensual;

  /// Cuenta a la que se limita (nula = todas las cuentas).
  int? cuentaId;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  Presupuesto({
    this.idPresupuesto,
    required this.motivoId,
    required this.montoMensual,
    this.cuentaId,
    this.createdAt,
    this.updatedAt,
    this.deleteAt,
  });

  factory Presupuesto.fromJson(Map<String, dynamic> json) => Presupuesto(
        idPresupuesto: json["id_presupuesto"],
        motivoId: json["motivo_id"],
        montoMensual: json["monto_mensual"],
        cuentaId: json["cuenta_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_presupuesto": idPresupuesto,
        "motivo_id": motivoId,
        "monto_mensual": montoMensual,
        "cuenta_id": cuentaId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
