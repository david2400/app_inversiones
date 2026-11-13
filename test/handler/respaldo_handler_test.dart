import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/entity/portafolio_entity.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/respaldo_impl.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory carpeta;
  final respaldo = RespaldoHandler();

  Future<void> crearPortafolio(String nombre) => PortafolioSchema().insert(
      Portafolio(
          nombre: nombre,
          tipoRenta: 'F',
          proyectoId: 1,
          tipoPortafolioId: 1,
          interes: 0,
          exentaImpuesto: 'S',
          frecuenciaPagoId: 1));

  Future<int> contarPortafolios() async =>
      (await PortafolioSchema().getAll()).length;

  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    carpeta = await Directory.systemTemp.createTemp('inversiones_test');
    DatabaseHelper.rutaDePrueba = join(carpeta.path, 'inversiones.db');
    await DatabaseHelper().cerrar();
  });

  tearDown(() async {
    await DatabaseHelper().cerrar();
    DatabaseHelper.rutaDePrueba = null;
    await carpeta.delete(recursive: true);
  });

  test('exporta y restaura los datos, guardando copia de seguridad', () async {
    await crearPortafolio('A');
    final archivo = await respaldo.exportar(carpeta.path);
    expect(File(archivo).existsSync(), isTrue);

    await crearPortafolio('B');
    expect(await contarPortafolios(), 2);

    await respaldo.restaurar(archivo);
    expect(await contarPortafolios(), 1);

    final copias = carpeta
        .listSync()
        .where((f) => f.path.contains(RespaldoHandler.sufijoSeguridad));
    expect(copias, hasLength(1));
  });

  test('rechaza un archivo que no es base de datos y conserva los datos',
      () async {
    await crearPortafolio('A');
    final falso = File(join(carpeta.path, 'falso.db'))
      ..writeAsStringSync('esto no es sqlite');

    await expectLater(() => respaldo.restaurar(falso.path), throwsException);
    expect(await contarPortafolios(), 1);
  });

  test('rechaza un respaldo de una versión más nueva', () async {
    final futuro = join(carpeta.path, 'futuro.db');
    final db = await databaseFactoryFfi.openDatabase(futuro,
        options: OpenDatabaseOptions(
          version: 999,
          onCreate: (db, _) => DatabaseHelper.crearEsquema(db),
        ));
    await db.close();

    await expectLater(() => respaldo.restaurar(futuro), throwsException);
  });
}
