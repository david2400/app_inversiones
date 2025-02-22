import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/proyecto_schema.dart';
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
    final result = await db.query(table);

    return result.isNotEmpty
        ? result.map((e) => Transaccion.fromJson(e)).toList()
        : [];
  }

  @override
  Future<Transaccion?> getById(int idT) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table, where: "$idTransferencia = ?", whereArgs: [idT]);
    return result.isNotEmpty ? Transaccion.fromJson(result.first) : null;
  }

  Future<List<TransaccionBalanceDto>> getTransaccionesByMesAndAnio(
      String year,String month) async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.rawQuery('''
        SELECT tr.id_Transferencia, tr.valor, tr.impuesto, tr.portafolio_id, p.proyecto_id, tr.destino_cuenta, 
        tt.tipo_fuente, tr.destino_alternativo
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS p ON tr.portafolio_id = p.id_portafolio OR tr.destino_cuenta = p.id_portafolio
        WHERE strftime('%Y', tr.created_at) = ? 
          AND strftime('%m', tr.created_at) = ?
      ''', [year, month]);
      return result.isNotEmpty
          ? result.map((e) => TransaccionBalanceDto.fromJson(e)).toList()
          : [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Transaccion>> getByPortafolioId(int idT) async {
    final db = await DatabaseHelper().database;
    final result =
        await db.query(table, where: "$portafolioId = ?", whereArgs: [idT]);

    return result.isNotEmpty
        ? result.map((e) => Transaccion.fromJson(e)).toList()
        : [];
  }

  Future<List<TransaccionBalanceDto>> getBalanceByProyectoId(
      int proyectoId) async {
    final db = await DatabaseHelper().database;
    final result = await db.rawQuery('''
        SELECT tr.id_Transferencia, tr.valor, tr.impuesto, tr.portafolio_id, p.proyecto_id, tr.destino_cuenta, tt.tipo_fuente, tr.destino_alternativo
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS p ON tr.portafolio_id = p.id_portafolio OR tr.destino_cuenta = p.id_portafolio
    ''', []);
    return result.isNotEmpty
        ? result.map((e) => TransaccionBalanceDto.fromJson(e)).toList()
        : [];
  }

  Future<List<TransaccionPortafolioDto>> getTransaccionByPortafolioId(
      int portafolioId) async {
    try {
      final db = await DatabaseHelper().database;
      final result = await db.rawQuery('''
            SELECT tr.id_transferencia, tr.valor, tr.impuesto, tr.destino_cuenta AS destino_cuenta_id, pr.nombre AS destino_cuenta,
            tr.tipo_transferencia_id, tt.nombre AS tipo_transaccion, tr.motivo_id, mo.nombre  AS motivo,
            tt.tipo_fuente, tr.destino_alternativo, tr.descripcion, tr.created_at, tr.updated_at, tr.deleted_at
            FROM $table AS tr
            JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
            LEFT JOIN ${MotivosSchema.table} AS mo ON tr.motivo_id = mo.id_motivo
            LEFT JOIN ${PortafolioSchema.table} AS pr ON tr.destino_cuenta = pr.id_portafolio
            WHERE tr.portafolio_id = ? OR tr.destino_cuenta = ?
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
          SELECT tr.id_Transferencia, tr.valor, tr.impuesto, tr.destino_cuenta AS destino_cuenta_id, 
          pr.nombre AS destino_cuenta, tr.tipo_transferencia_id, tt.nombre AS tipo_transaccion, tr.motivo_id, 
          mo.nombre  AS motivo, tr.destino_alternativo, tr.descripcion, tr.created_at, tr.updated_at, tr.deleted_at
          FROM $table AS tr
          JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
          LEFT JOIN ${MotivosSchema.table} AS mo ON tr.motivo_id = mo.id_motivo
          LEFT JOIN ${PortafolioSchema.table} AS pr ON tr.destino_cuenta = pr.id_portafolio
          WHERE tr.id_Transferencia = ?
      ''', [transaccionId]);
      return result.isNotEmpty
          ? TransaccionDetailsDto.fromJson(result.first)
          : null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> insert(object) async {
    Transaccion transferenciaModel = object as Transaccion;

    final db = await DatabaseHelper().database;
    final result = await db.insert(table, transferenciaModel.toJson());

    return result;
  }

  @override
  Future<int> update(object) async {
    Transaccion transferenciaModel = object as Transaccion;

    final db = await DatabaseHelper().database;
    final result = await db.update(
      table, transferenciaModel.toJson(), where: '$idTransferencia = ?',
      // Condición de actualización
      whereArgs: [transferenciaModel.idTransferencia!],
    );

    return result;
  }

  @override
  Future<int> insertAll(List object) async {
    int result = 0;

    deleteAll();
    for (var element in object) {
      result += await insert(element);
    }
    return result;
  }

  @override
  Future<int> deleteById(int idTable) async {
    final db = await DatabaseHelper().database;
    final result =
        await db.delete(table, where: '$idTransferencia = ?', whereArgs: [idTable]);

    return result;
  }
}
