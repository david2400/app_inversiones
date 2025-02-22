import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/tipo_proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_proyecto_interface.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/page/admin_tipo_transaccion.dart';

import 'package:inversiones/ui/utils/flutter_flow_util.dart';


class AdminTipoProyectoPageState
    extends FlutterFlowModel<AdminTipoTransaccionPage> {
  FocusNode? nombreFocus;
  TextEditingController? nombreController;

  FocusNode? descripcionFocus;
  TextEditingController? descripcionController;

  TipoProyectoDto _initDataTipoProyecto() {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return TipoProyectoDto(
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        createdAt: formattedDateTime);
  }

  Future<int> insertTipoProyecto() async {
    try {
      TipoProyectoDto tipoProyecto = _initDataTipoProyecto();
      ITipoProyecto tipoProyectoHandler = TipoProyectoHandler();
      int result = await tipoProyectoHandler.createTipoProyecto(tipoProyecto);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nombreFocus?.dispose();
    nombreController?.dispose();

    descripcionFocus?.dispose();
    descripcionController?.dispose();
  }
}
