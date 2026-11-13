import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/recurrente_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/recurrente_interface.dart';
import 'package:inversiones/page/recurrentes/dto/recurrente_dto.dart';
import 'package:inversiones/page/recurrentes/page/recurrentes_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class RecurrentesPageState extends FlutterFlowModel<RecurrentesPage> {
  final IRecurrente _recurrenteHandler = RecurrenteHandler();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<RecurrenteDto>> listar() async {
    try {
      return await _recurrenteHandler.listar();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registrar(int id) async {
    try {
      await _recurrenteHandler.registrar(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> actualizar(int id,
      {String? nombre, int? valor, int? diaMes, bool? activo}) async {
    try {
      await _recurrenteHandler.actualizar(id,
          nombre: nombre, valor: valor, diaMes: diaMes, activo: activo);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _recurrenteHandler.eliminar(id);
    } catch (e) {
      rethrow;
    }
  }
}
