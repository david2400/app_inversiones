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
  int? proyectoId;
  int? tipoPortafolioId;
  int? interes;
  int? total;
  String? exentaImpuesto;
  int? frecuenciaPagoId;
  String? descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;
  /// Cuenta a la que pertenece (excluyente con [proyectoId]).
  int? cuentaId;

  /// Si es el portafolio principal de su cuenta.
  bool esPrincipal;

  /// Cuenta de donde salen los aportes (nula = Efectivo / Sin definir).
  int? cuentaAportesId;

  /// Cuenta donde llegan los rendimientos (nula = la de aportes).
  int? cuentaDestinoId;

  PortafolioDto(
      {this.idPortafolio,
      required this.nombre,
      this.nroCuenta,
      this.tipoRenta,
      this.proyectoId,
      this.tipoPortafolioId,
      this.interes,
      this.total,
      this.exentaImpuesto,
      this.frecuenciaPagoId,
      this.descripcion,
      this.createdAt,
      this.updatedAt,
      this.deleteAt,
      this.cuentaId,
      this.esPrincipal = false,
      this.cuentaAportesId,
      this.cuentaDestinoId});

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
        cuentaId: json["cuenta_id"],
        esPrincipal: json["es_principal"] == 1,
        cuentaAportesId: json["cuenta_aportes_id"],
        cuentaDestinoId: json["cuenta_destino_id"],
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
        "cuenta_id": cuentaId,
        "es_principal": esPrincipal ? 1 : 0,
        "cuenta_aportes_id": cuentaAportesId,
        "cuenta_destino_id": cuentaDestinoId,
      };
}
