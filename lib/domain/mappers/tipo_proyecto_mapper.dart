import 'package:inversiones/domain/entity/tipo_proyecto_entity.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'tipo_proyecto_mapper.mapper.g.dart';

@Mapper()
abstract class TipoProyectoMappr {
  TipoProyecto fromModel(TipoProyectoDto model);

  TipoProyectoDto fromDto(TipoProyecto model);

  // List<TipoProyecto> fromListDto(List<TipoProyectoDto> model);
}
