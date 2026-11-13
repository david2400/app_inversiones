import 'package:inversiones/domain/entity/flujo_entre_cuentas_entity.dart';
import 'package:inversiones/domain/entity/total_por_concepto_entity.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'total_por_concepto_mapper.mapper.g.dart';

@Mapper()
abstract class TotalPorConceptoMappr {
  TotalPorConceptoDto fromDto(TotalPorConcepto model);

  FlujoEntreCuentasDto fromFlujo(FlujoEntreCuentas model);
}
