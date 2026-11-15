import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/deuda_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/deuda_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/cuentas/dto/deuda_dto.dart';
import 'package:inversiones/page/cuentas/page/deuda_detalle_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

/// Datos del detalle de una deuda.
class DetalleDeuda {
  final ResumenDeudaDto resumen;
  final int? idPortafolioPrincipal;

  /// Cuentas de activo para pagar (ahorros, corriente, digital, efectivo).
  final List<CuentaDto> cuentasParaPagar;

  const DetalleDeuda(
      this.resumen, this.idPortafolioPrincipal, this.cuentasParaPagar);
}

class DeudaDetallePageState extends FlutterFlowModel<DeudaDetallePage> {
  final IDeuda _deudaHandler = DeudaHandler();
  final ICuenta _cuentaHandler = CuentaHandler();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<DetalleDeuda> cargar(int idCuenta) async {
    try {
      final resumen = await _deudaHandler.resumen(idCuenta);
      final cuentas = await _cuentaHandler.listarCuentas();
      final propia = cuentas.where((c) => c.idCuenta == idCuenta);
      return DetalleDeuda(
        resumen,
        propia.isEmpty ? null : propia.first.idPortafolioPrincipal,
        cuentas.where((c) => !TipoCuenta.esPasivo(c.tipoCuenta)).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registrarCompra(int idTarjeta, int valor,
      {required int cuotas, String? descripcion}) async {
    try {
      await _deudaHandler.registrarCompra(idTarjeta, valor,
          numeroCuotas: cuotas, descripcion: descripcion);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pagar(int idDeuda, int idCuentaOrigen, int valor) async {
    try {
      await _deudaHandler.pagar(idDeuda,
          idCuentaOrigen: idCuentaOrigen, valor: valor);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registrarIntereses(int idDeuda, int valor) async {
    try {
      await _deudaHandler.registrarIntereses(idDeuda, valor);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> pagarCuota(int idPrestamo, int idCuentaOrigen) async {
    try {
      await _deudaHandler.pagarCuotaPrestamo(idPrestamo,
          idCuentaOrigen: idCuentaOrigen);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminar(int idCuenta) async {
    try {
      await _cuentaHandler.eliminarCuenta(idCuenta);
    } catch (e) {
      rethrow;
    }
  }
}
