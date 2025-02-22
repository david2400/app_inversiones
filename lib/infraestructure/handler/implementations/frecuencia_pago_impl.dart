import 'package:inversiones/domain/entity/frecuencia_pago_entity.dart';
import 'package:inversiones/page/frecuenciaPago/dto/frecuencia_pago_dto.dart';
import 'package:inversiones/domain/mappers/frecuencia_pago_mapper.dart';
import 'package:inversiones/domain/schema/frecuencia_pago_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/frecuencia_pago_interface.dart';

class FrecuenciaPagoHandler implements IFrecuenciaPago  {

  @override
  Future<int> createFrecuenciaPago(FrecuenciaPagoDto frecuenciaPagoDto) async {
    FrecuenciaPagoSchema motivosSchema = FrecuenciaPagoSchema();
    final mappr = FrecuenciaPagoMapprImpl();

    FrecuenciaPago motivo = mappr.fromModel(frecuenciaPagoDto);
    int resultInsert = await motivosSchema.insert(motivo);

    if (resultInsert == 0) {
      throw Exception('No se pudo realizar el registro');
    }

    return resultInsert;
  }

  @override
  Future<int> deleteFrecuenciaPago(int id) async {
    FrecuenciaPagoSchema frecuenciaPagoSchema = FrecuenciaPagoSchema();

    var result = await frecuenciaPagoSchema.deleteById(id);
    if (result != 1) {
      throw Exception('No se encontro el registro');
    }

    return result;
  }

  // @override
  // Future<FrecuenciaPagoDto> findFrecuenciaPago(int id) async {
  //   final mappr = FrecuenciaPagoMappr();
  //   FrecuenciaPagoSchema frecuenciaPagoSchema = FrecuenciaPagoSchema();
  //
  //   FrecuenciaPago? result = await frecuenciaPagoSchema.getById(id);
  //   if (result == null) {}
  //   FrecuenciaPagoDto frecuenciaPagoDto =
  //       mappr.convert<FrecuenciaPago, FrecuenciaPagoDto>(result);
  //
  //   return frecuenciaPagoDto;
  // }

  @override
  Future<List<FrecuenciaPagoDto>> listarFrecuenciaPago() async {
    try {
      final mappr = FrecuenciaPagoMapprImpl();
      FrecuenciaPagoSchema frecuenciaPagoSchema = FrecuenciaPagoSchema();
      List<FrecuenciaPago> listFrecuencia = await frecuenciaPagoSchema.getAll();
      // List<FrecuenciaPagoDto> listMotivoDto = mappr.convertList<FrecuenciaPago, FrecuenciaPagoDto>(listFrecuencia);
      List<FrecuenciaPagoDto> listMotivoDto = listFrecuencia.map((frecuenciaPago) {
        return mappr.fromDto(frecuenciaPago);
      }).toList();

      return listMotivoDto;
    } catch (e) {
      // Manejo de errores
      return [];
    }
  }
}
