
import 'package:inversiones/page/frecuenciaPago/dto/frecuencia_pago_dto.dart';

abstract class IFrecuenciaPago {
  Future<int> createFrecuenciaPago(FrecuenciaPagoDto frecuenciaPagoDto);
  Future<int> deleteFrecuenciaPago(int id);
  Future<List<FrecuenciaPagoDto>> listarFrecuenciaPago();
}
