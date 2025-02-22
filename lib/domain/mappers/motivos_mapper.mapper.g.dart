// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'motivos_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class MotivoMapprImpl extends MotivoMappr {
  MotivoMapprImpl() : super();

  @override
  Motivos fromModel(MotivosDto model) {
    final motivos = Motivos(
      idMotivo: model.idMotivo,
      nombre: model.nombre,
      descripcion: model.descripcion,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return motivos;
  }

  @override
  MotivosDto fromDto(Motivos model) {
    final motivosdto = MotivosDto(
      idMotivo: model.idMotivo,
      nombre: model.nombre,
      descripcion: model.descripcion,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return motivosdto;
  }
}
