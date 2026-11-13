import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:inversiones/domain/consultas/transaccion_portafolio_dto.dart';

/// Resultado de una búsqueda de movimientos con sus totales.
class ResultadoMovimientosDto {
  List<TransaccionPortafolioDto> movimientos;

  /// Totales de TODOS los movimientos del filtro (no solo los mostrados).
  TotalMensualDto totales;

  /// Cantidad total de movimientos que cumplen el filtro.
  int cantidadTotal;

  ResultadoMovimientosDto({
    required this.movimientos,
    required this.totales,
    required this.cantidadTotal,
  });

  /// `true` si hay más movimientos de los que se trajeron.
  bool get truncado => cantidadTotal > movimientos.length;
}
