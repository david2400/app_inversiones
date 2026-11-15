import 'package:inversiones/domain/entity/motivos_entity.dart';
import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/schema_base.dart';

class MotivosSchema extends SchemaBase<Motivos> {
  static const table = 'motivos';

  static const idMotivo = "id_motivo";
  static const nombre = "nombre";
  static const descripcion = "descripcion";

  /// `I` ingreso, `E` gasto; nulo = ambos.
  static const naturaleza = "naturaleza";

  /// 0 = oculto en los formularios (conserva su historial).
  static const activo = "activo";
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
        "$naturaleza ${TiposSql.textoNulo},"
        "$activo INTEGER NOT NULL DEFAULT 1,"
        "$createdAt ${TiposSql.texto},"
        "$updatedAt ${TiposSql.textoNulo},"
        "$deletedAt ${TiposSql.textoNulo}"
        ")";
  }

  /// Motivos no eliminados (activos e inactivos) con cantidad de
  /// movimientos y total movido, ordenados por naturaleza y nombre.
  Future<List<Map<String, Object?>>> listarConUso() async {
    final db = await DatabaseHelper().ejecutor;
    return db.rawQuery('''
        SELECT m.*,
          COUNT(tr.id_transferencia) AS cantidad_movimientos,
          COALESCE(SUM(tr.valor), 0) AS total_movido
        FROM $table m
        LEFT JOIN transferencias tr
          ON tr.motivo_id = m.$idMotivo AND tr.deleted_at IS NULL
        WHERE m.deleted_at IS NULL
        GROUP BY m.$idMotivo
        ORDER BY CASE m.$naturaleza WHEN 'I' THEN 0 WHEN 'E' THEN 1 ELSE 2 END,
          m.$nombre COLLATE NOCASE
    ''');
  }

  /// Motivos activos; con [soloNaturaleza] solo los de esa naturaleza y
  /// los que sirven para ambas.
  Future<List<Motivos>> getActivos({String? soloNaturaleza}) async {
    final db = await DatabaseHelper().ejecutor;
    final filtro = soloNaturaleza == null
        ? ''
        : 'AND ($naturaleza IS NULL OR $naturaleza = ?)';
    final result = await db.rawQuery(
        'SELECT * FROM $table WHERE deleted_at IS NULL AND $activo = 1 '
        '$filtro ORDER BY $nombre COLLATE NOCASE',
        soloNaturaleza == null ? [] : [soloNaturaleza]);
    return result.map(desdeJson).toList();
  }

  /// Si ya hay otro motivo (no eliminado) con [nombreBuscado], sin
  /// distinguir mayúsculas, distinto de [exceptoId].
  Future<bool> existeNombre(String nombreBuscado, {int? exceptoId}) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawQuery(
        'SELECT 1 FROM $table WHERE deleted_at IS NULL '
        'AND lower(trim($nombre)) = lower(trim(?)) '
        'AND $idMotivo <> ? LIMIT 1',
        [nombreBuscado, exceptoId ?? -1]);
    return result.isNotEmpty;
  }

  /// Uso del motivo en movimientos, fijos y presupuestos activos.
  Future<int> contarUsos(int id) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawQuery('''
        SELECT
          (SELECT COUNT(*) FROM transferencias WHERE motivo_id = ? AND deleted_at IS NULL)
        + (SELECT COUNT(*) FROM recurrentes WHERE motivo_id = ? AND deleted_at IS NULL)
        + (SELECT COUNT(*) FROM presupuestos WHERE motivo_id = ? AND deleted_at IS NULL)
          AS n
    ''', [id, id, id]);
    return (result.first['n'] as int?) ?? 0;
  }
}
