// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'total_por_motivo_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class TotalPorMotivoMapprImpl extends TotalPorMotivoMappr {
  TotalPorMotivoMapprImpl() : super();

  @override
  TotalPorMotivoDto fromDto(TotalPorMotivo model) {
    final totalpormotivodto = TotalPorMotivoDto(
      idMotivo: model.idMotivo,
      nombre: model.nombre,
      total: model.total,
      cantidad: model.cantidad,
    );
    return totalpormotivodto;
  }
}
