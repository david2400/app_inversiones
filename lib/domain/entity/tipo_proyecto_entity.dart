import 'dart:convert';

List<TipoProyecto> tipoProyectoModelFromJson(String str) =>
    List<TipoProyecto>.from(
        json.decode(str).map((x) => TipoProyecto.fromJson(x)));

String tipoProyectoModelToJson(List<TipoProyecto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TipoProyecto {
  int? idTipoProyecto;
  String nombre;
  String descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  TipoProyecto(
      {this.idTipoProyecto,
      required this.nombre,
      required this.descripcion,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory TipoProyecto.fromJson(Map<String, dynamic> json) => TipoProyecto(
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
