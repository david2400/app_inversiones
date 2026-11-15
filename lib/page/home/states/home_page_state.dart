import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/meta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/patrimonio_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/meta_interface.dart';
import 'package:inversiones/page/metas/dto/meta_dto.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/vencimiento_dto.dart';
import 'package:inversiones/infraestructure/handler/implementations/presupuesto_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/patrimonio_interface.dart';
import 'package:inversiones/page/home/dto/patrimonio_dto.dart';
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
  final IPatrimonio _patrimonioHandler = PatrimonioHandler();
  final IPortafolio _portafolioHandler = PortafolioHandler();
  final IMeta _metaHandler = MetaHandler();

  /// Metas que se muestran en el inicio.
  static const maximoMetas = 3;

  /// Resumen de las metas de ahorro activas.
  Future<ResumenMetasDto> cargarMetas() async {
    try {
      return await _metaHandler.resumen(maximo: maximoMetas);
    } catch (e) {
      rethrow;
    }
  }

  /// Días hacia adelante en que se avisan los vencimientos.
  static const diasAvisoVencimiento = 30;

  /// CDT e inversiones a término que vencen pronto o ya vencieron.
  Future<List<VencimientoDto>> cargarVencimientos() async {
    try {
      return await _portafolioHandler.listarVencimientos(
          dias: diasAvisoVencimiento);
    } catch (e) {
      rethrow;
    }
  }

  /// Patrimonio neto con su evolución de los últimos meses.
  Future<PatrimonioDto> cargarPatrimonio() async {
    try {
      return await _patrimonioHandler.obtenerPatrimonio(meses: 2);
    } catch (e) {
      rethrow;
    }
  }

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
