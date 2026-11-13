import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/config/migraciones.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
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

const _motivosV16 = 'CREATE TABLE motivos ('
    'id_motivo INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL,'
    'descripcion TEXT NULL, created_at TEXT NOT NULL, deleted_at TEXT NULL)';

const _tiposV16 = 'CREATE TABLE tipo_transferencia ('
    'id_tipo_transaccion INTEGER PRIMARY KEY AUTOINCREMENT,'
    'nombre TEXT NOT NULL, descripcion TEXT NULL, tipo_fuente TEXT NOT NULL,'
    'created_at TEXT NOT NULL, deleted_at TEXT NULL)';

const _portafoliosV16 = 'CREATE TABLE portafolios ('
    'id_portafolio INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL,'
    'nro_cuenta TEXT NULL, tipo_renta INTEGER NOT NULL,'
    'proyecto_id INTEGER NOT NULL, tipo_portafolio_id INTEGER NOT NULL,'
    'interes INTEGER NOT NULL, total INTEGER NULL, exenta_impuesto TEXT NULL,'
    'frecuencia_pago_id INTEGER NOT NULL, descripcion TEXT NULL,'
    'created_at TEXT NOT NULL, updated_at TEXT NULL, deleted_at TEXT NULL)';

Map<String, Object?> _portafolio(String nombre) => {
      'nombre': nombre,
      'tipo_renta': 'F',
      'proyecto_id': 1,
      'tipo_portafolio_id': 1,
      'interes': 5,
      'frecuencia_pago_id': 1,
      'exenta_impuesto': 'N',
      'created_at': '2026-01-01',
    };

const _proyectosV16 = 'CREATE TABLE proyectos ('
    'id_proyecto INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL,'
    'usuario_id INTEGER NOT NULL, descripcion TEXT NULL,'
    'created_at TEXT NOT NULL, updated_at TEXT NULL, deleted_at TEXT NULL)';

const _tipoProyectoV16 = 'CREATE TABLE tipo_proyecto ('
    'id_tipo_proyecto INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT NOT NULL,'
    'descripcion TEXT NULL, created_at TEXT NOT NULL, updated_at TEXT NULL,'
    'deleted_at TEXT NULL)';

Future<List<String>> _columnas(Database db, String tabla) async =>
    (await db.rawQuery('PRAGMA table_info($tabla)'))
        .map((c) => c['name'] as String)
        .toList();

