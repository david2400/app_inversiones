import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/entity/recurrente_detalle_entity.dart';
import 'package:inversiones/domain/entity/recurrente_entity.dart';
import 'package:inversiones/domain/models/schema_base.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/tercero_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';

class RecurrenteSchema extends SchemaBase<Recurrente> {
  static const table = 'recurrentes';

  static const idRecurrente = "id_recurrente";

  @override
  String get tabla => table;

  @override
  String get columnaId => idRecurrente;

  @override
  Recurrente desdeJson(Map<String, dynamic> json) => Recurrente.fromJson(json);

  @override
  Map<String, dynamic> aJson(Recurrente entidad) => entidad.toJson();

  @override
  int? idDe(Recurrente entidad) => entidad.idRecurrente;

  @override
  String createTableQuery() {
    return "CREATE TABLE $table ("
        "$idRecurrente INTEGER PRIMARY KEY AUTOINCREMENT,"
        "nombre TEXT NOT NULL,"
        "tipo_transferencia_id INTEGER NOT NULL,"
        "portafolio_id INTEGER NOT NULL,"
        "destino_cuenta INTEGER NULL,"
        "destino_alternativo TEXT NULL,"
        "motivo_id INTEGER NULL,"
        "tercero_id INTEGER NULL,"
        "valor INTEGER NOT NULL,"
        "dia_mes INTEGER NOT NULL,"
        "activo INTEGER NOT NULL DEFAULT 1,"
        "descripcion TEXT NULL,"
        "created_at TEXT NOT NULL,"
        "updated_at TEXT NULL,"
        "deleted_at TEXT NULL,"
        "automatico INTEGER NOT NULL DEFAULT 0,"
        "FOREIGN KEY (tipo_transferencia_id) REFERENCES ${TipoTransaccionSchema.table} (${TipoTransaccionSchema.idTipoTransaccion}),"
        "FOREIGN KEY (portafolio_id) REFERENCES ${PortafolioSchema.table} (${PortafolioSchema.idPortafolio}),"
        "FOREIGN KEY (destino_cuenta) REFERENCES ${PortafolioSchema.table} (${PortafolioSchema.idPortafolio}),"
        "FOREIGN KEY (motivo_id) REFERENCES ${MotivosSchema.table} (${MotivosSchema.idMotivo}),"
        "FOREIGN KEY (tercero_id) REFERENCES ${TerceroSchema.table} (${TerceroSchema.idTercero})"
        ")";
  }

  /// Fijos activos y pausados con nombres resueltos y si ya tienen un
  /// movimiento registrado en [desde, hasta).
  Future<List<RecurrenteDetalle>> obtenerDetalle(
      {required String desde, required String hasta}) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawQuery('''
        SELECT r.id_recurrente, r.nombre, tt.nombre AS tipo, tt.tipo_fuente,
          po.nombre AS origen, COALESCE(pd.nombre, r.destino_alternativo) AS destino,
          mo.nombre AS motivo, te.nombre AS tercero, r.valor, r.dia_mes, r.activo,
          CASE WHEN EXISTS (
            SELECT 1 FROM ${TransferenciaShema.table} AS tr
            WHERE tr.recurrente_id = r.id_recurrente
              AND tr.deleted_at IS NULL
              AND tr.created_at >= ? AND tr.created_at < ?
          ) THEN 1 ELSE 0 END AS registrado
        FROM $table AS r
        JOIN ${TipoTransaccionSchema.table} AS tt ON r.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS po ON r.portafolio_id = po.id_portafolio
        LEFT JOIN ${PortafolioSchema.table} AS pd ON r.destino_cuenta = pd.id_portafolio
        LEFT JOIN ${MotivosSchema.table} AS mo ON r.motivo_id = mo.id_motivo
        LEFT JOIN ${TerceroSchema.table} AS te ON r.tercero_id = te.id_tercero
        WHERE r.deleted_at IS NULL
        ORDER BY r.dia_mes, r.nombre COLLATE NOCASE
    ''', [desde, hasta]);
    return result.map((e) => RecurrenteDetalle.fromJson(e)).toList();
  }
}
