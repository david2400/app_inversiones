/// Aporte que se repite a un portafolio: cuánto, cada cuánto, qué día y si
/// la app lo registra sola o solo lo recuerda.
///
/// El dinero sale de la cuenta de aportes del portafolio (o de "Efectivo /
/// Sin definir" si no tiene). Se guarda como un movimiento fijo.
class AporteProgramadoDto {
  /// Id del movimiento fijo (nulo si aún no existe).
  int? idRecurrente;
  int valor;

  /// Cada cuántos meses (ver `Periodicidad.repetibles`).
  int periodoMeses;

  /// Día del mes (1–31; en meses cortos, el último día).
  int diaMes;

  /// `true`: se registra solo al llegar el día. `false`: queda pendiente
  /// en Fijos para registrarlo a mano.
  bool automatico;

  /// Primera fecha (yyyy-MM-dd) desde la que cuenta el periodo.
  String? fechaInicio;

  /// Si está pausado.
  bool activo;

  AporteProgramadoDto({
    this.idRecurrente,
    required this.valor,
    required this.periodoMeses,
    required this.diaMes,
    this.automatico = false,
    this.fechaInicio,
    this.activo = true,
  });
}
