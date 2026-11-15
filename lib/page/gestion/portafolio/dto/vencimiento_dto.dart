/// Portafolio con plazo (CDT o similar) que vence pronto o ya venció.
class VencimientoDto {
  final int idPortafolio;
  final String nombre;
  final int? proyectoId;
  final DateTime fechaVencimiento;

  /// Días que faltan (negativo si ya venció).
  final int diasRestantes;
  final int saldo;

  /// Rendimiento estimado desde hoy hasta el vencimiento con su tasa E.A.
  final int rendimientoEstimado;

  const VencimientoDto({
    required this.idPortafolio,
    required this.nombre,
    this.proyectoId,
    required this.fechaVencimiento,
    required this.diasRestantes,
    required this.saldo,
    required this.rendimientoEstimado,
  });

  bool get vencido => diasRestantes < 0;
}
