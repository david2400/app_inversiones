import 'package:inversiones/page/gestion/portafolio/dto/saldo_portafolio_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_portafolio_dto.dart';

/// Ingresos, egresos y GMF de un mes (o de un ámbito si `periodo` es vacío).
class TotalMensualDto {
  String periodo;
  int ingresos;
  int egresos;
  int impuestos;

  TotalMensualDto({
    required this.periodo,
    required this.ingresos,
    required this.egresos,
    required this.impuestos,
  });

  /// Todo lo que salió: egresos más el GMF pagado.
  int get totalSalidas => egresos + impuestos;

  /// Resultado neto del periodo.
  int get neto => ingresos - totalSalidas;
}

/// Egresos agrupados por motivo ("¿a dónde se fue el dinero?").
class TotalPorMotivoDto {
  /// `null` agrupa los egresos sin motivo.
  int? idMotivo;
  String? nombre;
  int total;
  int cantidad;

  TotalPorMotivoDto({
    this.idMotivo,
    this.nombre,
    required this.total,
    required this.cantidad,
  });
}

/// Totales y saldo de un portafolio o proyecto.
class TotalesDto {
  int ingresos;
  int egresos;
  int impuestos;
  int saldo;

  TotalesDto({
    required this.ingresos,
    required this.egresos,
    required this.impuestos,
    required this.saldo,
  });

  int get totalSalidas => egresos + impuestos;
}

/// Datos del dashboard financiero.
class ResumenFinancieroDto {
  int saldoTotal;
  TotalMensualDto mesActual;
  List<TotalMensualDto> historico;
  List<SaldoPortafolioDto> saldos;
  List<TransaccionPortafolioDto> ultimosMovimientos;

  /// Egresos del mes actual por motivo, de mayor a menor.
  List<TotalPorMotivoDto> egresosPorMotivo;

  ResumenFinancieroDto({
    required this.saldoTotal,
    required this.mesActual,
    required this.historico,
    required this.saldos,
    required this.ultimosMovimientos,
    required this.egresosPorMotivo,
  });

  bool get sinPortafolios => saldos.isEmpty;
}

/// Reporte de un año (global o de un proyecto) con el detalle mes a mes.
class ReporteAnualDto {
  int anio;
  int? idProyecto;

  /// Los 12 meses del año, incluidos los que no tienen movimientos.
  List<TotalMensualDto> meses;

  ReporteAnualDto({
    required this.anio,
    this.idProyecto,
    required this.meses,
  });

  TotalMensualDto get total => TotalMensualDto(
        periodo: '$anio',
        ingresos: meses.fold(0, (s, m) => s + m.ingresos),
        egresos: meses.fold(0, (s, m) => s + m.egresos),
        impuestos: meses.fold(0, (s, m) => s + m.impuestos),
      );
}
