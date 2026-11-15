import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/tipo_transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_transaccion_interface.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/page/tipo_transaccion.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

/// Orquesta el listado de tipos de transacción.
class TipoTransaccionPageState extends FlutterFlowModel<TipoTransaccionPage> {
  final ITipoTransaccion _tipoHandler = TipoTransaccionHandler();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<TipoTransaccionDto>> listarTipoTransaccion() async {
    try {
      return await _tipoHandler.listarTipoTransaccion();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cambiarActivo(int id, bool activo) async {
    try {
      await _tipoHandler.cambiarActivo(id, activo);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _tipoHandler.deleteTipoTransaccion(id);
    } catch (e) {
      rethrow;
    }
  }
}
