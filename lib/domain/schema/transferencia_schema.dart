import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/entity/saldo_portafolio_entity.dart';
import 'package:inversiones/domain/entity/total_mensual_entity.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:sqflite/sqflite.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_balance_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_portafolio_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transacciones_details_dto.dart';
import 'package:inversiones/domain/entity/transferencia_entity.dart';

class TransferenciaShema implements TableAbstract {
  static const table = 'transferencias';

  static const idTransferencia = "id_transferencia";
  static const valor = "valor";
  static const impuesto = "impuesto";
  static const tipoTransferencia = "tipo_transferencia_id";
  static const motivo = "motivo_id";
  static const portafolioId = "portafolio_id";
  static const destino = "destino_cuenta";
  static const destinoAlternativo = "destino_alternativo";
  static const descripcion = "descripcion";
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
        "$idTransferencia $idType,"
        "$valor $intType,"
        "$impuesto $intTypeNull,"
        "$tipoTransferencia $intType,"
        "$motivo $intTypeNull,"
        "$portafolioId $intType,"
        "$destino $intTypeNull,"
        "$destinoAlternativo $textTypeNull,"
        "$descripcion $textTypeNull,"
        "$createdAt $textType,"
        "$updatedAt $textTypeNull,"
        "$deletedAt $textTypeNull"
      ")";
  }

  @override
  Future<int> deleteAll() async {
    final db = await DatabaseHelper().database;
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
  Future<List<Transaccion>> getAll() async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table, where: Auditoria.filtroActivo);

    return result.isNotEmpty
        ? result.map((e) => Transaccion.fromJson(e)).toList()
        : [];
  }

  @override
  Future<Transaccion?> getById(int idT) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table, where: "$idTransferencia = ? AND ${Auditoria.filtroActivo}", whereArgs: [idT]);
    return result.isNotEmpty ? Transaccion.fromJson(result.first) : null;
  }

  /// SELECT + JOINs comunes para listar movimientos con sus nombres.
  static const _selectDetallePortafolio = '''
        SELECT tr.id_transferencia, tr.valor, tr.impuesto, tr.destino_cuenta AS destino_cuenta_id, pr.nombre AS destino_cuenta,
        tr.tipo_transferencia_id, tt.nombre AS tipo_transaccion, tr.motivo_id, mo.nombre  AS motivo,
        tt.tipo_fuente, tr.destino_alternativo, tr.descripcion, tr.created_at, tr.updated_at, tr.deleted_at
        FROM ${TransferenciaShema.table} AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        LEFT JOIN ${MotivosSchema.table} AS mo ON tr.motivo_id = mo.id_motivo
        LEFT JOIN ${PortafolioSchema.table} AS pr ON tr.destino_cuenta = pr.id_portafolio''';

  /// Columnas comunes para las consultas de balance.
  static const _columnasBalance = '''
        tr.id_transferencia, tr.valor, tr.impuesto, tr.portafolio_id,
        p.proyecto_id, tr.destino_cuenta, tt.tipo_fuente, tr.destino_alternativo''';

  Future<List<TransaccionBalanceDto>> getTransaccionesByMesAndAnio(
      String year, String month) async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.rawQuery('''
        SELECT $_columnasBalance
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS p ON tr.portafolio_id = p.id_portafolio
        WHERE tr.deleted_at IS NULL
          AND strftime('%Y', tr.created_at) = ?
          AND strftime('%m', tr.created_at) = ?
      ''', [year.padLeft(4, '0'), month.padLeft(2, '0')]);
      return result.isNotEmpty
          ? result.map((e) => TransaccionBalanceDto.fromJson(e)).toList()
          : [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Transaccion>> getByPortafolioId(int idT) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table,
        where: "$portafolioId = ? AND ${Auditoria.filtroActivo}",
        whereArgs: [idT]);

    return result.isNotEmpty
        ? result.map((e) => Transaccion.fromJson(e)).toList()
        : [];
  }

  /// Movimientos que salen de, o llegan a, algún portafolio del proyecto.
  /// `proyecto_id` corresponde siempre al proyecto del portafolio origen.
  Future<List<TransaccionBalanceDto>> getBalanceByProyectoId(
      int proyectoId) async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery('''
        SELECT $_columnasBalance
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS p ON tr.portafolio_id = p.id_portafolio
        LEFT JOIN ${PortafolioSchema.table} AS pd ON tr.destino_cuenta = pd.id_portafolio
        WHERE tr.deleted_at IS NULL
          AND (p.proyecto_id = ? OR pd.proyecto_id = ?)
    ''', [proyectoId, proyectoId]);
    return result.isNotEmpty
        ? result.map((e) => TransaccionBalanceDto.fromJson(e)).toList()
        : [];
  }

  Future<List<TransaccionPortafolioDto>> getTransaccionByPortafolioId(
      int portafolioId) async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.rawQuery('''
            $_selectDetallePortafolio
            WHERE tr.deleted_at IS NULL
              AND (tr.portafolio_id = ? OR tr.destino_cuenta = ?)
            ORDER BY tr.created_at DESC
          ''', [portafolioId, portafolioId]);
      return result.isNotEmpty
          ? result.map((e) => TransaccionPortafolioDto.fromJson(e)).toList()
          : [];
    } catch (e) {
      rethrow;
    }
  }

  Future<TransaccionDetailsDto?> getTransaccionDetails(
      int transaccionId) async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.rawQuery('''
          SELECT tr.id_transferencia, tr.valor, tr.impuesto, tr.destino_cuenta AS destino_cuenta_id,
          pr.nombre AS destino_cuenta, tr.tipo_transferencia_id, tt.nombre AS tipo_transaccion, tr.motivo_id,
          mo.nombre  AS motivo, tr.destino_alternativo, tr.descripcion, tr.created_at, tr.updated_at, tr.deleted_at
          FROM $table AS tr
          JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
          LEFT JOIN ${MotivosSchema.table} AS mo ON tr.motivo_id = mo.id_motivo
          LEFT JOIN ${PortafolioSchema.table} AS pr ON tr.destino_cuenta = pr.id_portafolio
          WHERE tr.id_transferencia = ? AND tr.deleted_at IS NULL
      ''', [transaccionId]);
      return result.isNotEmpty
          ? TransaccionDetailsDto.fromJson(result.first)
          : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Saldo de cada portafolio activo calculado desde los movimientos:
  /// ingresos (+), egresos y transferencias salientes (−valor −GMF) y
  /// transferencias entrantes (+valor). Si se indica [idPortafolio] retorna
  /// solo ese portafolio.
  Future<List<SaldoPortafolio>> obtenerSaldos({int? idPortafolio}) async {
    final db = await DatabaseHelper().database;
    const ingreso = TipoFuente.ingreso;
    const transferencia = TipoFuente.transferencia;
    final filtroPortafolio =
        idPortafolio == null ? '' : 'AND p.id_portafolio = ?';

    final result = await db.rawQuery('''
        SELECT p.id_portafolio, p.nombre, p.proyecto_id,
          COALESCE(SUM(m.ingreso), 0) AS ingresos,
          COALESCE(SUM(m.egreso), 0) AS egresos,
          COALESCE(SUM(m.impuesto), 0) AS impuestos,
          COALESCE(SUM(m.ingreso - m.egreso - m.impuesto), 0) AS saldo
        FROM ${PortafolioSchema.table} AS p
        LEFT JOIN (
          SELECT tr.portafolio_id AS id_portafolio,
            CASE WHEN tt.tipo_fuente = '$ingreso' THEN tr.valor ELSE 0 END AS ingreso,
            CASE WHEN tt.tipo_fuente = '$ingreso' THEN 0 ELSE tr.valor END AS egreso,
            CASE WHEN tt.tipo_fuente = '$ingreso' THEN 0 ELSE COALESCE(tr.impuesto, 0) END AS impuesto
          FROM $table AS tr
          JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
          WHERE tr.deleted_at IS NULL
          UNION ALL
          SELECT tr.destino_cuenta, tr.valor, 0, 0
          FROM $table AS tr
          JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
          WHERE tr.deleted_at IS NULL
            AND tt.tipo_fuente = '$transferencia'
            AND tr.destino_cuenta IS NOT NULL
        ) AS m ON m.id_portafolio = p.id_portafolio
        WHERE p.deleted_at IS NULL $filtroPortafolio
        GROUP BY p.id_portafolio, p.nombre, p.proyecto_id
        ORDER BY p.nombre
    ''', idPortafolio == null ? [] : [idPortafolio]);

    return result.map((e) => SaldoPortafolio.fromJson(e)).toList();
  }

  /// Cuenta movimientos activos que referencian [id] en [columna].
  /// Se usa para impedir borrar catálogos que están en uso.
  Future<int> contarActivosPor(String columna, int id) async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $table '
      'WHERE $columna = ? AND ${Auditoria.filtroActivo}',
      [id],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Totales por mes en el rango [desde, hasta) (fechas `yyyy-MM-dd`).
  /// Ingreso: tipo ingreso. Egreso: tipo egreso o transferencia a cuenta
  /// externa. Las transferencias entre portafolios propios no cuentan.
  Future<List<TotalMensual>> obtenerTotalesMensuales(
      {required String desde, required String hasta}) async {
    final db = await DatabaseHelper().database;
    const ingreso = TipoFuente.ingreso;
    const egreso = TipoFuente.egreso;
    const transferencia = TipoFuente.transferencia;

    final result = await db.rawQuery('''
        SELECT strftime('%Y-%m', tr.created_at) AS periodo,
          SUM(CASE WHEN tt.tipo_fuente = '$ingreso' THEN tr.valor ELSE 0 END) AS ingresos,
          SUM(CASE WHEN tt.tipo_fuente = '$egreso'
                     OR (tt.tipo_fuente = '$transferencia' AND tr.destino_cuenta IS NULL)
                   THEN tr.valor ELSE 0 END) AS egresos,
          SUM(CASE WHEN tt.tipo_fuente = '$ingreso' THEN 0
                   ELSE COALESCE(tr.impuesto, 0) END) AS impuestos
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        WHERE tr.deleted_at IS NULL
          AND tr.created_at >= ? AND tr.created_at < ?
        GROUP BY periodo
        ORDER BY periodo
    ''', [desde, hasta]);

    return result.map((e) => TotalMensual.fromJson(e)).toList();
  }

  /// Totales de un proyecto. Ingreso: ingresos a sus portafolios y
  /// transferencias que llegan desde fuera del proyecto. Egreso: egresos y
  /// transferencias que salen del proyecto. GMF: el pagado por sus portafolios.
  Future<TotalMensual> obtenerTotalesProyecto(int idProyecto) async {
    final db = await DatabaseHelper().database;
    const ingreso = TipoFuente.ingreso;
    const egreso = TipoFuente.egreso;
    const transferencia = TipoFuente.transferencia;

    final result = await db.rawQuery('''
        SELECT
          COALESCE(SUM(CASE
            WHEN tt.tipo_fuente = '$ingreso' AND po.proyecto_id = ?1 THEN tr.valor
            WHEN tt.tipo_fuente = '$transferencia' AND pd.proyecto_id = ?1
                 AND po.proyecto_id <> ?1 THEN tr.valor
            ELSE 0 END), 0) AS ingresos,
          COALESCE(SUM(CASE
            WHEN po.proyecto_id = ?1 AND (tt.tipo_fuente = '$egreso'
                 OR (tt.tipo_fuente = '$transferencia'
                     AND (pd.proyecto_id IS NULL OR pd.proyecto_id <> ?1)))
            THEN tr.valor ELSE 0 END), 0) AS egresos,
          COALESCE(SUM(CASE
            WHEN po.proyecto_id = ?1 AND tt.tipo_fuente <> '$ingreso'
            THEN COALESCE(tr.impuesto, 0) ELSE 0 END), 0) AS impuestos
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS po ON tr.portafolio_id = po.id_portafolio
        LEFT JOIN ${PortafolioSchema.table} AS pd ON tr.destino_cuenta = pd.id_portafolio
        WHERE tr.deleted_at IS NULL
          AND (po.proyecto_id = ?1 OR pd.proyecto_id = ?1)
    ''', [idProyecto]);

    return TotalMensual.fromJson(result.first);
  }

  /// Últimos movimientos activos de todos los portafolios.
  Future<List<TransaccionPortafolioDto>> obtenerUltimosMovimientos(
      int limite) async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery('''
        $_selectDetallePortafolio
        WHERE tr.deleted_at IS NULL
        ORDER BY tr.created_at DESC, tr.id_transferencia DESC
        LIMIT ?
    ''', [limite]);
    return result.map((e) => TransaccionPortafolioDto.fromJson(e)).toList();
  }

  @override
  Future<int> insert(object) async {
    Transaccion transferenciaModel = object as Transaccion;

    final db = await DatabaseHelper().database;
    final result = await db.insert(table, Auditoria.datosCreacion(transferenciaModel.toJson()));

    return result;
  }

  @override
  Future<int> update(object) async {
    Transaccion transferenciaModel = object as Transaccion;

    final db = await DatabaseHelper().database;
    final result = await db.update(
      table, Auditoria.datosActualizacion(transferenciaModel.toJson()), where: '$idTransferencia = ?',
      // Condición de actualización
      whereArgs: [transferenciaModel.idTransferencia!],
    );

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
    final db = await DatabaseHelper().database;
    final result =
        await Auditoria.borradoLogico(db, table, idTransferencia, idTable);

    return result;
  }
}
