import 'dart:convert';

import 'package:inversiones/domain/consultas/transacciones_details_dto.dart';


List<TransaccionPortafolioDto> transaccionPortafolioDtoModelFromJson(
        String str) =>
    List<TransaccionPortafolioDto>.from(
        json.decode(str).map((x) => TransaccionPortafolioDto.fromJson(x)));

String transaccionPortafolioDtoModelToJson(
        List<TransaccionPortafolioDto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TransaccionPortafolioDto extends TransaccionDetailsDto {
  String tipoFuente;

  static const _sinDato = '—';

  /// Recorrido del dinero en texto: "de dónde → a dónde".
  /// Ingreso: tercero (o motivo) → cuenta que recibe.
  /// Egreso/transferencia: cuenta de origen → cuenta destino, tercero o
  /// cuenta externa.
  String get flujo => '${desde ?? _sinDato} → ${hacia ?? _sinDato}';

  /// La naturaleza de esta consulta viene en [tipoFuente] (no nulo).
  @override
  String? get naturaleza => tipoFuente;

  TransaccionPortafolioDto({
    int? idTransferencia,
    required int valor,
    int? impuesto,
    int? destinoCuentaId,
    String? destinoCuenta,
    required int tipoTransferenciaId,
    required String tipoTransferencia,
    int? motivoId,
    String? motivo,
    String? destinoAlternativo,
    String? descripcion,
    String? createdAt,
    String? updatedAt,
    String? deleteAt,
    int? origenId,
    String? origen,
    int? terceroId,
    String? tercero,
    required this.tipoFuente,
  }) : super(
          idTransferencia: idTransferencia,
          valor: valor,
          impuesto: impuesto,
          destinoCuentaId: destinoCuentaId,
          destinoCuenta: destinoCuenta,
          tipoTransferenciaId: tipoTransferenciaId,
          tipoTransferencia: tipoTransferencia,
          motivoId: motivoId,
          motivo: motivo,
          destinoAlternativo: destinoAlternativo,
          descripcion: descripcion,
          createdAt: createdAt,
          updatedAt: updatedAt,
          deleteAt: deleteAt,
          origenId: origenId,
          origen: origen,
          terceroId: terceroId,
          tercero: tercero,
        );

  factory TransaccionPortafolioDto.fromJson(Map<String, dynamic> json) {
    return TransaccionPortafolioDto(
      idTransferencia: json['id_transferencia'],
      valor: json['valor'],
      impuesto: json['impuesto'],
      destinoCuentaId: json['destino_cuenta_id'],
      destinoCuenta: json['destino_cuenta'],
      tipoTransferenciaId: json['tipo_transferencia_id'],
      tipoTransferencia: json['tipo_transaccion'],
      motivoId: json['motivo_id'],
      motivo: json['motivo'],
      destinoAlternativo: json['destino_alternativo'],
      descripcion: json['descripcion'],
      tipoFuente: json['tipo_fuente'],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      deleteAt: json["deleted_at"],
      origenId: json['origen_id'],
      origen: json['origen'],
      terceroId: json['tercero_id'],
      tercero: json['tercero'],
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
        "tipo_fuente": tipoFuente,
        "origen_id": origenId,
        "origen": origen,
        "tercero_id": terceroId,
        "tercero": tercero,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
