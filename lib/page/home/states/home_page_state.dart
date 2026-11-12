import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/resumen_financiero_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/resumen_financiero_interface.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:inversiones/page/home/page/home_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class HomePageState extends FlutterFlowModel<HomePage> {
  final IResumenFinanciero _resumenHandler = ResumenFinancieroHandler();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<ResumenFinancieroDto> cargarResumen() async {
    try {
      return await _resumenHandler.obtenerResumen();
    } catch (e) {
      rethrow;
    }
  }
}
