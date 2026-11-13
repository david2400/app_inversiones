import 'package:inversiones/domain/entity/cuenta_entity.dart';
import 'package:inversiones/domain/models/schema_base.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';

class CuentaSchema extends SchemaBase<Cuenta> {
  static const table = 'cuentas';

  static const idCuenta = "id_cuenta";
  static const nombre = "nombre";
  static const tipoCuenta = "tipo_cuenta";
  static const entidad = "entidad";
  static const nroCuenta = "nro_cuenta";
  static const exentaImpuesto = "exenta_impuesto";
  static const descripcion = "descripcion";
  static const createdAt = "created_at";
  static const updatedAt = "updated_at";
  static const deletedAt = "deleted_at";

  /// Id de la cuenta "Efectivo / Sin definir". Es la primera fila que se
  /// inserta en la tabla (instalación nueva y migración 24), así que su id
  /// siempre es 1. Recibe el dinero cuando no se indica otra cuenta.
  static const idEfectivo = 1;

  /// Exención de GMF que aplica a los portafolios de [cuenta]: el efectivo
  /// nunca paga 4x1000.
  static String exencionEfectiva(Cuenta cuenta) =>
      TipoCuenta.puedePagarGmf(cuenta.tipoCuenta) ? cuenta.exentaImpuesto : 'S';

  @override
  String get tabla => table;

  @override
  String get columnaId => idCuenta;

  @override
  String get orden => '$idCuenta = $idEfectivo DESC, $nombre COLLATE NOCASE';

  @override
  Cuenta desdeJson(Map<String, dynamic> json) => Cuenta.fromJson(json);

  @override
  Map<String, dynamic> aJson(Cuenta entidad) => entidad.toJson();

  @override
  int? idDe(Cuenta entidad) => entidad.idCuenta;

  @override
  String createTableQuery() {
    return "CREATE TABLE $table ("
        "$idCuenta ${TiposSql.id},"
        "$nombre ${TiposSql.texto},"
        "$tipoCuenta TEXT NOT NULL CHECK ($tipoCuenta IN "
        "(${TipoCuenta.valores.map((t) => "'$t'").join(',')})),"
        "$entidad ${TiposSql.textoNulo},"
        "$nroCuenta ${TiposSql.textoNulo},"
        "$exentaImpuesto TEXT NOT NULL DEFAULT 'N',"
        "$descripcion ${TiposSql.textoNulo},"
        "$createdAt ${TiposSql.texto},"
        "$updatedAt ${TiposSql.textoNulo},"
        "$deletedAt ${TiposSql.textoNulo}"
        ")";
  }
}
