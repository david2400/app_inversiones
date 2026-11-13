// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tercero_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class TerceroMapprImpl extends TerceroMappr {
  TerceroMapprImpl() : super();

  @override
  Tercero fromModel(TerceroDto model) {
    final tercero = Tercero(
      idTercero: model.idTercero,
      nombre: model.nombre,
      descripcion: model.descripcion,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return tercero;
  }

  @override
  TerceroDto fromDto(Tercero model) {
    final tercerodto = TerceroDto(
      idTercero: model.idTercero,
      nombre: model.nombre,
      descripcion: model.descripcion,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return tercerodto;
  }
}
