/// Saldo calculado de un portafolio a partir de sus movimientos activos.
class SaldoPortafolio {
  int idPortafolio;
  String nombre;
  int? proyectoId;
  int ingresos;
  int egresos;
  int impuestos;
  int saldo;

  SaldoPortafolio({
    required this.idPortafolio,
    required this.nombre,
    this.proyectoId,
    required this.ingresos,
    required this.egresos,
    required this.impuestos,
    required this.saldo,
  });

  factory SaldoPortafolio.fromJson(Map<String, dynamic> json) =>
      SaldoPortafolio(
        idPortafolio: json["id_portafolio"],
        nombre: json["nombre"],
        proyectoId: json["proyecto_id"],
        ingresos: json["ingresos"] ?? 0,
        egresos: json["egresos"] ?? 0,
        impuestos: json["impuestos"] ?? 0,
        saldo: json["saldo"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id_portafolio": idPortafolio,
        "nombre": nombre,
        "proyecto_id": proyectoId,
        "ingresos": ingresos,
        "egresos": egresos,
        "impuestos": impuestos,
        "saldo": saldo,
      };
}
