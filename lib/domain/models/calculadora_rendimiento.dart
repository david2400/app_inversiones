import 'dart:math';

/// Proyección de rendimientos con tasa efectiva anual (E.A.), como la
/// expresan los bancos para CDT y cuentas remuneradas.
class CalculadoraRendimiento {
  CalculadoraRendimiento._();

  static const diasAnio = 365;

  /// Rendimiento estimado de [capital] a una tasa [tasaEa] en porcentaje
  /// (10 = 10 % E.A.) durante [dias] días. Redondeado al peso.
  static int rendimiento(
      {required int capital, required num tasaEa, required int dias}) {
    if (capital <= 0 || tasaEa <= 0 || dias <= 0) return 0;
    final factor = pow(1 + tasaEa / 100, dias / diasAnio) - 1;
    return (capital * factor).round();
  }

  /// Días entre [desde] y [hasta] contando solo fechas (sin horas).
  static int diasEntre(DateTime desde, DateTime hasta) =>
      DateTime(hasta.year, hasta.month, hasta.day)
          .difference(DateTime(desde.year, desde.month, desde.day))
          .inDays;
}
