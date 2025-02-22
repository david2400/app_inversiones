import 'package:inversiones/domain/entity/usuario_entity.dart';
import 'package:inversiones/page/account/profile/dto/usuario_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'usuario_mapper.mapper.g.dart';

@Mapper()
abstract class UsuarioMappr {
  Usuario fromModel(UsuarioDto model);

  UsuarioDto fromDto(Usuario model);

  // List<Usuario> fromListDto(List<UsuarioDto> model);

}
