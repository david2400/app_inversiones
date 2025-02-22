// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proyecto_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class ProyectoMapprImpl extends ProyectoMappr {
  ProyectoMapprImpl() : super();

  @override
  Proyecto fromModel(ProyectoDto model) {
    final proyecto = Proyecto(
      idProyecto: model.idProyecto,
      nombre: model.nombre,
      descripcion: model.descripcion,
      usuarioId: model.usuarioId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return proyecto;
  }

  @override
  ProyectoDto fromDto(Proyecto model) {
    final proyectodto = ProyectoDto(
      idProyecto: model.idProyecto,
      nombre: model.nombre,
      descripcion: model.descripcion,
      usuarioId: model.usuarioId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return proyectodto;
  }
}
