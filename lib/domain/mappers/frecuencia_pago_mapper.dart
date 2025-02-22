import 'package:inversiones/domain/entity/frecuencia_pago_entity.dart';
import 'package:inversiones/page/frecuenciaPago/dto/frecuencia_pago_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'frecuencia_pago_mapper.mapper.g.dart';

@Mapper()
abstract class FrecuenciaPagoMappr {
  FrecuenciaPago fromModel(FrecuenciaPagoDto model);

  FrecuenciaPagoDto fromDto(FrecuenciaPago model);

  // List<FrecuenciaPago> fromListDto(List<FrecuenciaPagoDto> model);
}
