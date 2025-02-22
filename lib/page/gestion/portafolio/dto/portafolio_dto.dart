import 'dart:convert';

List<PortafolioDto> portafolioDtoModelFromJson(String str) =>
    List<PortafolioDto>.from(
        json.decode(str).map((x) => PortafolioDto.fromJson(x)));

String portafolioDtoModelToJson(List<PortafolioDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PortafolioDto {
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

  PortafolioDto(
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

  factory PortafolioDto.fromJson(Map<String, dynamic> json) => PortafolioDto(
        idPortafolio: json["id_portafolio"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        nroCuenta: json["nro_cuenta"],
        tipoRenta: json["tipo_renta"],
        proyectoId: json["proyecto_id"],
        tipoPortafolioId: json["tipo_portafolio_id"],
        interes: json["interes"],
        total: json["total"],
        exentaImpuesto: json["exenta_impuesto"],
        frecuenciaPagoId: json["frecuencia_pago_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_portafolio": idPortafolio,
        "nombre": nombre,
        "descripcion": descripcion,
        "nro_cuenta": nroCuenta,
        "tipo_renta": tipoRenta,
        "proyecto_id": proyectoId,
        "interes": interes,
        "total": total,
        "exenta_impuesto": exentaImpuesto,
        "frecuencia_pago_id": frecuenciaPagoId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
