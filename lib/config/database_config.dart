import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:inversiones/config/migraciones.dart';
import 'package:inversiones/config/registro.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/schema/condiciones_credito_schema.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/domain/schema/frecuencia_pago_schema.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/presupuesto_schema.dart';
import 'package:inversiones/domain/schema/recurrente_schema.dart';
import 'package:inversiones/domain/schema/proyecto_schema.dart';
import 'package:inversiones/domain/schema/tipo_proyecto_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/domain/schema/tercero_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/domain/schema/usuario_schema.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show sqfliteFfiInit, databaseFactoryFfi;
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper._();
  static Database? _database;
  static const _databaseName = "inversiones.db";
  static const _databaseVersion = Migraciones.versionActual;
  static const _extensionRespaldo = '.bak';

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  DatabaseHelper._();

  /// Tablas del esquema actual, en orden de creación.
  static List<TableAbstract> get _tablas => [
        CuentaSchema(),
        FrecuenciaPagoSchema(),
        MotivosSchema(),
        PortafolioSchema(),
        ProyectoSchema(),
        TipoProyectoSchema(),
        TipoTransaccionSchema(),
        TerceroSchema(),
        TransferenciaShema(),
        UsuarioShema(),
        PresupuestoSchema(),
        RecurrenteSchema(),
        CondicionesCreditoSchema(),
      ];

  /// En Windows y Linux el plugin sqflite no tiene implementación nativa:
  /// se usa SQLite vía FFI. Debe llamarse una vez al iniciar la app.
  static void inicializarPlataforma() {
    if (kIsWeb) return;
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Permite a los tests inyectar una base de datos (por ejemplo en memoria
  /// con sqflite_common_ffi).
  @visibleForTesting
  static set baseDeDatosDePrueba(Database? db) => _database = db;

  /// Clave de zona donde vive la transacción activa (ver [enTransaccion]).
  static const _zonaTransaccion = #inversionesTransaccion;

  /// Ejecutor para las consultas: la transacción en curso si la hay, o la
  /// base de datos. Los schemas siempre deben usar este getter.
  Future<DatabaseExecutor> get ejecutor async =>
      (Zone.current[_zonaTransaccion] as DatabaseExecutor?) ?? await database;

  /// Ejecuta [accion] dentro de una transacción: si algo falla, se revierte
  /// todo. Las llamadas anidadas reutilizan la transacción externa.
  Future<T> enTransaccion<T>(Future<T> Function() accion) async {
    if (Zone.current[_zonaTransaccion] != null) return accion();
    final db = await database;
    return db.transaction((txn) =>
        runZoned(accion, zoneValues: {_zonaTransaccion: txn}));
  }

  // Obtener la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();

    if (!_database!.isOpen) {
      throw Exception("La conexión a la base de datos no está abierta.");
    }

    return _database!;
  }

  /// Ruta del archivo en los tests (evita depender de path_provider).
  @visibleForTesting
  static String? rutaDePrueba;

  /// Ruta completa del archivo `inversiones.db` en este dispositivo.
  Future<String> rutaArchivo() async {
    if (rutaDePrueba != null) return rutaDePrueba!;
    Directory pathDB = await getApplicationDocumentsDirectory();
    return join(pathDB.path, _databaseName);
  }

  /// Cierra la conexión; el siguiente acceso a [database] la reabre
  /// (y aplica migraciones si el archivo es de una versión anterior).
  Future<void> cerrar() async {
    final db = _database;
    _database = null;
    if (db != null && db.isOpen) await db.close();
  }

  // Inicializar la base de datos
  Future<Database> _initDatabase() async {
    String path = await rutaArchivo();

    await _respaldarSiRequiereMigracion(path);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onOpen: _onOpen,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Las llaves foráneas se desactivan mientras se crea o migra el esquema
  /// (procedimiento recomendado por SQLite para reconstruir tablas padre) y
  /// se activan al abrir, antes de cualquier consulta de la app.
  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = OFF');
  }

  static Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Crea el esquema completo en una instalación nueva.
  static Future<void> _onCreate(Database db, int version) =>
      crearEsquema(db);

  /// Crea todas las tablas e índices del esquema actual.
  static Future<void> crearEsquema(DatabaseExecutor db) async {
    for (final tabla in _tablas) {
      await db.execute(tabla.createTableQuery());
    }
    for (final indice in Migraciones.indicesActuales) {
      await db.execute(indice);
    }
    for (final sentencia in [
      ...Migraciones.datosIniciales,
      ...Migraciones.datosInicialesV24,
      ...Migraciones.datosInicialesV25,
    ]) {
      await db.execute(sentencia);
    }
  }

  /// Migra de forma incremental y no destructiva.
  static Future<void> _onUpgrade(
      Database db, int versionAnterior, int versionNueva) async {
    if (versionAnterior < Migraciones.versionMinimaMigrable) {
      // Versiones muy antiguas sin historial de migraciones: se recrean.
      for (final tabla in _tablas) {
        await db.execute(tabla.dropTableQuery());
      }
      await crearEsquema(db);
      return;
    }
    await Migraciones.migrar(db, versionAnterior, versionNueva);
    final violaciones = await db.rawQuery('PRAGMA foreign_key_check');
    if (violaciones.isNotEmpty) {
      Registro.info('Migración a v$versionNueva: ${violaciones.length} '
          'referencias inválidas heredadas: $violaciones');
    }
  }

  /// Antes de migrar, copia el archivo de la base de datos para poder
  /// recuperarlo si algo sale mal.
  Future<void> _respaldarSiRequiereMigracion(String path) async {
    final archivo = File(path);
    if (!await archivo.exists()) return;

    final db = await openDatabase(path, readOnly: true);
    final versionActual = await db.getVersion();
    await db.close();

    if (versionActual > 0 && versionActual < _databaseVersion) {
      final marca = DateTime.now().millisecondsSinceEpoch;
      await archivo.copy('$path.v$versionActual.$marca$_extensionRespaldo');
    }
  }
}
