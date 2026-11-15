import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/motivo_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/motivo_interface.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:inversiones/page/motivos/page/motivos_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

/// Orquesta el listado de motivos.
class MotivosPageState extends FlutterFlowModel<MotivosPage> {
  final IMotivo _motivoHandler = MotivoHandler();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<MotivosDto>> listarMotivos() async {
    try {
      return await _motivoHandler.listarConUso();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cambiarActivo(int id, bool activo) async {
    try {
      await _motivoHandler.cambiarActivo(id, activo);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _motivoHandler.deleteMotivo(id);
    } catch (e) {
      rethrow;
    }
  }
}
