import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';

// El test por defecto del contador se reemplazó: la app no tiene contador y
// requiere base de datos. Las pruebas de negocio viven en test/domain,
// test/config y test/handler.
void main() {
  test('TipoFuente reconoce solo los códigos válidos', () {
    expect(TipoFuente.esValido(TipoFuente.ingreso), isTrue);
    expect(TipoFuente.esValido('X'), isFalse);
    expect(TipoFuente.debitaOrigen(TipoFuente.ingreso), isFalse);
    expect(TipoFuente.debitaOrigen(TipoFuente.egreso), isTrue);
  });
}
