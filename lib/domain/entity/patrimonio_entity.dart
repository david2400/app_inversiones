/// Cambio neto del patrimonio en un mes (`yyyy-MM`): ingresos menos
/// egresos, GMF y transferencias a cuentas externas. Las transferencias
/// entre portafolios propios no cambian el patrimonio (salvo su GMF).
class VariacionMensual {
  final String periodo;
  final int neto;

  const VariacionMensual({required this.periodo, required this.neto});

  factory VariacionMensual.fromJson(Map<String, dynamic> json) =>
      VariacionMensual(
        periodo: json['periodo'] as String,
        neto: (json['neto'] as int?) ?? 0,
      );
}

/// Flujos de dinero de un portafolio de proyecto, vistos desde su proyecto:
/// las transferencias entre portafolios del mismo proyecto no cuentan como
/// aporte ni retiro.
class FlujoInversion {
  final int idPortafolio;
  final int proyectoId;

  /// Capital que entró: transferencias desde fuera del proyecto y el
  /// saldo inicial del portafolio.
  final int aportes;

  /// Dinero que salió hacia fuera del proyecto (cuentas o externos).
  final int retiros;

  /// Ingresos que no son capital: rendimientos, intereses, ajustes a favor.
  final int rendimientos;

  /// Egresos, comisiones, ajustes en contra y GMF pagado.
  final int gastos;

  const FlujoInversion({
    required this.idPortafolio,
    required this.proyectoId,
    required this.aportes,
    required this.retiros,
    required this.rendimientos,
    required this.gastos,
  });

  factory FlujoInversion.fromJson(Map<String, dynamic> json) => FlujoInversion(
        idPortafolio: json['id_portafolio'] as int,
        proyectoId: json['proyecto_id'] as int,
        aportes: (json['aportes'] as int?) ?? 0,
        retiros: (json['retiros'] as int?) ?? 0,
        rendimientos: (json['rendimientos'] as int?) ?? 0,
        gastos: (json['gastos'] as int?) ?? 0,
      );
}
