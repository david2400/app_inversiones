import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/entity/tipo_proyecto_entity.dart';

class TipoProyectoSchema implements TableAbstract {
  static const table = 'tipo_proyecto';

  static const idTipoProyecto = "id_tipo_proyecto";
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
        "$idTipoProyecto $idType,"
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
  Future<List<TipoProyecto>> getAll() async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table);

    print(result);
    return result.isNotEmpty
        ? result.map((e) => TipoProyecto.fromJson(e)).toList()
        : [];
  }

  @override
  Future<TipoProyecto?> getById(int idT) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table, where: "$idTipoProyecto = ?", whereArgs: [idT]);
    return result.isNotEmpty ? TipoProyecto.fromJson(result.first) : null;
  }

  @override
  Future<int> update(object) async {
    TipoProyecto tipoProyectoModel = object as TipoProyecto;

    final db = await DatabaseHelper().database;
    final result = await db.update(
      table,
      tipoProyectoModel.toJson(),
      where: '$idTipoProyecto = ?',
      whereArgs: [tipoProyectoModel.idTipoProyecto!],
    );

    return result;
  }

  @override
  Future<int> insert(object) async {
    TipoProyecto tipoProyectoModel = object as TipoProyecto;

    final db = await DatabaseHelper().database;
    final result = await db.insert(table, tipoProyectoModel.toJson());

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
        await db.delete(table, where: '$idTipoProyecto = ?', whereArgs: [idTable]);

    return result;
  }
}
