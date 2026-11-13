import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/tipo_transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_transaccion_interface.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/page/tipo_transaccion.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';
import 'package:inversiones/ui/utils/flutter_fluw_datatable.dart';

// import '../../../backend/schema/firebase/backend.dart';
// import '/components/pause_card/pause_card_widget.dart';


class TipoTransaccionPageState extends FlutterFlowModel<TipoTransaccionPage> {
  final unfocusNode = FocusNode();
  final paginatedDataTableController =
  FlutterFlowDataTableController<dynamic>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}


  Future<List<TipoTransaccionDto>> listarTipoTransaccion() async {
    try {
      ITipoTransaccion tipoTransaccionHandler = TipoTransaccionHandler();

      List<TipoTransaccionDto> result =
      await tipoTransaccionHandler.listarTipoTransaccion();

      return result;
    } catch (e) {
      rethrow;
    }
  }

}
