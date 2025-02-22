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
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  TipoTransaccion(
      {this.idTipoTransaccion,
      required this.nombre,
      required this.descripcion,
      required this.tipoFuente,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory TipoTransaccion.fromJson(Map<String, dynamic> json) =>
      TipoTransaccion(
        idTipoTransaccion: json["id_tipo_transaccion"],
        nombre: json["nombre"],
        tipoFuente: json["tipo_fuente"],
        descripcion: json["descripcion"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_tipo_transaccion": idTipoTransaccion,
        "nombre": nombre,
        "descripcion": descripcion,
        "tipo_fuente": tipoFuente,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
