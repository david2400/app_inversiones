/// Total de ingresos o egresos agrupado por un concepto (motivo, tercero o
/// contraparte) en un rango de fechas.
class TotalPorConcepto {
  /// `null` agrupa los movimientos sin dato para ese concepto.
  String? nombre;
  int total;
  int cantidad;

  TotalPorConcepto({this.nombre, required this.total, required this.cantidad});

  factory TotalPorConcepto.fromJson(Map<String, dynamic> json) =>
      TotalPorConcepto(
        nombre: json["nombre"],
        total: json["total"] ?? 0,
        cantidad: json["cantidad"] ?? 0,
      );

  Map<String, dynamic> toJson() =>
      {"nombre": nombre, "total": total, "cantidad": cantidad};
}
