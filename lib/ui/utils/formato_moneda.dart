import 'package:intl/intl.dart';

/// Formato de valores monetarios en pesos colombianos.
class FormatoMoneda {
  static const _locale = 'es_CO';
  static const _simbolo = '\$';

  static final NumberFormat _cop = NumberFormat.currency(
      locale: _locale, symbol: _simbolo, decimalDigits: 0,
      customPattern: '¤ #,##0');

  static final NumberFormat _compacto =
      NumberFormat.compactCurrency(locale: _locale, symbol: _simbolo);

  FormatoMoneda._();

  /// Ejemplo: `$ 1.250.000`.
  static String cop(num valor) => _cop.format(valor);

  /// Ejemplo: `$1,3 M`. Para ejes y espacios reducidos.
  static String compacto(num valor) => _compacto.format(valor);
}
