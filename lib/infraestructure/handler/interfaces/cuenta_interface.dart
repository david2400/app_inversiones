import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';

/// Cuentas donde vive el dinero (ahorros, corriente, digital, efectivo).
/// Cada cuenta tiene un portafolio principal y puede tener más portafolios
/// (cajitas, bolsillos, CDTs del banco).
abstract class ICuenta {
  /// Cuentas activas con su saldo (suma de sus portafolios). "Efectivo /
  /// Sin definir" va primero.
  Future<List<CuentaDto>> listarCuentas();

  Future<CuentaDto> obtenerCuenta(int idCuenta);

  /// Crea o actualiza la cuenta. Al crearla también crea su portafolio
  /// principal y, si [saldoInicial] > 0, registra ese saldo. Retorna el id.
  Future<int> guardarCuenta(CuentaDto cuenta, {int saldoInicial = 0});

  /// Borrado lógico. No se puede eliminar "Efectivo / Sin definir", ni una
  /// cuenta con movimientos o con portafolios además del principal.
  Future<void> eliminarCuenta(int idCuenta);

  /// Convierte un portafolio de un proyecto en una cuenta: el portafolio
  /// pasa a ser el principal de la cuenta nueva, con todos sus movimientos.
  /// Retorna el id de la cuenta.
  Future<int> convertirPortafolioEnCuenta(int idPortafolio,
      {required String tipoCuenta, String? entidad});
}
