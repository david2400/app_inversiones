import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/entity/proyecto_entity.dart';

class ProyectoSchema implements TableAbstract {
  static const table = 'proyectos';

  static const idProyecto = "id_proyecto";
  static const nombre = "nombre";
  static const descripcion = "descripcion";

  /// Tipo del proyecto (renta fija, finca raíz, acciones...). Opcional.
  static const tipoProyecto = "tipo_proyecto_id";
  static const usuarioId = "usuario_id";
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
        "$idProyecto $idType,"
        "$nombre $textType,"
        "$usuarioId $intType,"
        "$descripcion $textTypeNull,"
        "$createdAt $textType,"
        "$updatedAt $textTypeNull,"
        "$deletedAt $textTypeNull,"
        "$tipoProyecto $intTypeNull "
        "REFERENCES tipo_proyecto (id_tipo_proyecto)"
        ")";
  }

  @override
  Future<int> deleteAll() async {
    final db = await DatabaseHelper().ejecutor;
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
  Future<List<Proyecto>> getAll() async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table, where: Auditoria.filtroActivo);

    return result.isNotEmpty
        ? result.map((e) => Proyecto.fromJson(e)).toList()
        : [];
  }

  @override
  Future<Proyecto?> getById(int idT) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table, where: "$idProyecto = ? AND ${Auditoria.filtroActivo}", whereArgs: [idT]);
    return result.isNotEmpty ? Proyecto.fromJson(result.first) : null;
  }

  @override
  Future<int> update(object) async {
    Proyecto proyectoModel = object as Proyecto;

    final db = await DatabaseHelper().ejecutor;
    final result = await db.update(
      table,
      Auditoria.datosActualizacion(proyectoModel.toJson()),
      where: '$idProyecto = ?',
      whereArgs: [proyectoModel.idProyecto!],
    );

    return result;
  }

  @override
  Future<int> insert(object) async {
    Proyecto proyectoModel = object as Proyecto;

    final db = await DatabaseHelper().ejecutor;
    final result = await db.insert(table, Auditoria.datosCreacion(proyectoModel.toJson()));

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
    final db = await DatabaseHelper().ejecutor;
    final result =
        await Auditoria.borradoLogico(db, table, idProyecto, idTable);

    return result;
  }
}
