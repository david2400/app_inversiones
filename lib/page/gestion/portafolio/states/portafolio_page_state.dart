import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/resumen_financiero_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/resumen_financiero_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/gestion/portafolio/page/portafolio_page.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class PortafolioPageState extends FlutterFlowModel<PortafolioPage> {
  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}


  Future<List<PortafolioDto>> listarPortafolio(int idProyecto) async {
    try {
      IPortafolio portafolioHandler = PortafolioHandler();

      List<PortafolioDto> result = await portafolioHandler.listarPortafolioByProyecto(widget.idProyecto);

      return result.isEmpty ? [] : result;
    } catch (e) {
      rethrow;
    }
  }

  Future<TotalesDto> resumenProyecto(int idProyecto) async {
    try {
      IResumenFinanciero resumenHandler = ResumenFinancieroHandler();
      return await resumenHandler.resumenProyecto(idProyecto);
    } catch (e) {
      rethrow;
    }
  }
}
