import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/cuentas/dto/deuda_dto.dart';

/// Deudas: tarjetas de crédito y préstamos. Cada deuda es una cuenta de
/// tipo `TipoCuenta.tarjetaCredito` o `TipoCuenta.prestamo` cuyo saldo
/// negativo es lo que se debe, más sus condiciones.
abstract class IDeuda {
  /// Crea o actualiza una tarjeta de crédito con sus condiciones. Si tiene
  /// cuota de manejo, crea (o actualiza) un movimiento fijo automático en
  /// el día de corte. Retorna el id de la cuenta.
  Future<int> guardarTarjeta(CuentaDto cuenta, CondicionesCreditoDto condiciones);

  /// Crea un préstamo y registra el desembolso hacia la cuenta
  /// [idCuentaDesembolso]. Retorna el id de la cuenta del préstamo.
  Future<int> crearPrestamo(CuentaDto cuenta, CondicionesCreditoDto condiciones,
      {required int idCuentaDesembolso, String? fecha});

  Future<CondicionesCreditoDto?> obtenerCondiciones(int idCuenta);

  /// Deuda actual, cupo disponible, intereses estimados, próximas fechas,
  /// compras a cuotas (tarjeta) y tabla de amortización (préstamo).
  Future<ResumenDeudaDto> resumen(int idCuenta, {DateTime? hoy});

  /// Compra con la tarjeta (sube la deuda; no puede superar el cupo).
  /// Retorna el id del movimiento.
  Future<int> registrarCompra(int idTarjeta, int valor,
      {int numeroCuotas = 1,
      String? descripcion,
      int? motivoId,
      int? terceroId,
      String? fecha});

  /// Pago (o abono) a la deuda desde la cuenta [idCuentaOrigen]. Retorna el
  /// id del movimiento.
  Future<int> pagar(int idDeuda,
      {required int idCuentaOrigen, required int valor, String? fecha});

  /// Intereses cobrados según el extracto (suben la deuda).
  Future<int> registrarIntereses(int idDeuda, int valor, {String? fecha});

  /// Paga la cuota fija del préstamo desde [idCuentaOrigen]: abono a capital
  /// a la deuda y egreso por los intereses del mes.
  Future<void> pagarCuotaPrestamo(int idPrestamo,
      {required int idCuentaOrigen, String? fecha});
}
