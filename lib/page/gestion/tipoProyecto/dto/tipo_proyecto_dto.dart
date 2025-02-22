import 'dart:convert';

List<TipoProyectoDto> tipoProyectoDtoModelFromJson(String str) =>
    List<TipoProyectoDto>.from(
        json.decode(str).map((x) => TipoProyectoDto.fromJson(x)));

String tipoProyectoDtoModelToJson(List<TipoProyectoDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TipoProyectoDto {
  int? idTipoProyecto;
  String nombre;
  String descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  TipoProyectoDto(
      {this.idTipoProyecto,
      required this.nombre,
      required this.descripcion,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory TipoProyectoDto.fromJson(Map<String, dynamic> json) =>
      TipoProyectoDto(
        idTipoProyecto: json["id_tipo_proyecto"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_tipo_proyecto": idTipoProyecto,
        "nombre": nombre,
        "descripcion": descripcion,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
