import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/meta_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/meta_interface.dart';
import 'package:inversiones/page/metas/dto/meta_dto.dart';
import 'package:inversiones/page/metas/page/metas_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

/// Orquesta el listado de metas y sus acciones rápidas.
class MetasPageState extends FlutterFlowModel<MetasPage> {
  final IMeta _metaHandler = MetaHandler();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<AvanceMetaDto>> listar() async {
    try {
      return await _metaHandler.listar();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cambiarActivo(AvanceMetaDto meta) async {
    try {
      await _metaHandler.cambiarActivo(meta.idMeta, !meta.activo);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminar(int idMeta) async {
    try {
      await _metaHandler.eliminar(idMeta);
    } catch (e) {
      rethrow;
    }
  }

  /// Programa el aporte mensual. [valor] vacío = la cuota sugerida.
  Future<void> programarAporte(int idMeta,
      {required int idPortafolio,
      int? valor,
      required int diaMes,
      required bool automatico}) async {
    if (diaMes < 1 || diaMes > 31) {
      throw Exception('El día debe estar entre 1 y 31');
    }
    if (valor != null && valor <= 0) {
      throw Exception('El aporte debe ser mayor a cero');
    }
    try {
      await _metaHandler.programarAporte(idMeta,
          idPortafolio: idPortafolio,
          valor: valor,
          diaMes: diaMes,
          automatico: automatico);
    } catch (e) {
      rethrow;
    }
  }
}
