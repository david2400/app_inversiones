// To parse this JSON data, do
//
//     final populationModel = populationModelFromJson(jsonString);

import 'dart:convert';

List<TipoTransaccionDto> tipoTransaccionDtoModelFromJson(String str) =>
    List<TipoTransaccionDto>.from(
        json.decode(str).map((x) => TipoTransaccionDto.fromJson(x)));

String tipoTransaccionDtoModelToJson(List<TipoTransaccionDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TipoTransaccionDto {
  int? idTipoTransaccion;
  String nombre;
  String descripcion;
  String tipoFuente;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  TipoTransaccionDto(
      {this.idTipoTransaccion,
      required this.nombre,
      required this.descripcion,
      required this.tipoFuente,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory TipoTransaccionDto.fromJson(Map<String, dynamic> json) =>
      TipoTransaccionDto(
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
