import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/entity/tercero_entity.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/models/table_abstract.dart';

class TerceroSchema implements TableAbstract {
  static const table = 'terceros';

  static const idTercero = "id_tercero";
  static const nombre = "nombre";
  static const descripcion = "descripcion";
  static const createdAt = "created_at";
  static const updatedAt = "updated_at";
  static const deletedAt = "deleted_at";

  @override
  String createTableQuery() {
    return "CREATE TABLE $table ("
        "$idTercero INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$nombre TEXT NOT NULL,"
        "$descripcion TEXT NULL,"
        "$createdAt TEXT NOT NULL,"
        "$updatedAt TEXT NULL,"
        "$deletedAt TEXT NULL"
        ")";
  }

  @override
  String dropTableQuery() => "DROP TABLE IF EXISTS $table";

  @override
  Future<List<Tercero>> getAll() async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table,
        where: Auditoria.filtroActivo, orderBy: '$nombre COLLATE NOCASE');
    return result.map((e) => Tercero.fromJson(e)).toList();
  }

  @override
  Future<Tercero?> getById(int id) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table,
        where: "$idTercero = ? AND ${Auditoria.filtroActivo}", whereArgs: [id]);
    return result.isNotEmpty ? Tercero.fromJson(result.first) : null;
  }

  /// Busca un tercero activo con el mismo nombre (sin distinguir mayúsculas).
  Future<Tercero?> getByNombre(String valor) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table,
        where: "$nombre = ? COLLATE NOCASE AND ${Auditoria.filtroActivo}",
        whereArgs: [valor.trim()]);
    return result.isNotEmpty ? Tercero.fromJson(result.first) : null;
  }

  @override
  Future<int> insert(object) async {
    final tercero = object as Tercero;
    final db = await DatabaseHelper().database;
    return db.insert(table, Auditoria.datosCreacion(tercero.toJson()));
  }

  @override
  Future<int> update(object) async {
    final tercero = object as Tercero;
    final db = await DatabaseHelper().database;
    return db.update(table, Auditoria.datosActualizacion(tercero.toJson()),
        where: '$idTercero = ?', whereArgs: [tercero.idTercero]);
  }

  @override
  Future<int> insertAll(List object) async {
    int result = 0;
    for (final element in object) {
      result += await insert(element);
    }
    return result;
  }

  @override
  Future<int> deleteById(int id) async {
    final db = await DatabaseHelper().database;
    return Auditoria.borradoLogico(db, table, idTercero, id);
  }

  @override
  Future<int> deleteAll() async {
    final db = await DatabaseHelper().database;
    return db.rawDelete('DELETE FROM $table');
  }
}
