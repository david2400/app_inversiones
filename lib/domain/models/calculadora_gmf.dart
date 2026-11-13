import 'package:inversiones/domain/models/tipo_fuente.dart';

/// Cálculo del Gravamen a los Movimientos Financieros (4x1000) de Colombia.
///
/// El GMF grava los débitos: aplica a egresos y transferencias que salen de
/// un portafolio no exento. Los ingresos no generan GMF.
class CalculadoraGmf {
  static const tasaPorMil = 4;
  static const divisor = 1000;

  /// Valor de `exenta_impuesto` que indica que el portafolio SÍ paga GMF.
  static const portafolioGravado = 'N';

  CalculadoraGmf._();

  static bool esGravado(String? exentaImpuesto) =>
      exentaImpuesto == portafolioGravado;

  /// Retorna el GMF en pesos (redondeado al entero más cercano).
  static int calcular({
    required int valor,
    required String tipoFuente,
    required String? exentaImpuesto,
  }) {
    if (valor <= 0 ||
        !TipoFuente.debitaOrigen(tipoFuente) ||
        !esGravado(exentaImpuesto)) {
      return 0;
    }
    return (valor * tasaPorMil / divisor).round();
  }
}
