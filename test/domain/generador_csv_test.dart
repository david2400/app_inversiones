import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/generador_csv.dart';

void main() {
  test('incluye BOM, separador ; y fin de línea CRLF', () {
    final csv = GeneradorCsv.generar(['A', 'B'], [
      [1, 'x'],
    ]);
    expect(csv, '﻿A;B\r\n1;x\r\n');
  });

  test('escapa separadores, comillas y saltos de línea; null es vacío', () {
    final csv = GeneradorCsv.generar(['C'], [
      ['con;punto y coma'],
      ['dice "hola"'],
      ['dos\nlíneas'],
      [null],
    ]);
    final lineas = csv.substring(1).split('\r\n');
    expect(lineas[1], '"con;punto y coma"');
    expect(lineas[2], '"dice ""hola"""');
    expect(lineas[3], '"dos\nlíneas"');
    expect(lineas[4], '');
  });
}
