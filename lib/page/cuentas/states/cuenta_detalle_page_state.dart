import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/cuentas/page/cuenta_detalle_page.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

/// Datos que muestra el detalle de una cuenta.
class DetalleCuenta {
  final CuentaDto cuenta;
  final List<PortafolioDto> portafolios;

  /// Saldo por id de portafolio.
  final Map<int, int> saldos;

  const DetalleCuenta(this.cuenta, this.portafolios, this.saldos);
}

class CuentaDetallePageState extends FlutterFlowModel<CuentaDetallePage> {
  final ICuenta _cuentaHandler = CuentaHandler();
  final IPortafolio _portafolioHandler = PortafolioHandler();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<DetalleCuenta> cargar(int idCuenta) async {
    try {
      final (cuenta, portafolios, saldos) = await (
        _cuentaHandler.obtenerCuenta(idCuenta),
        _portafolioHandler.listarPortafoliosDeCuenta(idCuenta),
        _portafolioHandler.listarSaldos(),
      ).wait;
      return DetalleCuenta(cuenta, portafolios, {
        for (final s in saldos) s.idPortafolio: s.saldo,
      });
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

  /// Crea una cajita, bolsillo o CDT dentro de la cuenta.
  Future<void> crearCajita(int idCuenta, String nombre, int saldoInicial) async {
    try {
      final limpio = nombre.trim();
      if (limpio.isEmpty) throw Exception('El nombre es obligatorio');
      await _portafolioHandler.createPortafolio(
          PortafolioDto(nombre: limpio, cuentaId: idCuenta, interes: 0),
          saldoInicial: saldoInicial);
    } catch (e) {
      rethrow;
    }
  }
}
