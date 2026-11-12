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

  ResumenFinancieroDto({
    required this.saldoTotal,
    required this.mesActual,
    required this.historico,
    required this.saldos,
    required this.ultimosMovimientos,
  });

  bool get sinPortafolios => saldos.isEmpty;
}
