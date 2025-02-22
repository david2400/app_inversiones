import 'dart:convert';

List<Portafolio> portafolioModelFromJson(String str) =>
    List<Portafolio>.from(json.decode(str).map((x) => Portafolio.fromJson(x)));

String portafolioModelToJson(List<Portafolio> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Portafolio {
  int? idPortafolio;
  String nombre;
  String? nroCuenta;
  String? tipoRenta;
  int proyectoId;
  int tipoPortafolioId;
  int? interes;
  int? total;
  String? exentaImpuesto;
  int? frecuenciaPagoId;
  String? descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  Portafolio(
      {this.idPortafolio,
      required this.nombre,
      this.nroCuenta,
      this.tipoRenta,
      required this.proyectoId,
      required this.tipoPortafolioId,
      this.interes,
      this.total,
      this.exentaImpuesto,
      this.frecuenciaPagoId,
      this.descripcion,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory Portafolio.fromJson(Map<String, dynamic> json) => Portafolio(
        idPortafolio: json["id_portafolio"],
        nombre: json["nombre"],
        nroCuenta: json["nro_cuenta"],
        tipoRenta: json["tipo_renta"],
        proyectoId: json["proyecto_id"],
        tipoPortafolioId: json["tipo_portafolio_id"],
        interes: json["interes"],
        total: json["total"],
        exentaImpuesto: json["exenta_impuesto"],
        frecuenciaPagoId: json["frecuencia_pago_id"],
        descripcion: json["descripcion"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_portafolio": idPortafolio,
        "nombre": nombre,
        "nro_cuenta": nroCuenta,
        "tipo_renta": tipoRenta,
        "proyecto_id": proyectoId,
        "tipo_portafolio_id": tipoPortafolioId,
        "interes": interes,
        "total": total ?? 0,
        "exenta_impuesto": exentaImpuesto ?? 'N',
        "frecuencia_pago_id": frecuenciaPagoId,
        "descripcion": descripcion,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
