import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/tipo_proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_proyecto_interface.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:inversiones/page/gestion/tipoProyecto/page/tipo_proyecto_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

/// Orquesta el listado de tipos de proyecto.
class TipoProyectoPageState extends FlutterFlowModel<TipoProyectoPage> {
  final ITipoProyecto _tipoProyectoHandler = TipoProyectoHandler();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<TipoProyectoDto>> listarTipoProyectos() async {
    try {
      return await _tipoProyectoHandler.listarTipoProyecto();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _tipoProyectoHandler.deleteTipoProyecto(id);
    } catch (e) {
      rethrow;
    }
  }
}
