// To parse this JSON data, do
//
//     final populationModel = populationModelFromJson(jsonString);

import 'dart:convert';

List<TipoTransaccion> tipoTransaccionModelFromJson(String str) =>
    List<TipoTransaccion>.from(
        json.decode(str).map((x) => TipoTransaccion.fromJson(x)));

String tipoTransaccionModelToJson(List<TipoTransaccion> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TipoTransaccion {
  int? idTipoTransaccion;
  String nombre;
  String descripcion;
  String tipoFuente;

  /// Lo usa la app (uno por naturaleza): protegido.
  bool esSistema;

  /// Visible en los formularios.
  bool activo;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  TipoTransaccion(
      {this.idTipoTransaccion,
      required this.nombre,
      required this.descripcion,
      required this.tipoFuente,
      this.esSistema = false,
      this.activo = true,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory TipoTransaccion.fromJson(Map<String, dynamic> json) =>
      TipoTransaccion(
        idTipoTransaccion: json["id_tipo_transaccion"],
        nombre: json["nombre"],
        tipoFuente: json["tipo_fuente"],
        descripcion: json["descripcion"] ?? '',
        esSistema: json["es_sistema"] == 1,
        activo: (json["activo"] ?? 1) == 1,
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_tipo_transaccion": idTipoTransaccion,
        "nombre": nombre,
        "descripcion": descripcion,
        "tipo_fuente": tipoFuente,
        "es_sistema": esSistema ? 1 : 0,
        "activo": activo ? 1 : 0,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
