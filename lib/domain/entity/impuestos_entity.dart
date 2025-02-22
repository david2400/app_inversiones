import 'dart:convert';

List<Impuestos> motivosModelFromJson(String str) =>
    List<Impuestos>.from(json.decode(str).map((x) => Impuestos.fromJson(x)));

String motivosModelToJson(List<Impuestos> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Impuestos {
  int? idImpuesto;
  int total;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  Impuestos(
      {this.idImpuesto,
      required this.total,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory Impuestos.fromJson(Map<String, dynamic> json) => Impuestos(
        idImpuesto: json["id_impuesto"],
        total: json["total"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_impuesto": idImpuesto,
        "total": total,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
