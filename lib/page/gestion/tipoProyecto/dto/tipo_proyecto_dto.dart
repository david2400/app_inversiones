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

  /// Nivel de riesgo (ver `NivelRiesgo`); nulo = sin definir.
  String? riesgo;

  /// Proyectos activos de este tipo (solo lectura, lo calcula el handler).
  int cantidadProyectos;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  TipoProyectoDto(
      {this.idTipoProyecto,
      required this.nombre,
      required this.descripcion,
      this.riesgo,
      this.cantidadProyectos = 0,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory TipoProyectoDto.fromJson(Map<String, dynamic> json) =>
      TipoProyectoDto(
        idTipoProyecto: json["id_tipo_proyecto"],
        nombre: json["nombre"],
        descripcion: json["descripcion"] ?? '',
        riesgo: json["riesgo"],
        cantidadProyectos: json["cantidad_proyectos"] ?? 0,
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
