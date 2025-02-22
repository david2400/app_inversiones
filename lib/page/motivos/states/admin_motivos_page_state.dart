import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/motivo_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/motivo_interface.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:inversiones/page/motivos/page/admin_motivos_page.dart';

import 'package:inversiones/ui/utils/flutter_flow_util.dart';


class AdminMotivosPageState extends FlutterFlowModel<AdminMotivosPage> {
  FocusNode? nombreFocus;
  TextEditingController? nombreController;

  FocusNode? descripcionFocus;
  TextEditingController? descripcionController;


  MotivosDto _initDataMotivos() {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return MotivosDto(
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        createdAt: formattedDateTime);
  }

  Future<int> insertMotivo() async {
    try {
      MotivosDto motivos = _initDataMotivos();
      IMotivo motivosHandler = MotivoHandler();
      int result = await motivosHandler.createMotivo(motivos);

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
