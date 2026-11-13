import 'package:inversiones/domain/entity/tercero_entity.dart';
import 'package:inversiones/page/terceros/dto/tercero_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'tercero_mapper.mapper.g.dart';

@Mapper()
abstract class TerceroMappr {
  Tercero fromModel(TerceroDto model);

  TerceroDto fromDto(Tercero model);
}
