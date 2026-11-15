import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';

/// Orquesta el registro de un aporte: el dinero sale de la cuenta de
/// aportes del portafolio o, si no tiene, de "Efectivo / Sin definir".
/// Es una transferencia entre tus cuentas: no cuenta como ingreso ni gasto.
class AporteState {
  final ICuenta _cuentaHandler;
  final ITransaccion _transaccionHandler;

  AporteState({ICuenta? cuentaHandler, ITransaccion? transaccionHandler})
      : _cuentaHandler = cuentaHandler ?? CuentaHandler(),
        _transaccionHandler = transaccionHandler ?? TransaccionHandler();

  /// Cuenta de donde saldrá el aporte.
  Future<CuentaDto> cuentaOrigen(PortafolioDto portafolio) =>
      _cuentaHandler.obtenerCuenta(
          portafolio.cuentaAportesId ?? CuentaSchema.idEfectivo);

  /// Si el aporte sale de "Efectivo / Sin definir".
  static bool saleDeEfectivo(PortafolioDto portafolio) =>
      (portafolio.cuentaAportesId ?? CuentaSchema.idEfectivo) ==
      CuentaSchema.idEfectivo;

  Future<void> registrar(int idPortafolio, int valor, {String? descripcion}) {
    if (valor <= 0) {
      throw Exception('El valor debe ser mayor a cero');
    }
    return _transaccionHandler.registrarAporte(idPortafolio, valor,
        descripcion: descripcion);
  }
}
