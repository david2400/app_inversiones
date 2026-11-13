import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/resumen_financiero_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/proyecto_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/resumen_financiero_interface.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:inversiones/page/reportes/page/reporte_anual_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class ReporteAnualPageState extends FlutterFlowModel<ReporteAnualPage> {
  final IResumenFinanciero _resumenHandler = ResumenFinancieroHandler();
  final IProyecto _proyectoHandler = ProyectoHandler();

  int anio = DateTime.now().year;

  /// `null` = todos los proyectos.
  int? idProyecto;

  bool get esAnioActual => anio >= DateTime.now().year;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<ProyectoDto>> listarProyectos() async {
    try {
      return await _proyectoHandler.listarProyecto();
    } catch (e) {
      rethrow;
    }
  }

  Future<ReporteAnualDto> cargarReporte() async {
    try {
      return await _resumenHandler.reporteAnual(
          anio: anio, idProyecto: idProyecto);
    } catch (e) {
      rethrow;
    }
  }
}
