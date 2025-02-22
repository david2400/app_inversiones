import 'dart:convert';

List<ProyectoDto> proyectoDtoModelFromJson(String str) =>
    List<ProyectoDto>.from(
        json.decode(str).map((x) => ProyectoDto.fromJson(x)));

String proyectoDtoModelToJson(List<ProyectoDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProyectoDto {
  int? idProyecto;
  String nombre;
  String descripcion;
  int usuarioId;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  ProyectoDto(
      {this.idProyecto,
      required this.nombre,
      required this.descripcion,
      required this.usuarioId,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory ProyectoDto.fromJson(Map<String, dynamic> json) => ProyectoDto(
        idProyecto: json["id_proyecto"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        usuarioId: json["usuario_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_proyecto": idProyecto,
        "nombre": nombre,
        "descripcion": descripcion,
        "usuario_id": usuarioId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
