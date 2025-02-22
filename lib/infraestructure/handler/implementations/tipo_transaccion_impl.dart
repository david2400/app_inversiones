import 'package:inversiones/domain/mappers/tipo_transaccion_mapper.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_transaccion_interface.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';
import 'package:inversiones/domain/entity/tipo_transaccion_entity.dart';

class TipoTransaccionHandler implements ITipoTransaccion {
  @override
  Future<int> createTipoTransaccion(
      TipoTransaccionDto tipoTransaccionDto) async {
    final mappr = TipoTransaccionMapprImpl();
    TipoTransaccionSchema tipoTransaccionSchema = TipoTransaccionSchema();

    TipoTransaccion tipoTransaccion = mappr.fromModel(tipoTransaccionDto);
    int resultInsert = await tipoTransaccionSchema.insert(tipoTransaccion);

    if (resultInsert == 0) {
      throw Exception('No se pudo realizar el registro');
    }

    return resultInsert;
  }

  @override
  Future<int> deleteTipoTransaccion(int id) async {
    TipoTransaccionSchema tipoTransaccionSchema = TipoTransaccionSchema();

    var result = await tipoTransaccionSchema.deleteById(id);
    if (result != 1) {
      throw Exception('No se encontro el registro');
    }

    return result;
  }

  @override
  Future<List<TipoTransaccionDto>> listarTipoTransaccion() async {
    try {
      final mappr = TipoTransaccionMapprImpl();

      TipoTransaccionSchema tipoTransaccionSchema = TipoTransaccionSchema();
      List<TipoTransaccion> listTipoTransaccion =
          await tipoTransaccionSchema.getAll();

      // List<TipoTransaccionDto> listTransaccionesDto = mappr.convertList<TipoTransaccion,TipoTransaccionDto>(listTipoTransaccion);

      List<TipoTransaccionDto> listTransaccionesDto =
          listTipoTransaccion.map((tipoTransaccion) {
        return mappr.fromDto(tipoTransaccion);
      }).toList();

      return listTransaccionesDto;
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }
}
