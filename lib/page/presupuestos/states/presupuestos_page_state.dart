import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/motivo_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/infraestructure/handler/implementations/presupuesto_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/motivo_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/presupuesto_interface.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:inversiones/page/presupuestos/dto/presupuesto_dto.dart';
import 'package:inversiones/page/presupuestos/page/presupuestos_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class PresupuestosPageState extends FlutterFlowModel<PresupuestosPage> {
  final IPresupuesto _presupuestoHandler = PresupuestoHandler();
  final IMotivo _motivoHandler = MotivoHandler();
  final ICuenta _cuentaHandler = CuentaHandler();

  List<MotivosDto> motivos = [];
  List<CuentaDto> cuentas = [];

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<EjecucionPresupuestoDto>> cargar() async {
    try {
      motivos = await _motivoHandler.listarMotivos();
      cuentas = await _cuentaHandler.listarCuentas();
      return await _presupuestoHandler.ejecucionDelMes();
    } catch (e) {
      rethrow;
    }
  }

  /// Sin [cuentaId] el presupuesto es de todas las cuentas.
  Future<void> guardar(int motivoId, int monto, {int? cuentaId}) async {
    try {
      await _presupuestoHandler.guardar(
          motivoId: motivoId, montoMensual: monto, cuentaId: cuentaId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminar(int idPresupuesto) async {
    try {
      await _presupuestoHandler.eliminar(idPresupuesto);
    } catch (e) {
      rethrow;
    }
  }
}
