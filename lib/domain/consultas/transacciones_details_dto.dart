import 'dart:convert';

import 'package:inversiones/domain/models/tipo_fuente.dart';

List<TransaccionDetailsDto> TransaccionDetailsDtoModelFromJson(String str) =>
    List<TransaccionDetailsDto>.from(
        json.decode(str).map((x) => TransaccionDetailsDto.fromJson(x)));

String TransaccionDetailsDtoModelToJson(List<TransaccionDetailsDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TransaccionDetailsDto {
  int? idTransferencia;
  int valor;
  int? impuesto;
  int? destinoCuentaId;
  String? destinoCuenta;
  int tipoTransferenciaId;
  String tipoTransferencia;
  int? motivoId;
  String? motivo;
  String? destinoAlternativo;
  String? descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  /// Portafolio del que sale el dinero (o al que entra, si es ingreso).
  int? origenId;
  String? origen;

  /// Quién pagó (ingreso) o a quién se pagó (egreso / transferencia externa).
  int? terceroId;
  String? tercero;

  /// Naturaleza contable del tipo de transacción (`tipo_fuente`):
  /// [TipoFuente.ingreso], [TipoFuente.egreso] o [TipoFuente.transferencia].
  String? naturaleza;

  TransaccionDetailsDto(
      {this.idTransferencia,
      required this.valor,
      this.impuesto,
      required this.tipoTransferenciaId,
      required this.tipoTransferencia,
      this.motivoId,
      this.motivo,
      this.destinoCuentaId,
      this.destinoCuenta,
      this.destinoAlternativo,
      this.descripcion,
      this.createdAt,
      this.updatedAt,
      this.deleteAt,
      this.origenId,
      this.origen,
      this.terceroId,
      this.tercero,
      this.naturaleza});

  /// Destino legible: portafolio propio o cuenta externa.
  String? get destinoDescripcion => destinoCuenta ?? destinoAlternativo;

  bool get esIngreso => naturaleza == TipoFuente.ingreso;

  /// De dónde salió el dinero. Ingreso: quien pagó (o el motivo);
  /// egreso/transferencia: la cuenta de origen.
  String? get desde => esIngreso ? (tercero ?? motivo) : origen;

  /// A dónde llegó el dinero. Ingreso: la cuenta que recibe;
  /// egreso/transferencia: cuenta destino, tercero o cuenta externa.
  String? get hacia => esIngreso
      ? origen
      : (destinoCuenta ?? tercero ?? destinoAlternativo ?? motivo);

  factory TransaccionDetailsDto.fromJson(Map<String, dynamic> json) {
    return TransaccionDetailsDto(
      idTransferencia: json['id_transferencia'],
      valor: json['valor'],
      impuesto: json['impuesto'],
      tipoTransferenciaId: json['tipo_transferencia_id'],
      tipoTransferencia: json['tipo_transaccion'],
      motivoId: json['motivo_id'],
      motivo: json['motivo'],
      destinoCuentaId: json['destino_cuenta_id'],
      destinoCuenta: json['destino_cuenta'],
      destinoAlternativo: json['destino_alternativo'],
      descripcion: json['descripcion'],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      deleteAt: json["deleted_at"],
      origenId: json['origen_id'],
      origen: json['origen'],
      terceroId: json['tercero_id'],
      tercero: json['tercero'],
      naturaleza: json['tipo_fuente'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id_transferencia": idTransferencia,
        "valor": valor,
        "impuesto": impuesto,
        "tipo_transferencia_id": tipoTransferenciaId,
        "tipo_transferencia": tipoTransferencia,
        "motivo_id": motivoId,
        "motivo": motivo,
        "destino_cuenta_id": destinoCuentaId,
        "destino_cuenta": destinoCuenta,
        "destino_alternativo": destinoAlternativo,
        "descripcion": descripcion,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
        "origen_id": origenId,
        "origen": origen,
        "tercero_id": terceroId,
        "tercero": tercero,
        "tipo_fuente": naturaleza,
      };
}
