import 'dart:math';

/// Cálculos de una meta de ahorro con rendimiento compuesto.
///
/// La tasa es efectiva anual (E.A., en %), como la guardan los portafolios.
/// Se convierte a tasa mensual equivalente: `(1 + EA)^(1/12) − 1`.
class CalculadoraMeta {
  CalculadoraMeta._();

  /// Aportes mensuales que caben entre [hoy] y [objetivo]: meses completos
  /// de diferencia (si el día de la meta ya pasó en el mes, ese mes no
  /// cuenta). 0 si la fecha ya pasó.
  static int mesesRestantes(DateTime hoy, DateTime objetivo) {
    var meses = (objetivo.year - hoy.year) * 12 + objetivo.month - hoy.month;
    if (objetivo.day < hoy.day) meses--;
    return max(meses, 0);
  }

  static double tasaMensual(num tasaEa) =>
      tasaEa <= 0 ? 0.0 : (pow(1 + tasaEa / 100, 1 / 12) - 1).toDouble();

  /// Valor de [saldo] dentro de [meses] meses a la tasa [tasaEa].
  static int valorFuturo(
          {required int saldo, required num tasaEa, required int meses}) =>
      (saldo * pow(1 + tasaMensual(tasaEa), meses)).round();

  /// Aporte mensual para llegar a [objetivo] en [meses] meses partiendo de
  /// [saldo], con el rendimiento [tasaEa] sobre el saldo y los aportes
  /// (aportes al final de cada mes). 0 si el saldo ya alcanza. Con
  /// [meses] = 0 retorna todo lo que falta.
  static int cuotaMensual({
    required int objetivo,
    required int saldo,
    required num tasaEa,
    required int meses,
  }) {
    if (meses <= 0) return max(objetivo - saldo, 0);
    final falta =
        objetivo - valorFuturo(saldo: saldo, tasaEa: tasaEa, meses: meses);
    if (falta <= 0) return 0;
    final i = tasaMensual(tasaEa);
    if (i == 0) return (falta / meses).ceil();
    final factor = (pow(1 + i, meses) - 1) / i;
    return (falta / factor).ceil();
  }

  /// Ahorro estimado en [meses] meses: [saldo] con rendimiento más
  /// [aporteMensual] al final de cada mes, también con rendimiento.
  static int proyectar({
    required int saldo,
    required int aporteMensual,
    required num tasaEa,
    required int meses,
  }) {
    final inicial = valorFuturo(saldo: saldo, tasaEa: tasaEa, meses: meses);
    if (meses <= 0 || aporteMensual <= 0) return inicial;
    final i = tasaMensual(tasaEa);
    final factor = i == 0 ? meses : (pow(1 + i, meses) - 1) / i;
    return inicial + (aporteMensual * factor).round();
  }

  /// Tasa E.A. del conjunto de portafolios ponderada por su saldo. Si
  /// ninguno tiene saldo, el promedio simple.
  static double tasaPonderada(List<({int saldo, num tasaEa})> portafolios) {
    if (portafolios.isEmpty) return 0;
    final total = portafolios.fold<int>(0, (s, p) => s + max(p.saldo, 0));
    if (total == 0) {
      return portafolios.fold<double>(0, (s, p) => s + p.tasaEa) /
          portafolios.length;
    }
    return portafolios.fold<double>(
            0, (s, p) => s + p.tasaEa * max(p.saldo, 0)) /
        total;
  }
}
