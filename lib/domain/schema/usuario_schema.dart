import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/entity/usuario_entity.dart';

class UsuarioShema implements TableAbstract {
  static const table = 'usuarios';

  static const idUsuario = "id_usuario";
  static const nombre = "nombre";
  static const apellido = "apellido";
  static const fechaNacimiento = "motivo";
  static const email = "destino_alternativo";
  static const password = "descripcion";
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
        "$idUsuario $idType,"
        "$nombre $textTypeNull,"
        "$apellido $textTypeNull,"
        "$fechaNacimiento $textTypeNull,"
        "$email $textType,"
        "$password $textType,"
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
  Future<List> getAll() async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table);

    return result.isNotEmpty
        ? result.map((e) => Usuario.fromJson(e)).toList()
        : [];
  }

  @override
  Future<Usuario?> getById(int idT) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table, where: "$idUsuario = ?", whereArgs: [idT]);
    return result.isNotEmpty ? Usuario.fromJson(result.first) : null;
  }

  @override
  Future<int> update(object) async {
    Usuario usuarioModel = object as Usuario;

    final db = await DatabaseHelper().database;
    final result = await db.update(
      table,
      usuarioModel.toJson(),
      where: '$idUsuario = ?',
      whereArgs: [usuarioModel.idUsuario!],
    );

    return result;
  }

  @override
  Future<int> insert(object) async {
    Usuario beneficiaryModel = object as Usuario;

    final db = await DatabaseHelper().database;
    final result = await db.insert(table, beneficiaryModel.toJson());

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
        await db.delete(table, where: '$idUsuario = ?', whereArgs: [idTable]);

    return result;
  }
}
