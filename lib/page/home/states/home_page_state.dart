import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/presupuesto_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/recurrente_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/resumen_financiero_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/recurrente_interface.dart';
import 'package:inversiones/page/recurrentes/dto/recurrente_dto.dart';
import 'package:inversiones/infraestructure/handler/interfaces/presupuesto_interface.dart';
import 'package:inversiones/page/presupuestos/dto/presupuesto_dto.dart';
import 'package:inversiones/infraestructure/handler/interfaces/resumen_financiero_interface.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:inversiones/page/home/page/home_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class HomePageState extends FlutterFlowModel<HomePage> {
  final IResumenFinanciero _resumenHandler = ResumenFinancieroHandler();
  final IPresupuesto _presupuestoHandler = PresupuestoHandler();
  final IRecurrente _recurrenteHandler = RecurrenteHandler();

  Future<List<RecurrenteDto>> cargarPendientes() async {
    try {
      return await _recurrenteHandler.pendientesDelMes();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registrarFijo(int idRecurrente) async {
    try {
      await _recurrenteHandler.registrar(idRecurrente);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<EjecucionPresupuestoDto>> cargarPresupuestos() async {
    try {
      return await _presupuestoHandler.ejecucionDelMes();
    } catch (e) {
      rethrow;
    }
  }

  Future<ResumenFinancieroDto> cargarResumen() async {
    try {
      // Cuotas de manejo y demás fijos automáticos cuyo día ya llegó.
      await _recurrenteHandler.registrarAutomaticos();
      return await _resumenHandler.obtenerResumen();
    } catch (e) {
      rethrow;
    }
  }
}
