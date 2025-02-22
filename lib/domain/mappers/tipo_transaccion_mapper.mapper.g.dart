// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tipo_transaccion_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class TipoTransaccionMapprImpl extends TipoTransaccionMappr {
  TipoTransaccionMapprImpl() : super();

  @override
  TipoTransaccion fromModel(TipoTransaccionDto model) {
    final tipotransaccion = TipoTransaccion(
      idTipoTransaccion: model.idTipoTransaccion,
      nombre: model.nombre,
      descripcion: model.descripcion,
      tipoFuente: model.tipoFuente,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return tipotransaccion;
  }

  @override
  TipoTransaccionDto fromDto(TipoTransaccion model) {
    final tipotransacciondto = TipoTransaccionDto(
      idTipoTransaccion: model.idTipoTransaccion,
      nombre: model.nombre,
      descripcion: model.descripcion,
      tipoFuente: model.tipoFuente,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return tipotransacciondto;
  }
}
