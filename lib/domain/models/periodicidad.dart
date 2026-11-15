/// Cada cuánto se repite algo, en meses.
///
/// Se usa para:
/// - los rendimientos de un portafolio (un CDT puede pagar mensual,
///   trimestral... o al vencimiento);
/// - los movimientos fijos, incluidos los aportes programados.
///
/// Es una lista fija (no un catálogo editable): son los periodos que usan
/// bancos y fondos, y la app calcula fechas con ellos.
class Periodicidad {
  Periodicidad._();

  /// Solo para rendimientos: se pagan todos al final.
  static const alVencimiento = 0;
  static const mensual = 1;
  static const bimestral = 2;
  static const trimestral = 3;
  static const semestral = 6;
  static const anual = 12;

  /// Periodos válidos para algo que se repite (fijos y aportes).
  static const repetibles = [mensual, bimestral, trimestral, semestral, anual];

  /// Periodos válidos para el pago de rendimientos.
  static const deRendimientos = [...repetibles, alVencimiento];

  static bool esRepetible(int? meses) => repetibles.contains(meses);

  static bool esDeRendimientos(int? meses) => deRendimientos.contains(meses);

  /// Clave de traducción del nombre del periodo.
  static String clave(int meses) => switch (meses) {
        alVencimiento => 'per_al_vencimiento',
        mensual => 'per_mensual',
        bimestral => 'per_bimestral',
        trimestral => 'per_trimestral',
        semestral => 'per_semestral',
        anual => 'per_anual',
        _ => 'per_cada_n_meses',
      };

  /// Meses completos entre el mes de [desde] y el mes de [hasta]
  /// (negativo si [hasta] es anterior).
  static int mesesEntre(DateTime desde, DateTime hasta) =>
      (hasta.year - desde.year) * 12 + hasta.month - desde.month;

  /// Si algo que empezó en el mes de [inicio] y se repite cada [meses]
  /// toca en el mes de [mes].
  static bool tocaEnMes(
      {required DateTime inicio, required int meses, required DateTime mes}) {
    final transcurridos = mesesEntre(inicio, mes);
    if (transcurridos < 0) return false;
    if (meses <= mensual) return true;
    return transcurridos % meses == 0;
  }

  /// Primer mes, desde el mes de [desde] (incluido), en que toca algo que
  /// empezó en [inicio] y se repite cada [meses]. Retorna el día 1 de ese
  /// mes.
  static DateTime proximoMes(
      {required DateTime inicio, required int meses, required DateTime desde}) {
    var mes = DateTime(desde.year, desde.month);
    final primero = DateTime(inicio.year, inicio.month);
    if (mes.isBefore(primero)) return primero;
    while (!tocaEnMes(inicio: inicio, meses: meses, mes: mes)) {
      mes = DateTime(mes.year, mes.month + 1);
    }
    return mes;
  }
}
