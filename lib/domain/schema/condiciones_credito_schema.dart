import 'package:inversiones/domain/entity/condiciones_credito_entity.dart';
import 'package:inversiones/domain/models/schema_base.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';

class CondicionesCreditoSchema extends SchemaBase<CondicionesCredito> {
  static const table = 'condiciones_credito';

  static const idCuenta = "id_cuenta";
  static const cupo = "cupo";
  static const tasaMensual = "tasa_mensual";
  static const cuotaManejo = "cuota_manejo";
  static const diaCorte = "dia_corte";
  static const diaPago = "dia_pago";
  static const plazoMeses = "plazo_meses";
  static const fechaDesembolso = "fecha_desembolso";
  static const recurrenteManejoId = "recurrente_manejo_id";
  static const createdAt = "created_at";
  static const updatedAt = "updated_at";
  static const deletedAt = "deleted_at";

  @override
  String get tabla => table;

  @override
  String get columnaId => idCuenta;

  @override
  CondicionesCredito desdeJson(Map<String, dynamic> json) =>
      CondicionesCredito.fromJson(json);

  @override
  Map<String, dynamic> aJson(CondicionesCredito entidad) => entidad.toJson();

  @override
  int? idDe(CondicionesCredito entidad) => entidad.idCuenta;

  @override
  String createTableQuery() {
    return "CREATE TABLE $table ("
        "$idCuenta INTEGER PRIMARY KEY,"
        "$cupo ${TiposSql.enteroNulo},"
        "$tasaMensual INTEGER NOT NULL DEFAULT 0,"
        "$cuotaManejo ${TiposSql.enteroNulo},"
        "$diaCorte ${TiposSql.enteroNulo},"
        "$diaPago ${TiposSql.enteroNulo},"
        "$plazoMeses ${TiposSql.enteroNulo},"
        "$fechaDesembolso ${TiposSql.textoNulo},"
        "$recurrenteManejoId ${TiposSql.enteroNulo},"
        "$createdAt ${TiposSql.texto},"
        "$updatedAt ${TiposSql.textoNulo},"
        "$deletedAt ${TiposSql.textoNulo},"
        "FOREIGN KEY ($idCuenta) REFERENCES ${CuentaSchema.table} (${CuentaSchema.idCuenta}),"
        "FOREIGN KEY ($recurrenteManejoId) REFERENCES recurrentes (id_recurrente)"
        ")";
  }
}
