import 'package:inversiones/domain/entity/tipo_proyecto_entity.dart';
import 'package:inversiones/domain/models/schema_base.dart';

class TipoProyectoSchema extends SchemaBase<TipoProyecto> {
  static const table = 'tipo_proyecto';

  static const idTipoProyecto = "id_tipo_proyecto";
  static const nombre = "nombre";
  static const descripcion = "descripcion";
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
        "$createdAt ${TiposSql.texto},"
        "$updatedAt ${TiposSql.textoNulo},"
        "$deletedAt ${TiposSql.textoNulo}"
        ")";
  }
}
