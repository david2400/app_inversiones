// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrente_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class RecurrenteMapprImpl extends RecurrenteMappr {
  RecurrenteMapprImpl() : super();

  @override
  RecurrenteDto fromDetalle(RecurrenteDetalle model) {
    final recurrentedto = RecurrenteDto(
      idRecurrente: model.idRecurrente,
      nombre: model.nombre,
      tipo: model.tipo,
      tipoFuente: model.tipoFuente,
      origen: model.origen,
      destino: model.destino,
      motivo: model.motivo,
      tercero: model.tercero,
      valor: model.valor,
      diaMes: model.diaMes,
      activo: model.activo,
      registradoEnMes: model.registradoEnMes,
    );
    return recurrentedto;
  }
}
