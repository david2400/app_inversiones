import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:inversiones/config/migraciones.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/schema/frecuencia_pago_schema.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/proyecto_schema.dart';
import 'package:inversiones/domain/schema/tipo_proyecto_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/domain/schema/usuario_schema.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
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
        FrecuenciaPagoSchema(),
        MotivosSchema(),
        PortafolioSchema(),
        ProyectoSchema(),
        TipoProyectoSchema(),
        TipoTransaccionSchema(),
        TransferenciaShema(),
        UsuarioShema(),
      ];

  /// Permite a los tests inyectar una base de datos (por ejemplo en memoria
  /// con sqflite_common_ffi).
  @visibleForTesting
  static set baseDeDatosDePrueba(Database? db) => _database = db;

  // Obtener la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();

    if (!_database!.isOpen) {
      throw Exception("La conexión a la base de datos no está abierta.");
    }

    return _database!;
  }

  // Inicializar la base de datos
  Future<Database> _initDatabase() async {
    Directory pathDB = await getApplicationDocumentsDirectory();
    String path = join(pathDB.path, _databaseName);

    await _respaldarSiRequiereMigracion(path);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onConfigure(Database db) async {
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
    for (final indice in Migraciones.indices) {
      await db.execute(indice);
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
