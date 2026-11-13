import 'package:inversiones/domain/entity/total_por_motivo_entity.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'total_por_motivo_mapper.mapper.g.dart';

@Mapper()
abstract class TotalPorMotivoMappr {
  TotalPorMotivoDto fromDto(TotalPorMotivo model);
}
