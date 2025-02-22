// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frecuencia_pago_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class FrecuenciaPagoMapprImpl extends FrecuenciaPagoMappr {
  FrecuenciaPagoMapprImpl() : super();

  @override
  FrecuenciaPago fromModel(FrecuenciaPagoDto model) {
    final frecuenciapago = FrecuenciaPago(
      idFrecuenciaPago: model.idFrecuenciaPago,
      tiempo: model.tiempo,
      formato: model.formato,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return frecuenciapago;
  }

  @override
  FrecuenciaPagoDto fromDto(FrecuenciaPago model) {
    final frecuenciapagodto = FrecuenciaPagoDto(
      idFrecuenciaPago: model.idFrecuenciaPago,
      tiempo: model.tiempo,
      formato: model.formato,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return frecuenciapagodto;
  }
}
