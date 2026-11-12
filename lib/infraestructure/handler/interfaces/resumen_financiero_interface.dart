import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';

/// Consultas de resumen financiero: dashboard, portafolio y proyecto.
abstract class IResumenFinanciero {
  /// Saldo total, mes de [fecha] (por defecto hoy), histórico mensual,
  /// saldos por portafolio y últimos movimientos.
  Future<ResumenFinancieroDto> obtenerResumen({DateTime? fecha});

  Future<TotalesDto> resumenPortafolio(int idPortafolio);

  Future<TotalesDto> resumenProyecto(int idProyecto);
}
