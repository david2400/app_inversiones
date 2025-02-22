
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';

abstract class ITipoTransaccion {
  Future<int> createTipoTransaccion(TipoTransaccionDto tipoTransaccionDto);
  Future<int> deleteTipoTransaccion(int id);
  Future<List<TipoTransaccionDto>> listarTipoTransaccion();


}
