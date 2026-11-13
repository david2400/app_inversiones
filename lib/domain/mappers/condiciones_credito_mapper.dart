import 'package:inversiones/domain/entity/condiciones_credito_entity.dart';
import 'package:inversiones/page/cuentas/dto/deuda_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'condiciones_credito_mapper.mapper.g.dart';

@Mapper()
abstract class CondicionesCreditoMappr {
  CondicionesCredito fromModel(CondicionesCreditoDto model);

  CondicionesCreditoDto fromDto(CondicionesCredito model);
}
