import 'package:inversiones/domain/entity/frecuencia_pago_entity.dart';
import 'package:inversiones/domain/models/schema_base.dart';

class FrecuenciaPagoSchema extends SchemaBase<FrecuenciaPago> {
  static const table = 'frecuencia_pagos';

  static const idFrecuenciaPago = "id_frecuencia_pago";
  static const tiempo = "tiempo";
  static const formato = "formato";
  static const createdAt = "created_at";
  static const updatedAt = "updated_at";
  static const deletedAt = "deleted_at";

  @override
  String get tabla => table;

  @override
  String get columnaId => idFrecuenciaPago;

  @override
  FrecuenciaPago desdeJson(Map<String, dynamic> json) =>
      FrecuenciaPago.fromJson(json);

  @override
  Map<String, dynamic> aJson(FrecuenciaPago entidad) => entidad.toJson();

  @override
  int? idDe(FrecuenciaPago entidad) => entidad.idFrecuenciaPago;

  @override
  String createTableQuery() {
    return "CREATE TABLE $table ("
        "$idFrecuenciaPago ${TiposSql.id},"
        "$tiempo ${TiposSql.entero},"
        "$formato ${TiposSql.texto},"
        "$createdAt ${TiposSql.texto},"
        "$updatedAt ${TiposSql.textoNulo},"
        "$deletedAt ${TiposSql.textoNulo}"
        ")";
  }
}
