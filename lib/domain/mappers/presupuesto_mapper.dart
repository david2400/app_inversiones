import 'package:inversiones/domain/entity/ejecucion_presupuesto_entity.dart';
import 'package:inversiones/page/presupuestos/dto/presupuesto_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'presupuesto_mapper.mapper.g.dart';

@Mapper()
abstract class PresupuestoMappr {
  EjecucionPresupuestoDto fromEjecucion(EjecucionPresupuesto model);
}
