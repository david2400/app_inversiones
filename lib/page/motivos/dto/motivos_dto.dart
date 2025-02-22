import 'dart:convert';

List<MotivosDto> motivosDtoModelFromJson(String str) =>
    List<MotivosDto>.from(json.decode(str).map((x) => MotivosDto.fromJson(x)));

String motivosDtoModelToJson(List<MotivosDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MotivosDto {
  int? idMotivo;
  String nombre;
  String descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  MotivosDto(
      {this.idMotivo,
      required this.nombre,
      required this.descripcion,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory MotivosDto.fromJson(Map<String, dynamic> json) => MotivosDto(
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
