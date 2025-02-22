import 'package:inversiones/domain/entity/motivos_entity.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'motivos_mapper.mapper.g.dart';

@Mapper()
abstract class MotivoMappr {
  Motivos fromModel(MotivosDto model);

  MotivosDto fromDto(Motivos model);

  // List<Motivos> fromListDto(List<MotivosDto> model);

}
