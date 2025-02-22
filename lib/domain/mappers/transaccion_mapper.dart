import 'package:inversiones/domain/entity/transferencia_entity.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'transaccion_mapper.mapper.g.dart';

@Mapper()
abstract class TransaccionMappr {
  Transaccion fromModel(TransaccionDto model);

  TransaccionDto fromDto(Transaccion model);

  // List<Transaccion> fromListDto(List<TransaccionDto> model);

}