void main() {
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute(_usuariosV16);
    await db.execute(_transferenciasV16);
    await db.execute(_portafoliosV16);
    await db.execute(_motivosV16);
    await db.execute(_tiposV16);
    await db.execute(_proyectosV16);
    await db.execute(_tipoProyectoV16);
    await db.insert('portafolios', _portafolio('Ahorros'));
    await db.insert('tipo_transferencia',
        {'nombre': 'Ingreso', 'tipo_fuente': 'I', 'created_at': '2026-01-01'});
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
      'motivo_id': 0, // referencia inválida que dejaba el formulario
      'created_at': '2026-01-01 00:00:00',
    });
    // Movimiento de un portafolio borrado físicamente en versiones previas.
    await db.insert('transferencias', {
      'valor': 700,
      'tipo_transferencia_id': 1,
      'portafolio_id': 99,
      'created_at': '2026-01-02 00:00:00',
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
    // v23 elimina la contraseña en texto plano.
    expect(usuarios.first.containsKey('password'), isFalse);

    final transferencias = await db.query('transferencias');
    expect(transferencias, hasLength(1));
    expect(transferencias.first['motivo_id'], isNull);

    // El huérfano se conserva aparte, no se pierde.
    final huerfanas = await db.query(Migraciones.tablaHuerfanas);
    expect(huerfanas.single['valor'], 700);
  });

  test('18 impone llaves foráneas en transferencias', () async {
    await db.transaction(
        (txn) => Migraciones.migrar(txn, 16, Migraciones.versionActual));
    await db.execute('PRAGMA foreign_keys = ON');

    await expectLater(
        () => db.insert('transferencias', {
              'valor': 1,
              'tipo_transferencia_id': 1,
              'portafolio_id': 12345,
              'created_at': '2026-01-03 00:00:00',
            }),
        throwsA(isA<DatabaseException>()));
  });

  test('19 agrega terceros y tercero_id en transferencias', () async {
    await db.transaction(
        (txn) => Migraciones.migrar(txn, 16, Migraciones.versionActual));

    final columnas = await db.rawQuery('PRAGMA table_info(transferencias)');
    expect(columnas.map((c) => c['name']), contains('tercero_id'));

    final id = await db.insert('terceros',
        {'nombre': 'Empresa XYZ', 'created_at': '2026-01-01 00:00:00'});
    expect(id, greaterThan(0));
  });

  test('20 crea catálogos base solo si están vacíos', () async {
    await db.transaction(
        (txn) => Migraciones.migrar(txn, 16, Migraciones.versionActual));

    // tipo_transferencia ya tenía datos: no se agregan tipos base.
    final tipos = await db.query('tipo_transferencia');
    expect(tipos, hasLength(1));

    // motivos estaba vacía: se crean los motivos base.
    final motivos = await db.query('motivos');
    expect(motivos.map((m) => m['nombre']), containsAll(['Salario', 'Mercado']));
  });

  test('instalación nueva trae tipos y motivos base', () async {
    // Otra base en memoria independiente de la del setUp.
    final nueva = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false));
    await DatabaseHelper.crearEsquema(nueva);
    final tipos = await nueva.query('tipo_transferencia', orderBy: 'id_tipo_transaccion');
    expect(tipos.map((t) => t['tipo_fuente']), ['I', 'E', 'M']);
    expect((await nueva.query('motivos')).length, greaterThan(10));
    await nueva.close();
  });

  test('17 crea los índices', () async {
    await db.transaction((txn) => Migraciones.migrar(txn, 16, 17));
    final indices = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'");
    expect(indices.length, Migraciones.indices.length);
  });

  test('falla si no hay migración para la versión pedida', () async {
    await expectLater(
        () => db.transaction((txn) => Migraciones.migrar(
            txn, Migraciones.versionActual, Migraciones.versionActual + 1)),
        throwsStateError);
  });

  test('24 crea cuentas con "Efectivo / Sin definir" y conserva los movimientos',
      () async {
    await db.transaction(
        (txn) => Migraciones.migrar(txn, 16, 24));

    final cuentas = await db.query('cuentas');
    expect(cuentas, hasLength(1));
    expect(cuentas.single['id_cuenta'], 1);
    expect(cuentas.single['tipo_cuenta'], 'E');
    expect(cuentas.single['exenta_impuesto'], 'S');

    final transferencias = await db.query('transferencias');
    expect(transferencias.single['portafolio_id'], 1);
    expect(transferencias.single['cuenta_id'], isNull);
    expect(transferencias.single['valor'], 5000);

    expect(await _columnas(db, 'transferencias'),
        containsAll(['cuenta_id', 'cuenta_destino_id', 'tercero_id', 'recurrente_id']));
    expect(await _columnas(db, 'recurrentes'),
        containsAll(['cuenta_id', 'cuenta_destino_id']));
    expect(await _columnas(db, 'portafolios'), contains('cuenta_destino_id'));
    expect(await _columnas(db, 'proyectos'), contains('tipo_proyecto_id'));
    expect(await _columnas(db, 'presupuestos'), contains('cuenta_id'));
  });

  test('24 exige exactamente un origen: inversión o cuenta', () async {
    await db.transaction(
        (txn) => Migraciones.migrar(txn, 16, 24));

    Map<String, Object?> movimiento(int? portafolio, int? cuenta) => {
          'valor': 100,
          'tipo_transferencia_id': 1,
          'portafolio_id': portafolio,
          'cuenta_id': cuenta,
          'created_at': '2026-02-01 00:00:00',
        };

    // Sin origen y con dos orígenes: rechazados.
    await expectLater(() => db.insert('transferencias', movimiento(null, null)),
        throwsA(isA<DatabaseException>()));
    await expectLater(() => db.insert('transferencias', movimiento(1, 1)),
        throwsA(isA<DatabaseException>()));

    // Desde una cuenta, o desde una inversión: válidos.
    expect(await db.insert('transferencias', movimiento(null, 1)), greaterThan(0));
    expect(await db.insert('transferencias', movimiento(1, null)), greaterThan(0));

    // No puede llegar a una inversión y a una cuenta a la vez.
    await expectLater(
        () => db.insert('transferencias', {
              ...movimiento(null, 1),
              'destino_cuenta': 1,
              'cuenta_destino_id': 1,
            }),
        throwsA(isA<DatabaseException>()));
  });

  test('24 recrea todos los índices de transferencias', () async {
    await db.transaction(
        (txn) => Migraciones.migrar(txn, 16, 24));
    final indices = (await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'"))
        .map((i) => i['name'])
        .toList();
    expect(
        indices,
        containsAll([
          'idx_transferencias_portafolio',
          'idx_transferencias_tercero',
          'idx_transferencias_recurrente',
          'idx_transferencias_portafolio_fecha',
          'idx_transferencias_cuenta',
          'idx_transferencias_cuenta_destino',
        ]));
  });

  test('23 -> 24 funciona con llaves foráneas activas y fijos vinculados',
      () async {
    final conFk = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false));
    for (final ddl in [
      _usuariosV16,
      _transferenciasV16,
      _portafoliosV16,
      _motivosV16,
      _tiposV16,
      _proyectosV16,
      _tipoProyectoV16,
    ]) {
      await conFk.execute(ddl);
    }
    await conFk.transaction((txn) => Migraciones.migrar(txn, 16, 23));
    await conFk.execute('PRAGMA foreign_keys = ON');

    await conFk.insert('portafolios', _portafolio('CDT'));
    await conFk.insert('tipo_transferencia',
        {'nombre': 'Ingreso', 'tipo_fuente': 'I', 'created_at': '2026-01-01'});
    final idFijo = await conFk.insert('recurrentes', {
      'nombre': 'Arriendo',
      'tipo_transferencia_id': 1,
      'portafolio_id': 1,
      'valor': 900,
      'dia_mes': 5,
      'created_at': '2026-01-01',
    });
    await conFk.insert('transferencias', {
      'valor': 900,
      'tipo_transferencia_id': 1,
      'portafolio_id': 1,
      'recurrente_id': idFijo,
      'created_at': '2026-01-05 00:00:00',
    });

    await conFk.transaction((txn) => Migraciones.migrar(txn, 23, 24));

    final movimiento = (await conFk.query('transferencias')).single;
    expect(movimiento['recurrente_id'], idFijo);
    expect((await conFk.query('recurrentes')).single['nombre'], 'Arriendo');
    expect(await conFk.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    await conFk.close();
  });

  test('instalación nueva trae la cuenta "Efectivo / Sin definir" con id 1',
      () async {
    final nueva = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false));
    await DatabaseHelper.crearEsquema(nueva);
    final cuentas = await nueva.query('cuentas');
    expect(cuentas.single['id_cuenta'], CuentaSchema.idEfectivo);
    expect(cuentas.single['tipo_cuenta'], TipoCuenta.efectivo);
    final principal = await nueva.query('portafolios',
        where: 'cuenta_id = ? AND es_principal = 1',
        whereArgs: [CuentaSchema.idEfectivo]);
    expect(principal, hasLength(1));
    await nueva.close();
  });

  test('25: cada portafolio es de una cuenta o de un proyecto; Efectivo tiene su principal',
      () async {
    await db.transaction(
        (txn) => Migraciones.migrar(txn, 16, Migraciones.versionActual));

    final portafolios = await db.query('portafolios', orderBy: 'id_portafolio');
    expect(portafolios, hasLength(2));
    expect(portafolios[0]['nombre'], 'Ahorros');
    expect(portafolios[0]['proyecto_id'], 1);
    expect(portafolios[0]['cuenta_id'], isNull);
    expect(portafolios[0]['interes'], 5);
    expect(portafolios[1]['cuenta_id'], CuentaSchema.idEfectivo);
    expect(portafolios[1]['es_principal'], 1);
    expect(portafolios[1]['proyecto_id'], isNull);

    // Movimientos de nuevo solo entre portafolios.
    expect(await _columnas(db, 'transferencias'), isNot(contains('cuenta_id')));
    expect(await _columnas(db, 'recurrentes'), isNot(contains('cuenta_id')));
    expect((await db.query('transferencias')).single['valor'], 5000);

    // Sin cuenta ni proyecto, o con ambos: rechazado.
    await expectLater(
        () => db.insert('portafolios', {'nombre': 'X', 'created_at': '2026-01-01'}),
        throwsA(isA<DatabaseException>()));
    await expectLater(
        () => db.insert('portafolios', {
              'nombre': 'X',
              'proyecto_id': 1,
              'cuenta_id': 1,
              'created_at': '2026-01-01',
            }),
        throwsA(isA<DatabaseException>()));
    // Un segundo principal para la misma cuenta: rechazado.
    await expectLater(
        () => db.insert('portafolios', {
              'nombre': 'Otro',
              'cuenta_id': 1,
              'es_principal': 1,
              'created_at': '2026-01-01',
            }),
        throwsA(isA<DatabaseException>()));
    // Una cajita o CDT dentro de la cuenta: válido.
    expect(
        await db.insert('portafolios',
            {'nombre': 'Cajita', 'cuenta_id': 1, 'created_at': '2026-01-01'}),
        greaterThan(0));
  });

  test('24 -> 25 pasa a portafolios los movimientos que usaban cuentas',
      () async {
    await db.transaction((txn) => Migraciones.migrar(txn, 16, 24));
    await db.insert('transferencias', {
      'valor': 77,
      'tipo_transferencia_id': 1,
      'cuenta_id': 1,
      'destino_cuenta': 1,
      'created_at': '2026-02-01 00:00:00',
    });
    await db.transaction((txn) => Migraciones.migrar(txn, 24, 25));

    final principal = (await db.query('portafolios',
            where: 'cuenta_id = 1 AND es_principal = 1'))
        .single['id_portafolio'];
    final movimiento =
        (await db.query('transferencias', where: 'valor = 77')).single;
    expect(movimiento['portafolio_id'], principal);
    expect(movimiento['destino_cuenta'], 1);
    expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
  });

  test('26: tarjetas y préstamos como cuentas, con sus condiciones', () async {
    await db.transaction(
        (txn) => Migraciones.migrar(txn, 16, Migraciones.versionActual));

    final id = await db.insert('cuentas', {
      'nombre': 'Visa',
      'tipo_cuenta': 'T',
      'created_at': '2026-01-01',
    });
    await db.insert('condiciones_credito', {
      'id_cuenta': id,
      'cupo': 5000000,
      'tasa_mensual': 1850,
      'created_at': '2026-01-01',
    });
    await expectLater(
        () => db.insert('cuentas',
            {'nombre': 'X', 'tipo_cuenta': 'Z', 'created_at': '2026-01-01'}),
        throwsA(isA<DatabaseException>()));
    expect(await _columnas(db, 'transferencias'), contains('numero_cuotas'));
    expect(await _columnas(db, 'recurrentes'), contains('automatico'));
    // La cuenta Efectivo se conserva al reconstruir la tabla.
    expect((await db.query('cuentas', where: 'id_cuenta = 1')).single['tipo_cuenta'], 'E');
  });
}
