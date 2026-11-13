import 'dart:math' as math;

/// Cálculos de deudas: intereses mensuales, cuota fija (sistema francés)
/// y tabla de amortización. Las tasas son mensuales (E.M.) y se guardan
/// como enteros en milésimas de punto porcentual (1,85 % = 1850).
class CalculadoraCredito {
  /// 1 % = 1000.
  static const escalaTasa = 1000;
  static const _porcentaje = 100;

  CalculadoraCredito._();

  /// Convierte la tasa guardada a fracción: 1850 → 0,0185.
  static double tasaComoFraccion(int tasaMensual) =>
      tasaMensual / (escalaTasa * _porcentaje);

  /// Convierte un porcentaje escrito por el usuario (1,85) a la escala
  /// guardada (1850).
  static int tasaDesdePorcentaje(double porcentaje) =>
      (porcentaje * escalaTasa).round();

  /// Porcentaje para mostrar: 1850 → 1,85.
  static double porcentaje(int tasaMensual) => tasaMensual / escalaTasa;

  /// Interés de un mes sobre [deuda].
  static int interesMensual(int deuda, int tasaMensual) =>
      deuda <= 0 ? 0 : (deuda * tasaComoFraccion(tasaMensual)).round();

  /// Cuota fija mensual (sistema francés) para [monto] a [plazoMeses].
  static int cuotaFija(int monto, int tasaMensual, int plazoMeses) {
    if (monto <= 0 || plazoMeses <= 0) return 0;
    final r = tasaComoFraccion(tasaMensual);
    if (r == 0) return (monto / plazoMeses).ceil();
    final cuota = monto * r / (1 - math.pow(1 + r, -plazoMeses));
    return cuota.round();
  }

  /// Tabla de amortización desde una [deuda] actual pagando [cuota] cada
  /// mes, hasta saldarla o llegar a [maximoMeses].
  static List<CuotaAmortizacion> tablaAmortizacion(
      {required int deuda,
      required int tasaMensual,
      required int cuota,
      int maximoMeses = 600}) {
    final tabla = <CuotaAmortizacion>[];
    var saldo = deuda;
    for (var mes = 1; saldo > 0 && mes <= maximoMeses; mes++) {
      final interes = interesMensual(saldo, tasaMensual);
      final capital = math.min(math.max(cuota - interes, 0), saldo);
      if (capital == 0) break; // La cuota no alcanza ni para los intereses.
      saldo -= capital;
      tabla.add(CuotaAmortizacion(
          numero: mes,
          cuota: capital + interes,
          capital: capital,
          interes: interes,
          saldo: saldo));
    }
    return tabla;
  }
}

/// Una fila de la tabla de amortización.
class CuotaAmortizacion {
  final int numero;
  final int cuota;
  final int capital;
  final int interes;
  final int saldo;

  const CuotaAmortizacion({
    required this.numero,
    required this.cuota,
    required this.capital,
    required this.interes,
    required this.saldo,
  });
}
