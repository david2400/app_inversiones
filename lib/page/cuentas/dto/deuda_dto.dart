import 'package:inversiones/domain/models/calculadora_credito.dart';

/// Condiciones de una tarjeta de crédito o un préstamo.
class CondicionesCreditoDto {
  int? idCuenta;

  /// Tarjeta: cupo. Préstamo: monto desembolsado.
  int? cupo;

  /// Tasa mensual (E.M.) en milésimas de punto: 1,85 % = 1850.
  int tasaMensual;
  int? cuotaManejo;
  int? diaCorte;
  int? diaPago;
  int? plazoMeses;
  String? fechaDesembolso;
  int? recurrenteManejoId;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  CondicionesCreditoDto({
    this.idCuenta,
    this.cupo,
    this.tasaMensual = 0,
    this.cuotaManejo,
    this.diaCorte,
    this.diaPago,
    this.plazoMeses,
    this.fechaDesembolso,
    this.recurrenteManejoId,
    this.createdAt,
    this.updatedAt,
    this.deleteAt,
  });

  /// Tasa en porcentaje para mostrar: 1850 → 1,85.
  double get tasaPorcentaje => CalculadoraCredito.porcentaje(tasaMensual);
}

/// Compra con tarjeta diferida a varias cuotas y su avance.
class CompraCuotasDto {
  final int idTransferencia;
  final String descripcion;
  final DateTime fecha;
  final int valor;
  final int numeroCuotas;
  final int cuotasPagadas;
  final int cuotaMensual;

  const CompraCuotasDto({
    required this.idTransferencia,
    required this.descripcion,
    required this.fecha,
    required this.valor,
    required this.numeroCuotas,
    required this.cuotasPagadas,
    required this.cuotaMensual,
  });

  int get cuotasPendientes => numeroCuotas - cuotasPagadas;

  int get saldoPendiente =>
      (valor - cuotaMensual * cuotasPagadas).clamp(0, valor);
}

/// Estado de una deuda: lo que se debe, cupo, intereses y próximos pagos.
class ResumenDeudaDto {
  final int idCuenta;
  final String nombre;

  /// `TipoCuenta.tarjetaCredito` o `TipoCuenta.prestamo`.
  final String tipoCuenta;
  final CondicionesCreditoDto condiciones;

  /// Lo que se debe hoy (0 si hay saldo a favor).
  final int deuda;

  /// Saldo a favor (pagos de más).
  final int saldoAFavor;

  /// Tarjeta: cupo menos deuda.
  final int? disponible;

  /// Interés estimado del mes sobre la deuda actual.
  final int interesEstimado;
  final DateTime? proximoCorte;
  final DateTime? proximoPago;

  /// Préstamo: cuota fija mensual.
  final int? cuotaFija;
  final List<CuotaAmortizacion> amortizacion;
  final List<CompraCuotasDto> comprasACuotas;

  const ResumenDeudaDto({
    required this.idCuenta,
    required this.nombre,
    required this.tipoCuenta,
    required this.condiciones,
    required this.deuda,
    required this.saldoAFavor,
    required this.disponible,
    required this.interesEstimado,
    required this.proximoCorte,
    required this.proximoPago,
    required this.cuotaFija,
    required this.amortizacion,
    required this.comprasACuotas,
  });

  /// Cuota del mes de las compras a cuotas (tarjeta).
  int get cuotasDelMes => comprasACuotas
      .where((c) => c.cuotasPendientes > 0)
      .fold(0, (total, c) => total + c.cuotaMensual);
}
