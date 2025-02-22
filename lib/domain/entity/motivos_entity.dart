import 'dart:convert';

List<Motivos> motivosModelFromJson(String str) =>
    List<Motivos>.from(json.decode(str).map((x) => Motivos.fromJson(x)));

String motivosModelToJson(List<Motivos> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Motivos {
  int? idMotivo;
  String nombre;
  String descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  Motivos(
      {this.idMotivo,
      required this.nombre,
      required this.descripcion,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory Motivos.fromJson(Map<String, dynamic> json) => Motivos(
        idMotivo: json["id_motivo"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_motivo": idMotivo,
        "nombre": nombre,
        "descripcion": descripcion,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
