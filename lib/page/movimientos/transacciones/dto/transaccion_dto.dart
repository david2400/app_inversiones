import 'dart:convert';

List<TransaccionDto> transaccionDtoModelFromJson(String str) =>
    List<TransaccionDto>.from(
        json.decode(str).map((x) => TransaccionDto.fromJson(x)));

String transaccionDtoModelToJson(List<TransaccionDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TransaccionDto {
  int? idTransferencia;
  int valor;
  int? impuesto;
  int tipoTransferenciaId;
  int? motivoId;
  int portafolioId;
  int? destinoCuenta;
  String? destinoAlternativo;
  String? descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  TransaccionDto(
      {this.idTransferencia,
      required this.valor,
      this.impuesto,
      required this.tipoTransferenciaId,
      this.motivoId,
      required this.portafolioId,
      this.destinoCuenta,
      this.destinoAlternativo,
      this.descripcion,
      this.createdAt,
      this.updatedAt,
      this.deleteAt});

  factory TransaccionDto.fromJson(Map<String, dynamic> json) => TransaccionDto(
        idTransferencia: json["id_transferencia"],
        valor: json["valor"],
        impuesto: json["impuesto"],
        tipoTransferenciaId: json["tipo_transferencia_id"],
        motivoId: json["motivo_id"],
        portafolioId: json["portafolio_id"],
        destinoCuenta: json["destino_cuenta"],
        destinoAlternativo: json["destino_alternativo"],
        descripcion: json["descripcion"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_transferencia": idTransferencia,
        "valor": valor,
        "impuesto": impuesto,
        "tipo_transferencia_id": tipoTransferenciaId,
        "motivo_id": motivoId,
        "portafolio_id": portafolioId,
        "destino_cuenta": destinoCuenta,
        "destino_alternativo": destinoAlternativo,
        "descripcion": descripcion,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
