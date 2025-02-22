import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inversiones/infraestructure/handler/implementations/frecuencia_pago_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/frecuencia_pago_interface.dart';
import 'package:inversiones/page/frecuenciaPago/dto/frecuencia_pago_dto.dart';
import 'package:inversiones/page/frecuenciaPago/page/admin_frecuencia_pago_page.dart';
import 'package:inversiones/ui/utils/form_field_controller.dart';

import 'package:inversiones/ui/utils/flutter_flow_util.dart';

class AdminFrecuenciaPagoPageState
    extends FlutterFlowModel<AdminFrecuenciaPagoPage> {
  FocusNode? tiempoFocus;
  int? tiempo;
  FormFieldController<int>? tiempoController;

  FocusNode? formatoFocus;
  String? formato;
  FormFieldController<String>? formatoController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tiempoFocus?.dispose();
    tiempoController?.dispose();

    formatoFocus?.dispose();
    formatoController?.dispose();
  }

  FrecuenciaPagoDto _initDataFrecunciaPago() {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return FrecuenciaPagoDto(
        tiempo: tiempo!, formato: formato!, createdAt: formattedDateTime);
  }

  Future<int> insertFrecuenciaPago() async {
    try {
      FrecuenciaPagoDto frecuenciaPago = _initDataFrecunciaPago();
      IFrecuenciaPago frecuenciapagoHandler = FrecuenciaPagoHandler();
      int result =
          await frecuenciapagoHandler.createFrecuenciaPago(frecuenciaPago);

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
