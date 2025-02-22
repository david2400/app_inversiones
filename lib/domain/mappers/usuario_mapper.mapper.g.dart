// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class UsuarioMapprImpl extends UsuarioMappr {
  UsuarioMapprImpl() : super();

  @override
  Usuario fromModel(UsuarioDto model) {
    final usuario = Usuario(
      idUsuario: model.idUsuario,
      nombre: model.nombre,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return usuario;
  }

  @override
  UsuarioDto fromDto(Usuario model) {
    final usuariodto = UsuarioDto(
      idUsuario: model.idUsuario,
      nombre: model.nombre,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return usuariodto;
  }
}
