/// Saldo de un portafolio para la capa de presentación.
class SaldoPortafolioDto {
  int idPortafolio;
  String nombre;
  int? proyectoId;
  int ingresos;
  int egresos;
  int impuestos;
  int saldo;

  SaldoPortafolioDto({
    required this.idPortafolio,
    required this.nombre,
    this.proyectoId,
    required this.ingresos,
    required this.egresos,
    required this.impuestos,
    required this.saldo,
  });
}
