import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/patrimonio_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/patrimonio_interface.dart';
import 'package:inversiones/page/home/dto/patrimonio_dto.dart';
import 'package:inversiones/page/patrimonio/page/patrimonio_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

/// Orquesta la pantalla de patrimonio y rentabilidad.
class PatrimonioPageState extends FlutterFlowModel<PatrimonioPage> {
  /// Meses que muestra la gráfica de evolución.
  static const mesesEvolucion = 12;

  final IPatrimonio _patrimonioHandler = PatrimonioHandler();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<PatrimonioDto> cargar() async {
    try {
      return await _patrimonioHandler.obtenerPatrimonio(
          meses: mesesEvolucion);
    } catch (e) {
      rethrow;
    }
  }
}
