import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/proyecto_interface.dart';

import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/page/gestion/proyecto/page/proyect_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class ProyectsPageModel extends FlutterFlowModel<ProyectPage> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }

  Future<List<ProyectoDto>> listarProyectos() async {
    try {
      IProyecto proyectoHandler = ProyectoHandler();

      List<ProyectoDto> result =
      await proyectoHandler.listarProyecto();
      return result.isEmpty ? [] : result;
    } catch (e) {
      rethrow;
    }
  }
}
