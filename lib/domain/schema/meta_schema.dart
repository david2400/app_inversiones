import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/entity/meta_entity.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/models/schema_base.dart';

class MetaSchema extends SchemaBase<Meta> {
  static const table = 'metas';

  static const idMeta = 'id_meta';
  static const nombre = 'nombre';
  static const descripcion = 'descripcion';
  static const montoObjetivo = 'monto_objetivo';
  static const fechaObjetivo = 'fecha_objetivo';
  static const activo = 'activo';
  static const createdAt = 'created_at';
  static const updatedAt = 'updated_at';
  static const deletedAt = 'deleted_at';

  @override
  String get tabla => table;

  @override
  String get columnaId => idMeta;

  /// Activas primero; luego por fecha objetivo (las sin fecha al final).
  @override
  String get orden =>
      '$activo DESC, $fechaObjetivo IS NULL, $fechaObjetivo, $nombre COLLATE NOCASE';

  @override
  Meta desdeJson(Map<String, dynamic> json) => Meta.fromJson(json);

  @override
  Map<String, dynamic> aJson(Meta entidad) => entidad.toJson();

  @override
  int? idDe(Meta entidad) => entidad.idMeta;

  @override
  String createTableQuery() => 'CREATE TABLE $table ('
      '$idMeta ${TiposSql.id},'
      '$nombre ${TiposSql.texto},'
      '$descripcion ${TiposSql.textoNulo},'
      '$montoObjetivo ${TiposSql.entero} CHECK ($montoObjetivo > 0),'
      '$fechaObjetivo ${TiposSql.textoNulo},'
      '$activo INTEGER NOT NULL DEFAULT 1,'
      '$createdAt ${TiposSql.texto},'
      '$updatedAt ${TiposSql.textoNulo},'
      '$deletedAt ${TiposSql.textoNulo}'
      ')';
}

class MetaPortafolioSchema extends SchemaBase<MetaPortafolio> {
  static const table = 'metas_portafolios';

  static const idMetaPortafolio = 'id_meta_portafolio';
  static const metaId = 'meta_id';
  static const portafolioId = 'portafolio_id';

  @override
  String get tabla => table;

  @override
  String get columnaId => idMetaPortafolio;

  @override
  MetaPortafolio desdeJson(Map<String, dynamic> json) =>
      MetaPortafolio.fromJson(json);

  @override
  Map<String, dynamic> aJson(MetaPortafolio entidad) => entidad.toJson();

  @override
  int? idDe(MetaPortafolio entidad) => entidad.idMetaPortafolio;

  @override
  String createTableQuery() => 'CREATE TABLE $table ('
      '$idMetaPortafolio ${TiposSql.id},'
      '$metaId ${TiposSql.entero},'
      '$portafolioId ${TiposSql.entero},'
      'created_at ${TiposSql.texto},'
      'updated_at ${TiposSql.textoNulo},'
      'deleted_at ${TiposSql.textoNulo},'
      'FOREIGN KEY ($metaId) REFERENCES ${MetaSchema.table} (${MetaSchema.idMeta}),'
      'FOREIGN KEY ($portafolioId) REFERENCES portafolios (id_portafolio)'
      ')';

  /// Datos de un borrado lógico de vínculos.
  static Map<String, Object> _borrado() {
    final fecha = Auditoria.ahora();
    return {
      Auditoria.columnaDeletedAt: fecha,
      Auditoria.columnaUpdatedAt: fecha,
    };
  }

  /// Portafolios activos vinculados a cada meta: {metaId: [portafolioId]}.
  Future<Map<int, List<int>>> portafoliosPorMeta() async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table,
        columns: [metaId, portafolioId],
        where: Auditoria.filtroActivo,
        orderBy: columnaId);
    final mapa = <int, List<int>>{};
    for (final fila in result) {
      mapa.putIfAbsent(fila[metaId] as int, () => []).add(fila[portafolioId] as int);
    }
    return mapa;
  }

  /// Portafolios vinculados a [idMeta].
  Future<List<int>> portafoliosDe(int idMeta) async =>
      (await portafoliosPorMeta())[idMeta] ?? [];

  /// Meta activa a la que pertenece el portafolio (o `null`).
  Future<int?> metaDePortafolio(int idPortafolio) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table,
        columns: [metaId],
        where: '$portafolioId = ? AND ${Auditoria.filtroActivo}',
        whereArgs: [idPortafolio],
        limit: 1);
    return result.isEmpty ? null : result.first[metaId] as int;
  }

  /// Deja vinculados a [idMeta] exactamente los portafolios [ids].
  Future<void> reemplazar(int idMeta, List<int> ids) async {
    final actuales = await portafoliosDe(idMeta);
    final db = await DatabaseHelper().ejecutor;
    for (final id in actuales.where((p) => !ids.contains(p))) {
      await db.update(table, _borrado(),
          where: '$metaId = ? AND $portafolioId = ? AND ${Auditoria.filtroActivo}',
          whereArgs: [idMeta, id]);
    }
    for (final id in ids.where((p) => !actuales.contains(p))) {
      await insert(MetaPortafolio(metaId: idMeta, portafolioId: id));
    }
  }

  /// Quita todos los vínculos de la meta (al eliminarla).
  Future<void> quitarDeMeta(int idMeta) => reemplazar(idMeta, const []);

  /// Quita el portafolio de su meta (al eliminar el portafolio).
  Future<void> quitarPortafolio(int idPortafolio) async {
    final db = await DatabaseHelper().ejecutor;
    await db.update(table, _borrado(),
        where: '$portafolioId = ? AND ${Auditoria.filtroActivo}',
        whereArgs: [idPortafolio]);
  }
}
