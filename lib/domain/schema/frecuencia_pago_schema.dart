import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/entity/frecuencia_pago_entity.dart';

class FrecuenciaPagoSchema implements TableAbstract {
  static const table = 'frecuencia_pagos';

  static const idFrecuenciaPago = "id_frecuencia_pago";
  static const tiempo = "tiempo";
  static const formato = "formato";
  static const createdAt = "created_at";
  static const updatedAt = "updated_at";
  static const deletedAt = "deleted_at";

  final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  final intType = 'INTEGER NOT NULL';
  final intTypeNull = 'INTEGER NULL';
  final textType = 'TEXT NOT NULL';
  final textTypeNull = 'TEXT NULL';
  final doubleType = 'REAL NOT NULL';

  @override
  String createTableQuery() {
    return "CREATE TABLE $table ("
        "$idFrecuenciaPago $idType,"
        "$tiempo $intType,"
        "$formato $textType,"
        "$createdAt $textType,"
        "$updatedAt $textTypeNull,"
        "$deletedAt $textTypeNull"
      ")";
  }

  @override
  Future<int> deleteAll() async {
    final db = await DatabaseHelper().database;
    final result = await db.rawDelete('''
      DELETE FROM $table
    ''');
    return result;
  }

  @override
  String dropTableQuery() {
    return "DROP TABLE IF EXISTS $table";
  }

  @override
  Future<List<FrecuenciaPago>> getAll() async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table, where: Auditoria.filtroActivo);

    return result.isNotEmpty
        ? result.map((e) => FrecuenciaPago.fromJson(e)).toList()
        : [];
  }

  @override
  Future<FrecuenciaPago?> getById(int idT) async {
    final db = await DatabaseHelper().database;
    final result =
        await db.query(table, where: "$idFrecuenciaPago = ? AND ${Auditoria.filtroActivo}", whereArgs: [idT]);
    return result.isNotEmpty ? FrecuenciaPago.fromJson(result.first) : null;
  }

  @override
  Future<int> update(object) async {
    FrecuenciaPago frecuenciaPagoModel = object as FrecuenciaPago;

    final db = await DatabaseHelper().database;
    final result = await db.update(
      table,
      Auditoria.datosActualizacion(frecuenciaPagoModel.toJson()),
      where: '$idFrecuenciaPago = ?',
      whereArgs: [frecuenciaPagoModel.idFrecuenciaPago!],
    );

    return result;
  }

  @override
  Future<int> insert(object) async {
    FrecuenciaPago frecuenciaPagoModel = object as FrecuenciaPago;

    final db = await DatabaseHelper().database;
    final result = await db.insert(table, Auditoria.datosCreacion(frecuenciaPagoModel.toJson()));

    return result;
  }

  @override
  Future<int> insertAll(List object) async {
    int result = 0;

    await deleteAll();
    for (var element in object) {
      result += await insert(element);
    }
    return result;
  }

  @override
  Future<int> deleteById(int idTable) async {
    final db = await DatabaseHelper().database;
    final result = await Auditoria.borradoLogico(db, table, idFrecuenciaPago, idTable);

    return result;
  }
}
