import 'dart:convert';

List<FrecuenciaPago> frecuenciaPagoModelFromJson(String str) =>
    List<FrecuenciaPago>.from(
        json.decode(str).map((x) => FrecuenciaPago.fromJson(x)));

String frecuenciaPagoModelToJson(List<FrecuenciaPago> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FrecuenciaPago {
  int? idFrecuenciaPago;
  int tiempo;
  String formato;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  FrecuenciaPago(
      {this.idFrecuenciaPago,
      required this.tiempo,
      required this.formato,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory FrecuenciaPago.fromJson(Map<String, dynamic> json) => FrecuenciaPago(
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
