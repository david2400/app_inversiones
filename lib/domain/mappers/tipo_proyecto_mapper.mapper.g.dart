// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tipo_proyecto_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class TipoProyectoMapprImpl extends TipoProyectoMappr {
  TipoProyectoMapprImpl() : super();

  @override
  TipoProyecto fromModel(TipoProyectoDto model) {
    final tipoproyecto = TipoProyecto(
      idTipoProyecto: model.idTipoProyecto,
      nombre: model.nombre,
      descripcion: model.descripcion,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return tipoproyecto;
  }

  @override
  TipoProyectoDto fromDto(TipoProyecto model) {
    final tipoproyectodto = TipoProyectoDto(
      idTipoProyecto: model.idTipoProyecto,
      nombre: model.nombre,
      descripcion: model.descripcion,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return tipoproyectodto;
  }
}
