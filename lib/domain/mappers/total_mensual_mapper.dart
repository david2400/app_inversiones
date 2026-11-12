import 'package:inversiones/domain/entity/total_mensual_entity.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'total_mensual_mapper.mapper.g.dart';

@Mapper()
abstract class TotalMensualMappr {
  TotalMensualDto fromDto(TotalMensual model);
}
