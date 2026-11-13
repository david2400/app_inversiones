import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/resumen_financiero_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/resumen_financiero_interface.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/domain/consultas/transaccion_portafolio_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/page/transactions_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';


class TransactionsPageState extends FlutterFlowModel<TransactionsPage> {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<TransaccionDto>> listarTransaccionesByPortafolio(int idPortafolio) async {
    try {
      ITransaccion portafolioHandler = TransaccionHandler();

      List<TransaccionDto> result = await portafolioHandler.listaTransaccionesByPortafolio(idPortafolio);

      return result.isEmpty ? [] : result;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> ajustarSaldo(int idPortafolio, int saldoReal) async {
    try {
      ITransaccion transaccionHandler = TransaccionHandler();
      await transaccionHandler.ajustarSaldo(idPortafolio, saldoReal);
    } catch (e) {
      rethrow;
    }
  }

  Future<TotalesDto> resumenPortafolio(int idPortafolio) async {
    try {
      IResumenFinanciero resumenHandler = ResumenFinancieroHandler();
      return await resumenHandler.resumenPortafolio(idPortafolio);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransaccionPortafolioDto>> listaTransaccionByPortafolioId(
      int idProyecto) async {
    try {
      ITransaccion transaccionHandler = TransaccionHandler();

      List<TransaccionPortafolioDto> result =
      await transaccionHandler.listaTransaccionByPortafolioId(idProyecto);

      return result.isEmpty ? [] : result;
    } catch (e) {
      rethrow;
    }
  }

  Future<PortafolioDto> obtenerPortafolio(int idPortafolio) async {
    try {
      final IPortafolio portafolioHandler = PortafolioHandler();
      return await portafolioHandler.obtenerPortafolioById(idPortafolio);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registrarAporte(int idPortafolio, int valor) async {
    try {
      final ITransaccion transaccionHandler = TransaccionHandler();
      await transaccionHandler.registrarAporte(idPortafolio, valor);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registrarRendimiento(int idPortafolio, int valor,
      {required bool reinvertir}) async {
    try {
      final ITransaccion transaccionHandler = TransaccionHandler();
      await transaccionHandler.registrarRendimiento(idPortafolio, valor,
          reinvertir: reinvertir);
    } catch (e) {
      rethrow;
    }
  }

  /// Convierte el portafolio en una cuenta y retorna el id de la cuenta.
  Future<int> convertirEnCuenta(int idPortafolio,
      {required String tipoCuenta, String? entidad}) async {
    try {
      final ICuenta cuentaHandler = CuentaHandler();
      return await cuentaHandler.convertirPortafolioEnCuenta(idPortafolio,
          tipoCuenta: tipoCuenta, entidad: entidad);
    } catch (e) {
      rethrow;
    }
  }
}
