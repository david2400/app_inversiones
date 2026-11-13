import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/tercero_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tercero_interface.dart';
import 'package:inversiones/page/terceros/dto/tercero_dto.dart';
import 'package:inversiones/page/terceros/page/terceros_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class TercerosPageState extends FlutterFlowModel<TercerosPage> {
  final ITercero _terceroHandler = TerceroHandler();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<TerceroDto>> listar() async {
    try {
      return await _terceroHandler.listarTerceros();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> guardar(TerceroDto tercero) async {
    try {
      await _terceroHandler.guardarTercero(tercero);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _terceroHandler.eliminarTercero(id);
    } catch (e) {
      rethrow;
    }
  }
}
