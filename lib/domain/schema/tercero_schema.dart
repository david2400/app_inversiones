import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/entity/tercero_entity.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/models/schema_base.dart';

class TerceroSchema extends SchemaBase<Tercero> {
  static const table = 'terceros';

  static const idTercero = "id_tercero";
  static const nombre = "nombre";
  static const descripcion = "descripcion";
  static const createdAt = "created_at";
  static const updatedAt = "updated_at";
  static const deletedAt = "deleted_at";

  @override
  String get tabla => table;

  @override
  String get columnaId => idTercero;

  @override
  String get orden => 'nombre COLLATE NOCASE';

  @override
  Tercero desdeJson(Map<String, dynamic> json) => Tercero.fromJson(json);

  @override
  Map<String, dynamic> aJson(Tercero entidad) => entidad.toJson();

  @override
  int? idDe(Tercero entidad) => entidad.idTercero;

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

  /// Busca un tercero activo con el mismo nombre (sin distinguir mayúsculas).
  Future<Tercero?> getByNombre(String valor) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table,
        where: "$nombre = ? COLLATE NOCASE AND ${Auditoria.filtroActivo}",
        whereArgs: [valor.trim()]);
    return result.isNotEmpty ? Tercero.fromJson(result.first) : null;
  }
}
