import 'dart:convert';

List<UsuarioDto> usuarioDtoModelFromJson(String str) =>
    List<UsuarioDto>.from(json.decode(str).map((x) => UsuarioDto.fromJson(x)));

String usuarioDtoToJson(List<UsuarioDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsuarioDto {
  int idUsuario;
  String nombre;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  UsuarioDto(
      {required this.idUsuario,
      required this.nombre,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory UsuarioDto.fromJson(Map<String, dynamic> json) => UsuarioDto(
        idUsuario: json["id_usuario"],
        nombre: json["nombre"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_usuario": idUsuario,
        "nombre": nombre,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
