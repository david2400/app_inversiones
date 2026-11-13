import 'package:inversiones/domain/entity/saldo_portafolio_entity.dart';
import 'package:inversiones/page/gestion/portafolio/dto/saldo_portafolio_dto.dart';
import 'package:smartstruct/smartstruct.dart';

part 'saldo_portafolio_mapper.mapper.g.dart';

@Mapper()
abstract class SaldoPortafolioMappr {
  SaldoPortafolioDto fromDto(SaldoPortafolio model);
}
