import 'package:inversiones/domain/entity/motivos_entity.dart';
import 'package:inversiones/domain/models/schema_base.dart';

class MotivosSchema extends SchemaBase<Motivos> {
  static const table = 'motivos';

  static const idMotivo = "id_motivo";
  static const nombre = "nombre";
  static const descripcion = "descripcion";
  static const createdAt = "created_at";
  static const updatedAt = "updated_at";
  static const deletedAt = "deleted_at";

  @override
  String get tabla => table;

  @override
  String get columnaId => idMotivo;

  @override
  String get orden => '$nombre COLLATE NOCASE';

  @override
  Motivos desdeJson(Map<String, dynamic> json) => Motivos.fromJson(json);

  @override
  Map<String, dynamic> aJson(Motivos entidad) => entidad.toJson();

  @override
  int? idDe(Motivos entidad) => entidad.idMotivo;

  @override
  String createTableQuery() {
    return "CREATE TABLE $table ("
        "$idMotivo ${TiposSql.id},"
        "$nombre ${TiposSql.texto},"
        "$descripcion ${TiposSql.textoNulo},"
        "$createdAt ${TiposSql.texto},"
        "$updatedAt ${TiposSql.textoNulo},"
        "$deletedAt ${TiposSql.textoNulo}"
        ")";
  }
}
