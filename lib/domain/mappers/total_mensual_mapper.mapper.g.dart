// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'total_mensual_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class TotalMensualMapprImpl extends TotalMensualMappr {
  TotalMensualMapprImpl() : super();

  @override
  TotalMensualDto fromDto(TotalMensual model) {
    final totalmensualdto = TotalMensualDto(
      periodo: model.periodo,
      ingresos: model.ingresos,
      egresos: model.egresos,
      impuestos: model.impuestos,
    );
    return totalmensualdto;
  }
}
