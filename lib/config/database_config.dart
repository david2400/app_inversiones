import 'dart:async';
import 'dart:io';

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
  static const _databaseVersion = 16;

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  DatabaseHelper._();


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

    return await openDatabase(
      path,
      version: _databaseVersion,
      onOpen: (db) {},
      onCreate: _onCreate,
      onUpgrade: (db, olVersion, newVersion) async {
        if (olVersion < newVersion) {
          await _onCreate(db, newVersion);
        }
      },
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    TableAbstract tableAbstract = FrecuenciaPagoSchema();
    await _executeDb(tableAbstract, db);

    tableAbstract = MotivosSchema();
    await _executeDb(tableAbstract, db);

    tableAbstract = PortafolioSchema();
    await _executeDb(tableAbstract, db);

    tableAbstract = ProyectoSchema();
    await _executeDb(tableAbstract, db);

    tableAbstract = TipoProyectoSchema();
    await _executeDb(tableAbstract, db);

    tableAbstract = TipoTransaccionSchema();
    await _executeDb(tableAbstract, db);

    tableAbstract = TransferenciaShema();
    await _executeDb(tableAbstract, db);

    tableAbstract = UsuarioShema();
    await _executeDb(tableAbstract, db);
  }

  _executeDb(TableAbstract tableAbstract, Database db) async {
    await db.execute(tableAbstract.dropTableQuery());
    await db.execute(tableAbstract.createTableQuery());
  }
}
