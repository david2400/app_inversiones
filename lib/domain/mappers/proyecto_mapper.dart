import 'package:inversiones/domain/entity/proyecto_entity.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'proyecto_mapper.mapper.g.dart';

@Mapper()
abstract class  ProyectoMappr {
  Proyecto fromModel(ProyectoDto model);

  ProyectoDto fromDto(Proyecto model);

  // List<Proyecto> fromListDto(List<ProyectoDto> model);
}
