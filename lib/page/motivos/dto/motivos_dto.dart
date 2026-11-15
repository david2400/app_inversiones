import 'dart:convert';

List<MotivosDto> motivosDtoModelFromJson(String str) =>
    List<MotivosDto>.from(json.decode(str).map((x) => MotivosDto.fromJson(x)));

String motivosDtoModelToJson(List<MotivosDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MotivosDto {
  int? idMotivo;
  String nombre;
  String descripcion;

  /// `I` ingreso, `E` gasto; nulo = sirve para ambos (ver `TipoFuente`).
  String? naturaleza;

  /// Visible en los formularios.
  bool activo;

  /// Movimientos activos con este motivo (solo lectura).
  int cantidadMovimientos;

  /// Suma del valor de esos movimientos (solo lectura).
  int totalMovido;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  MotivosDto(
      {this.idMotivo,
      required this.nombre,
      required this.descripcion,
      this.naturaleza,
      this.activo = true,
      this.cantidadMovimientos = 0,
      this.totalMovido = 0,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory MotivosDto.fromJson(Map<String, dynamic> json) => MotivosDto(
        idMotivo: json["id_motivo"],
        nombre: json["nombre"],
        descripcion: json["descripcion"] ?? '',
        naturaleza: json["naturaleza"],
        activo: (json["activo"] ?? 1) == 1,
        cantidadMovimientos: json["cantidad_movimientos"] ?? 0,
        totalMovido: json["total_movido"] ?? 0,
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_motivo": idMotivo,
        "nombre": nombre,
        "descripcion": descripcion,
        "naturaleza": naturaleza,
        "activo": activo ? 1 : 0,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
