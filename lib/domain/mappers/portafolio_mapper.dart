import 'package:inversiones/domain/entity/portafolio_entity.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'portafolio_mapper.mapper.g.dart';

@Mapper()
abstract class PortafolioMappr {
  Portafolio fromModel(PortafolioDto model);

  PortafolioDto fromDto(Portafolio model);

  // List<Portafolio> fromListDto(List<PortafolioDto> model);

}
