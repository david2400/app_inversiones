import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/entity/motivos_entity.dart';

class MotivosSchema implements TableAbstract {
  static const table = 'motivos';

  static const idMotivo = "id_motivo";
  static const nombre = "nombre";
  static const descripcion = "descripcion";
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
        "$idMotivo $idType,"
        "$nombre $textType,"
        "$descripcion $textTypeNull,"
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
  Future<List<Motivos>> getAll() async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table);

    return result.isNotEmpty
        ? result.map((e) => Motivos.fromJson(e)).toList()
        : [];
  }

  @override
  Future<Motivos?> getById(int idT) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table, where: "$idMotivo = ?", whereArgs: [idT]);
    return result.isNotEmpty ? Motivos.fromJson(result.first) : null;
  }

  @override
  Future<int> update(object) async {
    Motivos motivosModel = object as Motivos;

    final db = await DatabaseHelper().database;
    final result = await db.update(
      table,
      motivosModel.toJson(),
      where: 'idMotivo = ?',
      whereArgs: [motivosModel.idMotivo!],
    );

    return result;
  }

  @override
  Future<int> insert(object) async {
    Motivos motivoModel = object as Motivos;

    final db = await DatabaseHelper().database;

    final result = await db.insert(table, motivoModel.toJson());

    return result;
  }

  @override
  Future<int> insertAll(List object) async {
    int result = 0;

    deleteAll();
    for (var element in object) {
      result += await insert(element);
    }
    return result;
  }

  @override
  Future<int> deleteById(int idTable) async {
    final db = await DatabaseHelper().database;
    final result =
        await db.delete(table, where: '$idMotivo = ?', whereArgs: [idTable]);

    return result;
  }
}
