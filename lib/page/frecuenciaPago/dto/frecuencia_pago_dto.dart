import 'dart:convert';

List<FrecuenciaPagoDto> frecuenciaPagoDtoModelFromJson(String str) =>
    List<FrecuenciaPagoDto>.from(
        json.decode(str).map((x) => FrecuenciaPagoDto.fromJson(x)));

String frecuenciaPagoDtoModelToJson(List<FrecuenciaPagoDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FrecuenciaPagoDto {
  int? idFrecuenciaPago;
  int tiempo;
  String formato;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  FrecuenciaPagoDto(
      {this.idFrecuenciaPago,
      required this.tiempo,
      required this.formato,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory FrecuenciaPagoDto.fromJson(Map<String, dynamic> json) =>
      FrecuenciaPagoDto(
        idFrecuenciaPago: json["id_frecuencia_pago"],
        tiempo: json["tiempo"],
        formato: json["formato"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_frecuencia_pago": idFrecuenciaPago,
        "tiempo": tiempo,
        "formato": formato,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
