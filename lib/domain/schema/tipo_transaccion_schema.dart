import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/entity/tipo_transaccion_entity.dart';

class TipoTransaccionSchema implements TableAbstract {
  static const table = 'tipo_transferencia';

  static const idTipoTransaccion = "id_tipo_transaccion";
  static const nombre = "nombre";
  static const descripcion = "descripcion";
  static const tipoFuente = "tipo_fuente";

  /// 1 si la app lo usa para sus operaciones (uno por naturaleza): no se
  /// elimina, no se desactiva ni cambia de naturaleza.
  static const esSistema = "es_sistema";

  /// 0 = oculto en los formularios (conserva su historial).
  static const activo = "activo";
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
        "$idTipoTransaccion $idType,"
        "$nombre $textType,"
        "$descripcion $textTypeNull,"
        "$tipoFuente $textType,"
        "$esSistema INTEGER NOT NULL DEFAULT 0,"
        "$activo INTEGER NOT NULL DEFAULT 1,"
        "$createdAt $textType,"
        "$updatedAt $textTypeNull,"
        "$deletedAt $textTypeNull"
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
  Future<List<TipoTransaccion>> getAll() async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table, where: Auditoria.filtroActivo);

    return result.isNotEmpty
        ? result.map((e) => TipoTransaccion.fromJson(e)).toList()
        : [];
  }

  @override
  Future<TipoTransaccion?> getById(int idT) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table, where: "$idTipoTransaccion = ? AND ${Auditoria.filtroActivo}", whereArgs: [idT]);
    return result.isNotEmpty ? TipoTransaccion.fromJson(result.first) : null;
  }

  /// Tipo que usa la app para la naturaleza [fuente] (`I`, `E` o `M`): el
  /// del sistema o, si no hay, el primero activo.
  Future<TipoTransaccion?> getPrimeroPorFuente(String fuente) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table,
        where: "$tipoFuente = ? AND ${Auditoria.filtroActivo}",
        whereArgs: [fuente],
        orderBy: '$esSistema DESC, $activo DESC, $idTipoTransaccion',
        limit: 1);
    return result.isNotEmpty ? TipoTransaccion.fromJson(result.first) : null;
  }

  @override
  Future<int> update(object) async {
    TipoTransaccion tipoTransaccionModel = object as TipoTransaccion;

    final db = await DatabaseHelper().ejecutor;
    final result = await db.update(
      table,
      Auditoria.datosActualizacion(tipoTransaccionModel.toJson()),
      where: '$idTipoTransaccion = ?',
      whereArgs: [tipoTransaccionModel.idTipoTransaccion!],
    );

    return result;
  }

  @override
  Future<int> insert(object) async {
    final tipo = object as TipoTransaccion;

    final db = await DatabaseHelper().ejecutor;
    final result = await db.insert(table, Auditoria.datosCreacion(tipo.toJson()));

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
        await Auditoria.borradoLogico(db, table, idTipoTransaccion, idTable);

    return result;
  }

  /// Tipos (activos e inactivos, sin los eliminados) con cantidad de
  /// movimientos y total movido, ordenados por naturaleza y nombre.
  Future<List<Map<String, Object?>>> listarConUso() async {
    final db = await DatabaseHelper().ejecutor;
    return db.rawQuery('''
        SELECT t.*,
          COUNT(tr.id_transferencia) AS cantidad_movimientos,
          COALESCE(SUM(tr.valor), 0) AS total_movido
        FROM $table t
        LEFT JOIN transferencias tr
          ON tr.tipo_transferencia_id = t.$idTipoTransaccion
         AND tr.deleted_at IS NULL
        WHERE t.deleted_at IS NULL
        GROUP BY t.$idTipoTransaccion
        ORDER BY CASE t.$tipoFuente WHEN 'I' THEN 0 WHEN 'E' THEN 1 ELSE 2 END,
          t.$esSistema DESC, t.$nombre COLLATE NOCASE
    ''');
  }

  /// Tipos activos (para los formularios), ordenados por naturaleza.
  Future<List<TipoTransaccion>> getActivos() async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table,
        where: '$activo = 1 AND ${Auditoria.filtroActivo}',
        orderBy: "CASE $tipoFuente WHEN 'I' THEN 0 WHEN 'E' THEN 1 ELSE 2 END, "
            '$esSistema DESC, $nombre COLLATE NOCASE');
    return result.map((e) => TipoTransaccion.fromJson(e)).toList();
  }

  /// Si ya hay otro tipo (no eliminado) con [nombreBuscado], sin distinguir
  /// mayúsculas, distinto de [exceptoId].
  Future<bool> existeNombre(String nombreBuscado, {int? exceptoId}) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawQuery(
        'SELECT 1 FROM $table WHERE deleted_at IS NULL '
        'AND lower(trim($nombre)) = lower(trim(?)) '
        'AND $idTipoTransaccion <> ? LIMIT 1',
        [nombreBuscado, exceptoId ?? -1]);
    return result.isNotEmpty;
  }

  /// Movimientos fijos activos que usan el tipo [id].
  Future<int> contarFijos(int id) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawQuery(
        'SELECT COUNT(*) AS n FROM recurrentes '
        'WHERE tipo_transferencia_id = ? AND deleted_at IS NULL',
        [id]);
    return (result.first['n'] as int?) ?? 0;
  }
}
