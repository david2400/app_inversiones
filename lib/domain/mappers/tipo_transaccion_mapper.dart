import 'package:inversiones/domain/entity/tipo_transaccion_entity.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'tipo_transaccion_mapper.mapper.g.dart';

@Mapper()
abstract class TipoTransaccionMappr {
  TipoTransaccion fromModel(TipoTransaccionDto model);

  TipoTransaccionDto fromDto(TipoTransaccion model);

  // List<TipoTransaccion> fromListDto(List<TipoTransaccionDto> model);
}
