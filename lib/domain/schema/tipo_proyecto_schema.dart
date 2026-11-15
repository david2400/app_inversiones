import 'package:inversiones/domain/entity/tipo_proyecto_entity.dart';
import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/schema_base.dart';
import 'package:inversiones/domain/schema/proyecto_schema.dart';

class TipoProyectoSchema extends SchemaBase<TipoProyecto> {
  static const table = 'tipo_proyecto';

  static const idTipoProyecto = "id_tipo_proyecto";
  static const nombre = "nombre";
  static const descripcion = "descripcion";
  static const riesgo = "riesgo";
  static const createdAt = "created_at";
  static const updatedAt = "updated_at";
  static const deletedAt = "deleted_at";

  @override
  String get tabla => table;

  @override
  String get columnaId => idTipoProyecto;

  @override
  TipoProyecto desdeJson(Map<String, dynamic> json) =>
      TipoProyecto.fromJson(json);

  @override
  Map<String, dynamic> aJson(TipoProyecto entidad) => entidad.toJson();

  @override
  int? idDe(TipoProyecto entidad) => entidad.idTipoProyecto;

  @override
  String createTableQuery() {
    return "CREATE TABLE $table ("
        "$idTipoProyecto ${TiposSql.id},"
        "$nombre ${TiposSql.texto},"
        "$descripcion ${TiposSql.textoNulo},"
        "$riesgo ${TiposSql.textoNulo},"
        "$createdAt ${TiposSql.texto},"
        "$updatedAt ${TiposSql.textoNulo},"
        "$deletedAt ${TiposSql.textoNulo}"
        ")";
  }

  /// Tipos activos con la cantidad de proyectos activos de cada uno,
  /// ordenados por nombre.
  Future<List<Map<String, Object?>>> listarConUso() async {
    final db = await DatabaseHelper().ejecutor;
    return db.rawQuery('''
        SELECT t.*, (
          SELECT COUNT(*) FROM ${ProyectoSchema.table} p
          WHERE p.${ProyectoSchema.tipoProyecto} = t.$idTipoProyecto
            AND p.deleted_at IS NULL
        ) AS cantidad_proyectos
        FROM $table t
        WHERE t.deleted_at IS NULL
        ORDER BY t.$nombre COLLATE NOCASE
    ''');
  }

  /// Si ya hay otro tipo activo con [nombreBuscado] (sin distinguir
  /// mayúsculas), distinto de [exceptoId].
  Future<bool> existeNombre(String nombreBuscado, {int? exceptoId}) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawQuery(
        'SELECT 1 FROM $table WHERE deleted_at IS NULL '
        'AND lower(trim($nombre)) = lower(trim(?)) '
        'AND $idTipoProyecto <> ? LIMIT 1',
        [nombreBuscado, exceptoId ?? -1]);
    return result.isNotEmpty;
  }

  /// Proyectos activos que usan el tipo [id].
  Future<int> contarProyectos(int id) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawQuery(
        'SELECT COUNT(*) AS n FROM ${ProyectoSchema.table} '
        'WHERE ${ProyectoSchema.tipoProyecto} = ? AND deleted_at IS NULL',
        [id]);
    return (result.first['n'] as int?) ?? 0;
  }
}
