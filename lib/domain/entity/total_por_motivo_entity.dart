/// Total egresado por un motivo en un rango de fechas.
class TotalPorMotivo {
  /// `null` agrupa los egresos registrados sin motivo.
  int? idMotivo;
  String? nombre;
  int total;
  int cantidad;

  TotalPorMotivo({
    this.idMotivo,
    this.nombre,
    required this.total,
    required this.cantidad,
  });

  factory TotalPorMotivo.fromJson(Map<String, dynamic> json) => TotalPorMotivo(
        idMotivo: json["id_motivo"],
        nombre: json["nombre"],
        total: json["total"] ?? 0,
        cantidad: json["cantidad"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id_motivo": idMotivo,
        "nombre": nombre,
        "total": total,
        "cantidad": cantidad,
      };
}
