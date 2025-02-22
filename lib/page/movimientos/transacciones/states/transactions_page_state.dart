import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_portafolio_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/page/transactions_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';


class TransactionsPageState extends FlutterFlowModel<TransactionsPage> {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<TransaccionDto>> listarTransaccionesByPortafolio(int idPortafolio) async {
    try {
      ITransaccion portafolioHandler = TransaccionHandler();

      List<TransaccionDto> result = await portafolioHandler.listaTransaccionesByPortafolio(idPortafolio);

      return result.isEmpty ? [] : result;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransaccionPortafolioDto>> listaTransaccionByPortafolioId(
      int idProyecto) async {
    try {
      ITransaccion transaccionHandler = TransaccionHandler();

      List<TransaccionPortafolioDto> result =
      await transaccionHandler.listaTransaccionByPortafolioId(idProyecto);

      return result.isEmpty ? [] : result;
    } catch (e) {
      rethrow;
    }
  }
}
