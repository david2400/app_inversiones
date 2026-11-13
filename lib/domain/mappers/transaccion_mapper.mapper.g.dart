// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaccion_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class TransaccionMapprImpl extends TransaccionMappr {
  TransaccionMapprImpl() : super();

  @override
  Transaccion fromModel(TransaccionDto model) {
    final transaccion = Transaccion(
      idTransferencia: model.idTransferencia,
      valor: model.valor,
      impuesto: model.impuesto,
      tipoTransferenciaId: model.tipoTransferenciaId,
      motivoId: model.motivoId,
      portafolioId: model.portafolioId,
      destinoCuenta: model.destinoCuenta,
      destinoAlternativo: model.destinoAlternativo,
      terceroId: model.terceroId,
      descripcion: model.descripcion,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return transaccion;
  }

  @override
  TransaccionDto fromDto(Transaccion model) {
    final transacciondto = TransaccionDto(
      idTransferencia: model.idTransferencia,
      valor: model.valor,
      impuesto: model.impuesto,
      tipoTransferenciaId: model.tipoTransferenciaId,
      motivoId: model.motivoId,
      portafolioId: model.portafolioId,
      destinoCuenta: model.destinoCuenta,
      destinoAlternativo: model.destinoAlternativo,
      terceroId: model.terceroId,
      descripcion: model.descripcion,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return transacciondto;
  }
}
