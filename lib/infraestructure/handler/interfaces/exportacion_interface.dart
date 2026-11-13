/// Periodos disponibles para exportar movimientos.
enum PeriodoExportacion { mesActual, anioActual, todo }

/// Exportación de movimientos a archivos para herramientas externas.
abstract class IExportacion {
  /// Escribe un CSV con los movimientos del [periodo] en [directorio] y
  /// retorna la ruta del archivo creado.
  Future<String> exportarMovimientosCsv(
      {required String directorio,
      PeriodoExportacion periodo = PeriodoExportacion.todo,
      DateTime? fecha});
}
