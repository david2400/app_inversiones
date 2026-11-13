import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/entity/tipo_transaccion_entity.dart';

class TipoTransaccionSchema implements TableAbstract {
  static const table = 'tipo_transferencia';

  static const idTipoTransaccion = "id_tipo_transaccion";
  static const nombre = "nombre";
  static const descripcion = "descripcion";
  static const tipoFuente = "tipo_fuente";
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
        "$idTipoTransaccion $idType,"
        "$nombre $textType,"
        "$descripcion $textTypeNull,"
        "$tipoFuente $textType,"
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
  Future<List<TipoTransaccion>> getAll() async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table, where: Auditoria.filtroActivo);

    return result.isNotEmpty
        ? result.map((e) => TipoTransaccion.fromJson(e)).toList()
        : [];
  }

  @override
  Future<TipoTransaccion?> getById(int idT) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table, where: "$idTipoTransaccion = ? AND ${Auditoria.filtroActivo}", whereArgs: [idT]);
    return result.isNotEmpty ? TipoTransaccion.fromJson(result.first) : null;
  }

  @override
  Future<int> update(object) async {
    TipoTransaccion tipoTransaccionModel = object as TipoTransaccion;

    final db = await DatabaseHelper().database;
    final result = await db.update(
      table,
      Auditoria.datosActualizacion(tipoTransaccionModel.toJson()),
      where: '$idTipoTransaccion = ?',
      whereArgs: [tipoTransaccionModel.idTipoTransaccion!],
    );

    return result;
  }

  @override
  Future<int> insert(object) async {
    TipoTransaccion TipoTransaccionModel = object as TipoTransaccion;

    final db = await DatabaseHelper().database;
    final result = await db.insert(table, Auditoria.datosCreacion(TipoTransaccionModel.toJson()));

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
    final result =
        await Auditoria.borradoLogico(db, table, idTipoTransaccion, idTable);

    return result;
  }
}
