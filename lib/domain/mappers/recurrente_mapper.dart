import 'package:inversiones/domain/entity/recurrente_detalle_entity.dart';
import 'package:inversiones/page/recurrentes/dto/recurrente_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'recurrente_mapper.mapper.g.dart';

@Mapper()
abstract class RecurrenteMappr {
  RecurrenteDto fromDetalle(RecurrenteDetalle model);
}
