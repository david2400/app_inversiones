

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
  Future<int> calcular4xMill(DateTime date);
}
