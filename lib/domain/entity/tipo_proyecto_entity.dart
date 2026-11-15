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

  /// Nivel de riesgo (ver `NivelRiesgo`); nulo = sin definir.
  String? riesgo;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  TipoProyecto(
      {this.idTipoProyecto,
      required this.nombre,
      required this.descripcion,
      this.riesgo,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory TipoProyecto.fromJson(Map<String, dynamic> json) => TipoProyecto(
        idTipoProyecto: json["id_tipo_proyecto"],
        nombre: json["nombre"],
        descripcion: json["descripcion"] ?? '',
        riesgo: json["riesgo"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_tipo_proyecto": idTipoProyecto,
        "nombre": nombre,
        "descripcion": descripcion,
        "riesgo": riesgo,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
