import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/infraestructure/handler/implementations/exportacion_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/exportacion_interface.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late Directory carpeta;
  final exportacion = ExportacionHandler();

  setUp(() async {
    await base.abrir();
    carpeta = await Directory.systemTemp.createTemp('inversiones_csv');

    final ingreso = await base.crearTipo('Salario', TipoFuente.ingreso);
    final egreso = await base.crearTipo('Pago', TipoFuente.egreso);
    final cuenta = await base.crearPortafolio('Ahorros; principal', 'N');

    Future<void> registrar(int tipo, int valor, String fecha,
            {String? descripcion}) =>
        TransaccionHandler().createTransaccion(TransaccionDto(
            valor: valor,
            tipoTransferenciaId: tipo,
            portafolioId: cuenta,
            descripcion: descripcion,
            createdAt: '$fecha 08:00:00'));

    await registrar(ingreso, 1000000, '2026-10-01');
    await registrar(egreso, 250000, '2026-11-10', descripcion: 'Arriendo');
  });

  tearDown(() async {
    await base.cerrar();
    await carpeta.delete(recursive: true);
  });

  Future<List<String>> exportar(PeriodoExportacion periodo) async {
    final ruta = await exportacion.exportarMovimientosCsv(
        directorio: carpeta.path,
        periodo: periodo,
        fecha: DateTime(2026, 11, 15));
    final bytes = await File(ruta).readAsBytes();
    // El archivo debe empezar con el BOM UTF-8 (EF BB BF) para Excel.
    expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
    return utf8
        .decode(bytes.skip(3).toList())
        .split('\r\n')
        .where((l) => l.isNotEmpty)
        .toList();
  }

  test('exporta todos los movimientos con encabezados y GMF', () async {
    final lineas = await exportar(PeriodoExportacion.todo);
    expect(lineas.first, ExportacionHandler.encabezados.join(';'));
    expect(lineas, hasLength(3));
    expect(lineas[1], contains('Ingreso'));
    expect(lineas[1], contains('"Ahorros; principal"'));
    // Egreso de 250.000 con GMF de 1.000 -> total debitado 251.000
    expect(lineas[2], contains(';250000;1000;251000;Arriendo'));
  });

  test('filtra por mes actual', () async {
    final lineas = await exportar(PeriodoExportacion.mesActual);
    expect(lineas, hasLength(2));
    expect(lineas[1], contains('Egreso'));
  });
}
