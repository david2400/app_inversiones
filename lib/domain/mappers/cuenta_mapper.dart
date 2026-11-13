import 'package:inversiones/domain/entity/cuenta_entity.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'cuenta_mapper.mapper.g.dart';

@Mapper()
abstract class CuentaMappr {
  Cuenta fromModel(CuentaDto model);

  CuentaDto fromDto(Cuenta model);
}
