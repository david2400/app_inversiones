import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/proyecto_interface.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/page/gestion/proyecto/page/admin_proyect_page.dart';
import 'package:inversiones/ui/utils/form_field_controller.dart';

import 'package:inversiones/ui/utils/flutter_flow_util.dart';

class AdminProyectPageState extends FlutterFlowModel<AdminProyectPage> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? nombreFocus;
  TextEditingController? nombreController;

  // String? Function(BuildContext, String?)? textController1Validator;



  // State field(s) for TextField widget.
  FocusNode? descripcionFocus;
  TextEditingController? descripcionController;

  // String? Function(BuildContext, String?)? textController1Validator;



  // String? Function(BuildContext, String?)? interesAnualValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nombreFocus?.dispose();
    nombreController?.dispose();

    descripcionFocus?.dispose();
    descripcionController?.dispose();

  }

  ProyectoDto _initDataProyecto() {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    return ProyectoDto(
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        createdAt: formattedDateTime,
        usuarioId: 1);
  }

  Future<int> insertProyecto() async {
    try {
      ProyectoDto proyecto = _initDataProyecto();
      print(proyecto.toJson());

      IProyecto tipoProyectoHandler = ProyectoHandler();
      int result = await tipoProyectoHandler.createProyecto(proyecto);
      print(result);

      return result;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
