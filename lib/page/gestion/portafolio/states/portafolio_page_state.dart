import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/gestion/portafolio/page/portafolio_page.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_balance_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class PortafolioPageState extends FlutterFlowModel<PortafolioPage> {
  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}


  Future<List<PortafolioDto>> listarPortafolio(int idProyecto) async {
    try {
      IPortafolio portafolioHandler = PortafolioHandler();

      List<PortafolioDto> result = await portafolioHandler.listarPortafolioByProyecto(widget.idProyecto);

      return result.isEmpty ? [] : result;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransaccionBalanceDto>> getBalanceProyecto(
      int idProyecto) async {
    try {
      ITransaccion transaccionHandler = TransaccionHandler();

      List<TransaccionBalanceDto> result =
          await transaccionHandler.getBalanceByProyectoId(idProyecto);

      return result.isEmpty ? [] : result;
    } catch (e) {
      rethrow;
    }
  }
}
