/// Totales de ingresos, egresos y GMF de un periodo (mes) o ámbito.
///
/// Las transferencias entre portafolios propios no cuentan como ingreso ni
/// egreso del ámbito: solo mueven dinero dentro de él. Su GMF sí cuenta.
class TotalMensual {
  /// Periodo en formato `yyyy-MM`. Vacío cuando el total no es mensual.
  String periodo;
  int ingresos;
  int egresos;
  int impuestos;

  /// Número de movimientos (solo lo llenan algunas consultas).
  int cantidad = 0;

  TotalMensual({
    required this.periodo,
    required this.ingresos,
    required this.egresos,
    required this.impuestos,
  });

  factory TotalMensual.fromJson(Map<String, dynamic> json) => TotalMensual(
        periodo: json["periodo"] ?? '',
        ingresos: json["ingresos"] ?? 0,
        egresos: json["egresos"] ?? 0,
        impuestos: json["impuestos"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "periodo": periodo,
        "ingresos": ingresos,
        "egresos": egresos,
        "impuestos": impuestos,
      };
}
