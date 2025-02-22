import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/tipo_transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_transaccion_interface.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/page/admin_tipo_transaccion.dart';
import 'package:inversiones/ui/utils/form_field_controller.dart';

import 'package:inversiones/ui/utils/flutter_flow_util.dart';

class AdminTipoTransaccionPageState
    extends FlutterFlowModel<AdminTipoTransaccionPage> {
  FocusNode? nombreFocus;
  String? nombre;
  TextEditingController? nombreController;

  FocusNode? descripcionFocus;
  String? descripcion;
  TextEditingController? descripcionController;

  String? tipoFuente;
  FormFieldController<String>? tipoFuenteController;

  TipoTransaccionDto _initDataTipoTransaccion() {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return TipoTransaccionDto(
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        tipoFuente: tipoFuente!,
        createdAt: formattedDateTime);
  }

  Future<int> insertTipoTransaccion() async {
    try {
      TipoTransaccionDto tipoTransaccion = _initDataTipoTransaccion();
      ITipoTransaccion tipoTransaccionHandler = TipoTransaccionHandler();

      int result =
          await tipoTransaccionHandler.createTipoTransaccion(tipoTransaccion);

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

    tipoFuenteController?.dispose();
  }
}
