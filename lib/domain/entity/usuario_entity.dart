import 'dart:convert';

List<Usuario> usuarioModelFromJson(String str) =>
    List<Usuario>.from(json.decode(str).map((x) => Usuario.fromJson(x)));

String usuarioModelToJson(List<Usuario> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Usuario {
  int idUsuario;
  String nombre;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  Usuario(
      {required this.idUsuario,
      required this.nombre,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
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
