import 'dart:convert';

List<Proyecto> proyectoModelFromJson(String str) =>
    List<Proyecto>.from(json.decode(str).map((x) => Proyecto.fromJson(x)));

String proyectoModelToJson(List<Proyecto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Proyecto {
  int? idProyecto;
  String nombre;
  String descripcion;
  int usuarioId;

  /// Tipo de proyecto (renta fija, finca raíz...); nulo = sin clasificar.
  int? tipoProyectoId;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  Proyecto(
      {this.idProyecto,
      required this.nombre,
      required this.descripcion,
      required this.usuarioId,
      this.tipoProyectoId,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory Proyecto.fromJson(Map<String, dynamic> json) => Proyecto(
        idProyecto: json["id_proyecto"],
        nombre: json["nombre"],
        descripcion: json["descripcion"] ?? '',
        tipoProyectoId: json["tipo_proyecto_id"],
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
        "tipo_proyecto_id": tipoProyectoId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
