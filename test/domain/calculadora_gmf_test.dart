import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/calculadora_gmf.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';

void main() {
  group('CalculadoraGmf', () {
    test('egreso de portafolio gravado paga 4 por mil', () {
      expect(
          CalculadoraGmf.calcular(
              valor: 1000000,
              tipoFuente: TipoFuente.egreso,
              exentaImpuesto: 'N'),
          4000);
    });

    test('transferencia de portafolio gravado paga 4 por mil', () {
      expect(
          CalculadoraGmf.calcular(
              valor: 250000,
              tipoFuente: TipoFuente.transferencia,
              exentaImpuesto: 'N'),
          1000);
    });

    test('redondea al peso más cercano', () {
      expect(
          CalculadoraGmf.calcular(
              valor: 1125, tipoFuente: TipoFuente.egreso, exentaImpuesto: 'N'),
          5); // 4.5 -> 5
    });

    test('ingresos no pagan GMF', () {
      expect(
          CalculadoraGmf.calcular(
              valor: 1000000,
              tipoFuente: TipoFuente.ingreso,
              exentaImpuesto: 'N'),
          0);
    });

    test('portafolio exento o sin dato no paga GMF', () {
      for (final exenta in ['S', null]) {
        expect(
            CalculadoraGmf.calcular(
                valor: 1000000,
                tipoFuente: TipoFuente.egreso,
                exentaImpuesto: exenta),
            0);
      }
    });
  });
}
