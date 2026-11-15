// To parse this JSON data, do
//
//     final populationModel = populationModelFromJson(jsonString);

import 'dart:convert';

List<TipoTransaccionDto> tipoTransaccionDtoModelFromJson(String str) =>
    List<TipoTransaccionDto>.from(
        json.decode(str).map((x) => TipoTransaccionDto.fromJson(x)));

String tipoTransaccionDtoModelToJson(List<TipoTransaccionDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TipoTransaccionDto {
  int? idTipoTransaccion;
  String nombre;
  String descripcion;
  String tipoFuente;

  /// Lo usa la app (uno por naturaleza): protegido.
  bool esSistema;

  /// Visible en los formularios.
  bool activo;

  /// Movimientos activos de este tipo (solo lectura).
  int cantidadMovimientos;

  /// Suma del valor de esos movimientos (solo lectura).
  int totalMovido;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  TipoTransaccionDto(
      {this.idTipoTransaccion,
      required this.nombre,
      required this.descripcion,
      required this.tipoFuente,
      this.esSistema = false,
      this.activo = true,
      this.cantidadMovimientos = 0,
      this.totalMovido = 0,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory TipoTransaccionDto.fromJson(Map<String, dynamic> json) =>
      TipoTransaccionDto(
        idTipoTransaccion: json["id_tipo_transaccion"],
        nombre: json["nombre"],
        tipoFuente: json["tipo_fuente"],
        descripcion: json["descripcion"] ?? '',
        esSistema: json["es_sistema"] == 1,
        activo: (json["activo"] ?? 1) == 1,
        cantidadMovimientos: json["cantidad_movimientos"] ?? 0,
        totalMovido: json["total_movido"] ?? 0,
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_tipo_transaccion": idTipoTransaccion,
        "nombre": nombre,
        "descripcion": descripcion,
        "tipo_fuente": tipoFuente,
        "es_sistema": esSistema ? 1 : 0,
        "activo": activo ? 1 : 0,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
