import 'dart:convert';

List<TransaccionBalanceDto> transaccionBalanceDtoModelFromJson(String str) =>
    List<TransaccionBalanceDto>.from(
        json.decode(str).map((x) => TransaccionBalanceDto.fromJson(x)));

String transaccionDtoModelToJson(List<TransaccionBalanceDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TransaccionBalanceDto {
  int idTransferencia;
  int valor;
  int? impuesto;
  int portafolioId;
  int? proyectoId;
  String tipoFuente;
  int? destinoCuenta;
  String? destinoAlternativo;

  TransaccionBalanceDto({
    required this.idTransferencia,
    required this.valor,
    this.impuesto,
    required this.portafolioId,
    this.proyectoId,
    required this.tipoFuente,
    this.destinoCuenta,
    this.destinoAlternativo,
  });

  factory TransaccionBalanceDto.fromJson(Map<String, dynamic> json) =>
      TransaccionBalanceDto(
        idTransferencia: json["id_transferencia"],
        valor: json["valor"],
        impuesto: json["impuesto"],
        portafolioId: json["portafolio_id"],
        proyectoId: json["proyecto_id"],
        tipoFuente: json["tipo_fuente"],
        destinoCuenta: json["destino_cuenta"],
        destinoAlternativo: json["destino_alternativo"],
      );

  Map<String, dynamic> toJson() => {
        "id_transferencia": idTransferencia,
        "valor": valor,
        "impuesto": impuesto,
        "portafolio_id": portafolioId,
        "proyecto_id": proyectoId,
        "tipo_fuente": tipoFuente,
        "destino_cuenta": destinoCuenta,
        "destino_alternativo": destinoAlternativo,
      };
}
