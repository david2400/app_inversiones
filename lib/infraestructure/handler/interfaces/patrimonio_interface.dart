import 'package:inversiones/page/home/dto/patrimonio_dto.dart';

/// Patrimonio neto y rentabilidad de las inversiones.
abstract class IPatrimonio {
  /// Foto a hoy: en cuentas, invertido, deudas, evolución de los últimos
  /// [meses] meses hasta el mes de [fecha] (hoy por defecto) y
  /// rentabilidad por tipo de proyecto y por proyecto.
  Future<PatrimonioDto> obtenerPatrimonio({DateTime? fecha, int meses = 12});
}
