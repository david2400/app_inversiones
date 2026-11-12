import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/config/migraciones.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// DDL de la tabla usuarios tal como existía en la versión 16.
const _usuariosV16 = 'CREATE TABLE usuarios ('
    'id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,'
    'nombre TEXT NULL,'
    'apellido TEXT NULL,'
    'motivo TEXT NULL,'
    'destino_alternativo TEXT NOT NULL,'
    'descripcion TEXT NOT NULL,'
    'created_at TEXT NOT NULL,'
    'updated_at TEXT NULL,'
    'deleted_at TEXT NULL)';

const _transferenciasV16 = 'CREATE TABLE transferencias ('
    'id_transferencia INTEGER PRIMARY KEY AUTOINCREMENT,'
    'valor INTEGER NOT NULL, impuesto INTEGER NULL,'
    'tipo_transferencia_id INTEGER NOT NULL, motivo_id INTEGER NULL,'
    'portafolio_id INTEGER NOT NULL, destino_cuenta INTEGER NULL,'
    'destino_alternativo TEXT NULL, descripcion TEXT NULL,'
    'created_at TEXT NOT NULL, updated_at TEXT NULL, deleted_at TEXT NULL)';

const _portafoliosV16 = 'CREATE TABLE portafolios ('
    'id_portafolio INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL,'
    'proyecto_id INTEGER NOT NULL, created_at TEXT NOT NULL,'
    'deleted_at TEXT NULL)';

void main() {
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute(_usuariosV16);
    await db.execute(_transferenciasV16);
    await db.execute(_portafoliosV16);
    await db.insert('usuarios', {
      'nombre': 'Ana',
      'motivo': '1990-01-01',
      'destino_alternativo': 'ana@correo.com',
      'descripcion': 'hash',
      'created_at': '2026-01-01 00:00:00',
    });
    await db.insert('transferencias', {
      'valor': 5000,
      'tipo_transferencia_id': 1,
      'portafolio_id': 1,
      'created_at': '2026-01-01 00:00:00',
    });
  });

  tearDown(() => db.close());

  test('16 -> 17 conserva los datos y corrige columnas de usuarios', () async {
    await db.transaction(
        (txn) => Migraciones.migrar(txn, 16, Migraciones.versionActual));

    final usuarios = await db.query('usuarios');
    expect(usuarios, hasLength(1));
    expect(usuarios.first['fecha_nacimiento'], '1990-01-01');
    expect(usuarios.first['email'], 'ana@correo.com');
    expect(usuarios.first['password'], 'hash');

    final transferencias = await db.query('transferencias');
    expect(transferencias, hasLength(1));
  });

  test('17 crea los índices', () async {
    await db.transaction((txn) => Migraciones.migrar(txn, 16, 17));
    final indices = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'");
    expect(indices.length, Migraciones.indices.length);
  });

  test('falla si no hay migración para la versión pedida', () async {
    await expectLater(
        () => db.transaction((txn) => Migraciones.migrar(txn, 17, 18)),
        throwsStateError);
  });
}
