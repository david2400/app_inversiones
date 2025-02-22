import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/proyecto_interface.dart';

import 'dart:math';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/page/gestion/proyecto/page/proyect_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

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
      print(result);
      return result.isEmpty ? [] : result;
    } catch (e) {
      rethrow;
    }
  }
}
