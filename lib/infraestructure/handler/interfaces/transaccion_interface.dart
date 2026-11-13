

import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_balance_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_portafolio_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transacciones_details_dto.dart';

abstract class ITransaccion {
  Future<int> createTransaccion(TransaccionDto transaccionDto);
  Future<int> updateTransaccion(TransaccionDto transaccionDto);
  Future<int> deleteTransaccion(int id);
  Future<List<TransaccionDto>> listaTransacciones();
  Future<List<TransaccionBalanceDto>> getBalanceByProyectoId(int portafolioId);
  Future<List<TransaccionPortafolioDto>> listaTransaccionByPortafolioId(int id);
  Future<List<TransaccionDto>> listaTransaccionesByPortafolio(int id);
  Future<TransaccionDto> findTransaccion(int id);
  Future<TransaccionDetailsDto> findTransaccionDetails(int id);
  Future<List<TransaccionBalanceDto>> findTransaccionesByMesAndAnio(String year,String month);

  /// GMF (4x1000) de un movimiento según su tipo y la exención del
  /// portafolio origen.
  int calcularGmf(
      {required int valor,
      required String tipoFuente,
      required String? exentaImpuesto});
}
