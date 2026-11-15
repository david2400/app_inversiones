/// Patrimonio al cierre de un mes.
class PuntoPatrimonioDto {
  /// `yyyy-MM`.
  final String periodo;
  final int patrimonio;

  const PuntoPatrimonioDto({required this.periodo, required this.patrimonio});
}

/// Rentabilidad de un grupo de inversiones (un proyecto o un tipo de
/// proyecto).
///
/// - [aportado]: capital que entró desde fuera (cuentas, saldo inicial).
/// - [retirado]: dinero que salió hacia las cuentas o a externos.
/// - [ganancia]: rendimientos menos gastos y GMF.
/// - [saldo]: lo que hay hoy (= aportado − retirado + ganancia).
class RentabilidadDto {
  /// Id del proyecto o del tipo (nulo = "sin tipo").
  final int? id;
  final String? nombre;

  /// Nivel de riesgo del tipo (ver `NivelRiesgo`), si aplica.
  final String? riesgo;
  final int saldo;
  final int aportado;
  final int retirado;
  final int ganancia;
  final int cantidad;

  const RentabilidadDto({
    this.id,
    this.nombre,
    this.riesgo,
    required this.saldo,
    required this.aportado,
    required this.retirado,
    required this.ganancia,
    this.cantidad = 0,
  });

  /// Ganancia sobre lo aportado, en porcentaje; nulo si no hay aportes.
  double? get porcentaje => aportado > 0 ? ganancia * 100 / aportado : null;
}

/// Foto del patrimonio: qué tienes, qué debes y cómo rinden tus
/// inversiones.
class PatrimonioDto {
  /// Saldo de las cuentas de activo (ahorros, corriente, digital,
  /// efectivo) y saldos a favor en tarjetas o préstamos.
  final int enCuentas;

  /// Saldo de los portafolios de proyectos.
  final int invertido;

  /// Lo que debes en tarjetas y préstamos (positivo).
  final int deudas;

  /// Patrimonio al cierre de cada mes (el último es el actual).
  final List<PuntoPatrimonioDto> evolucion;

  /// Rentabilidad agrupada por tipo de proyecto (mayor saldo primero).
  final List<RentabilidadDto> porTipo;

  /// Rentabilidad de cada proyecto (mayor saldo primero).
  final List<RentabilidadDto> porProyecto;

  const PatrimonioDto({
    required this.enCuentas,
    required this.invertido,
    required this.deudas,
    required this.evolucion,
    required this.porTipo,
    required this.porProyecto,
  });

  /// Lo que tienes menos lo que debes.
  int get neto => enCuentas + invertido - deudas;

  /// Rentabilidad de todas las inversiones juntas.
  RentabilidadDto get totalInversiones => RentabilidadDto(
        saldo: porProyecto.fold(0, (s, r) => s + r.saldo),
        aportado: porProyecto.fold(0, (s, r) => s + r.aportado),
        retirado: porProyecto.fold(0, (s, r) => s + r.retirado),
        ganancia: porProyecto.fold(0, (s, r) => s + r.ganancia),
        cantidad: porProyecto.length,
      );

  /// Cambio del patrimonio frente al mes anterior.
  int get variacionMes => evolucion.length < 2
      ? 0
      : evolucion.last.patrimonio - evolucion[evolucion.length - 2].patrimonio;
}
