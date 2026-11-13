import 'package:flutter/material.dart';

import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/domain/consultas/transacciones_details_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/page/transaction_detail_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class TransactionDetailPageState extends FlutterFlowModel<TransactionDetailPage> {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<TransaccionDetailsDto> findTransaccionDetails(int id) async {
    try {
      ITransaccion transaccionHandler = TransaccionHandler();

      TransaccionDetailsDto result =
      await transaccionHandler.findTransaccionDetails(id);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Anula (borrado lógico) el movimiento. Un movimiento registrado no se
  /// edita: para corregirlo se anula y se registra de nuevo.
  Future<void> anularTransaccion(int id) async {
    try {
      ITransaccion transaccionHandler = TransaccionHandler();
      await transaccionHandler.deleteTransaccion(id);
    } catch (e) {
      rethrow;
    }
  }
}
