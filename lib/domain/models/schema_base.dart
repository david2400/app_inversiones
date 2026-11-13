import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/models/table_abstract.dart';

/// Tipos de columna SQLite compartidos por los schemas.
class TiposSql {
  static const id = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const entero = 'INTEGER NOT NULL';
  static const enteroNulo = 'INTEGER NULL';
  static const texto = 'TEXT NOT NULL';
  static const textoNulo = 'TEXT NULL';

  TiposSql._();
}

/// CRUD común con auditoría y borrado lógico. Cada schema solo define su
/// tabla, su DDL y cómo convertir la entidad; las consultas propias se
/// agregan en la subclase.
abstract class SchemaBase<T> implements TableAbstract {
  /// Nombre de la tabla.
  String get tabla;

  /// Columna de la llave primaria.
  String get columnaId;

  /// Orden de [getAll] (por defecto, la llave primaria).
  String get orden => columnaId;

  T desdeJson(Map<String, dynamic> json);

  Map<String, dynamic> aJson(T entidad);

  int? idDe(T entidad);

  @override
  String dropTableQuery() => 'DROP TABLE IF EXISTS $tabla';

  @override
  Future<List<T>> getAll() async {
    final db = await DatabaseHelper().ejecutor;
    final result =
        await db.query(tabla, where: Auditoria.filtroActivo, orderBy: orden);
    return result.map(desdeJson).toList();
  }

  @override
  Future<T?> getById(int id) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(tabla,
        where: '$columnaId = ? AND ${Auditoria.filtroActivo}', whereArgs: [id]);
    return result.isNotEmpty ? desdeJson(result.first) : null;
  }

  @override
  Future<int> insert(dynamic object) async {
    final db = await DatabaseHelper().ejecutor;
    return db.insert(tabla, Auditoria.datosCreacion(aJson(object as T)));
  }

  @override
  Future<int> update(dynamic object) async {
    final entidad = object as T;
    final db = await DatabaseHelper().ejecutor;
    return db.update(tabla, Auditoria.datosActualizacion(aJson(entidad)),
        where: '$columnaId = ?', whereArgs: [idDe(entidad)]);
  }

  /// Reemplaza todo el contenido de la tabla por [object].
  @override
  Future<int> insertAll(List<dynamic> object) async {
    await deleteAll();
    var result = 0;
    for (final element in object) {
      result += await insert(element);
    }
    return result;
  }

  @override
  Future<int> deleteById(int id) async {
    final db = await DatabaseHelper().ejecutor;
    return Auditoria.borradoLogico(db, tabla, columnaId, id);
  }

  /// Borrado físico de toda la tabla (solo para [insertAll]).
  @override
  Future<int> deleteAll() async {
    final db = await DatabaseHelper().ejecutor;
    return db.rawDelete('DELETE FROM $tabla');
  }
}
