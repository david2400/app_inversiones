import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/entity/ejecucion_presupuesto_entity.dart';
import 'package:inversiones/domain/entity/presupuesto_entity.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/models/schema_base.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';

class PresupuestoSchema extends SchemaBase<Presupuesto> {
  static const table = 'presupuestos';

  static const idPresupuesto = "id_presupuesto";
  static const motivoId = "motivo_id";
  static const montoMensual = "monto_mensual";

  /// Cuenta a la que se limita el presupuesto (nula = todas las cuentas).
  static const cuentaId = "cuenta_id";
  static const createdAt = "created_at";
  static const updatedAt = "updated_at";
  static const deletedAt = "deleted_at";

  @override
  String get tabla => table;

  @override
  String get columnaId => idPresupuesto;

  @override
  Presupuesto desdeJson(Map<String, dynamic> json) => Presupuesto.fromJson(json);

  @override
  Map<String, dynamic> aJson(Presupuesto entidad) => entidad.toJson();

  @override
  int? idDe(Presupuesto entidad) => entidad.idPresupuesto;

  @override
  String createTableQuery() {
    return "CREATE TABLE $table ("
        "$idPresupuesto INTEGER PRIMARY KEY AUTOINCREMENT,"
        "$motivoId INTEGER NOT NULL,"
        "$montoMensual INTEGER NOT NULL,"
        "$createdAt TEXT NOT NULL,"
        "$updatedAt TEXT NULL,"
        "$deletedAt TEXT NULL,"
        "$cuentaId INTEGER NULL,"
        "FOREIGN KEY ($motivoId) REFERENCES ${MotivosSchema.table} (${MotivosSchema.idMotivo}),"
        "FOREIGN KEY ($cuentaId) REFERENCES ${CuentaSchema.table} (${CuentaSchema.idCuenta})"
        ")";
  }

  /// Presupuesto activo del motivo para la cuenta [idCuenta] (nula = el
  /// presupuesto general, de todas las cuentas).
  Future<Presupuesto?> getByMotivo(int idMotivo, {int? idCuenta}) async {
    final db = await DatabaseHelper().ejecutor;
    // sqflite no acepta null como argumento: sin cuenta se usa IS NULL.
    final result = await db.query(table,
        where: "$motivoId = ? AND "
            "${idCuenta == null ? '$cuentaId IS NULL' : '$cuentaId = ?'} "
            "AND ${Auditoria.filtroActivo}",
        whereArgs: [idMotivo, if (idCuenta != null) idCuenta]);
    return result.isNotEmpty ? Presupuesto.fromJson(result.first) : null;
  }

  /// Presupuestos activos con lo gastado en [desde, hasta) por su motivo.
  /// Gasto = egresos y transferencias a cuentas externas (sin GMF). Si el
  /// presupuesto es de una cuenta, solo cuenta lo que sale de sus
  /// portafolios.
  Future<List<EjecucionPresupuesto>> obtenerEjecucion(
      {required String desde, required String hasta}) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawQuery('''
        SELECT p.$idPresupuesto, p.$motivoId, mo.nombre AS motivo, p.$montoMensual,
          p.$cuentaId, cu.nombre AS cuenta,
          COALESCE((
            SELECT SUM(tr.valor)
            FROM ${TransferenciaShema.table} AS tr
            JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
            WHERE tr.deleted_at IS NULL
              AND tr.motivo_id = p.$motivoId
              AND (tt.tipo_fuente = '${TipoFuente.egreso}'
                   OR (tt.tipo_fuente = '${TipoFuente.transferencia}' AND tr.destino_cuenta IS NULL))
              AND tr.created_at >= ? AND tr.created_at < ?
              AND (p.$cuentaId IS NULL OR tr.portafolio_id IN (
                SELECT po.id_portafolio FROM ${PortafolioSchema.table} AS po
                WHERE po.cuenta_id = p.$cuentaId))
          ), 0) AS gastado
        FROM $table AS p
        JOIN ${MotivosSchema.table} AS mo ON p.$motivoId = mo.id_motivo
        LEFT JOIN ${CuentaSchema.table} AS cu ON p.$cuentaId = cu.id_cuenta
        WHERE p.deleted_at IS NULL
        ORDER BY mo.nombre COLLATE NOCASE, cu.nombre COLLATE NOCASE
    ''', [desde, hasta]);
    return result.map((e) => EjecucionPresupuesto.fromJson(e)).toList();
  }
}
