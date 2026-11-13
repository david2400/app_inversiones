import 'dart:convert';

List<UpdatePortafolioDto> updatePortafolioDtoModelFromJson(String str) =>
    List<UpdatePortafolioDto>.from(
        json.decode(str).map((x) => UpdatePortafolioDto.fromJson(x)));

String UpdatePortafolioDtoModelToJson(List<UpdatePortafolioDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UpdatePortafolioDto {
  int idPortafolio;
  String? nombre;
  String? nroCuenta;
  String? tipoRenta;
  int? proyectoId;
  int? tipoPortafolioId;
  int? interes;
  int? total;
  String? exentaImpuesto;
  int? totalImpuesto;
  int? frecuenciaPagoId;
  String? descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  UpdatePortafolioDto(
      {required this.idPortafolio,
      this.nombre,
      this.nroCuenta,
      this.tipoRenta,
      this.proyectoId,
      this.tipoPortafolioId,
      this.interes,
      this.total,
      this.exentaImpuesto,
      this.totalImpuesto,
      this.frecuenciaPagoId,
      this.descripcion,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory UpdatePortafolioDto.fromJson(Map<String, dynamic> json) =>
      UpdatePortafolioDto(
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
        totalImpuesto: json["total_impuesto"],
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
        "total_impuesto": totalImpuesto,
        "frecuencia_pago_id": frecuenciaPagoId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
