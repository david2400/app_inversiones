import 'package:inversiones/page/gestion/portafolio/dto/saldo_portafolio_dto.dart';
import 'package:inversiones/domain/consultas/transaccion_portafolio_dto.dart';

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

/// Ingresos o egresos agrupados por un concepto (motivo o contraparte).
class TotalPorConceptoDto {
  /// `null` agrupa los movimientos sin dato para el concepto.
  String? nombre;
  int total;
  int cantidad;

  TotalPorConceptoDto(
      {this.nombre, required this.total, required this.cantidad});
}

/// Transferencias agrupadas por recorrido origen → destino.
class FlujoEntreCuentasDto {
  String origen;
  String? destino;
  bool externo;
  int total;
  int impuestos;
  int cantidad;

  FlujoEntreCuentasDto({
    required this.origen,
    this.destino,
    required this.externo,
    required this.total,
    required this.impuestos,
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
  List<TotalPorConceptoDto> egresosPorMotivo;

  /// Ingresos del mes actual por contraparte ("¿de dónde vino?").
  List<TotalPorConceptoDto> ingresosPorOrigen;

  ResumenFinancieroDto({
    required this.saldoTotal,
    required this.mesActual,
    required this.historico,
    required this.saldos,
    required this.ultimosMovimientos,
    required this.egresosPorMotivo,
    required this.ingresosPorOrigen,
  });

  bool get sinPortafolios => saldos.isEmpty;
}

/// Reporte de un año (global o de un proyecto) con el detalle mes a mes.
class ReporteAnualDto {
  int anio;
  int? idProyecto;

  /// Los 12 meses del año, incluidos los que no tienen movimientos.
  List<TotalMensualDto> meses;

  /// "¿De dónde vino el dinero?": ingresos del año por contraparte.
  List<TotalPorConceptoDto> ingresosPorOrigen;

  /// "¿A dónde se fue?": egresos del año por contraparte.
  List<TotalPorConceptoDto> egresosPorDestino;

  /// "¿En qué se gastó?": egresos del año por motivo.
  List<TotalPorConceptoDto> egresosPorMotivo;

  /// Transferencias del año por recorrido origen → destino.
  List<FlujoEntreCuentasDto> flujosEntreCuentas;

  /// Saldo acumulado al 1 de enero (todo lo anterior al año).
  int saldoInicialAnio;

  /// Meses del año con información (en el año en curso, hasta el mes actual).
  int mesesConDatos;

  ReporteAnualDto({
    required this.anio,
    this.idProyecto,
    required this.meses,
    this.ingresosPorOrigen = const [],
    this.egresosPorDestino = const [],
    this.egresosPorMotivo = const [],
    this.flujosEntreCuentas = const [],
    this.saldoInicialAnio = 0,
    this.mesesConDatos = DateTime.monthsPerYear,
  });

  /// Saldo al cierre de cada mes (solo los [mesesConDatos] primeros).
  List<int> get saldosAlCierre {
    var saldo = saldoInicialAnio;
    return [
      for (final mes in meses.take(mesesConDatos)) saldo += mes.neto,
    ];
  }

  TotalMensualDto get total => TotalMensualDto(
        periodo: '$anio',
        ingresos: meses.fold(0, (s, m) => s + m.ingresos),
        egresos: meses.fold(0, (s, m) => s + m.egresos),
        impuestos: meses.fold(0, (s, m) => s + m.impuestos),
      );
}
