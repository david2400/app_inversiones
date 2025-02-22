import 'package:inversiones/domain/mappers/tipo_proyecto_mapper.dart';
import 'package:inversiones/domain/schema/tipo_proyecto_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_proyecto_interface.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:inversiones/domain/entity/tipo_proyecto_entity.dart';

class TipoProyectoHandler implements ITipoProyecto {
  @override
  Future<int> createTipoProyecto(TipoProyectoDto tipoProyectoDto) async {
    TipoProyectoSchema tipoProyectoSchema = TipoProyectoSchema();

    final mappr = TipoProyectoMapprImpl();
    TipoProyecto tipoProyecto = mappr.fromModel(tipoProyectoDto);
    int resultInsert = await tipoProyectoSchema.insert(tipoProyecto);

    if (resultInsert == 0) {
      throw Exception('No se pudo realizar el registro');
    }

    return resultInsert;
  }

  @override
  Future<int> deleteTipoProyecto(int id) async {
    TipoProyectoSchema tipoProyectoSchema = TipoProyectoSchema();

    var result = await tipoProyectoSchema.deleteById(id);
    if (result != 1) {
      throw Exception('No se encontro el registro');
    }

    return result;
  }

  @override
  Future<List<TipoProyectoDto>> listarTipoProyecto() async {
    try {
      final mappr = TipoProyectoMapprImpl();
      TipoProyectoSchema tipoProyectoSchema = TipoProyectoSchema();
      List<TipoProyecto> listTipoTransaccion =
          await tipoProyectoSchema.getAll();

      // List<TipoProyectoDto> listTransaccionesDto = mappr.convertList<TipoProyecto,TipoProyectoDto>(listTipoTransaccion);
      List<TipoProyectoDto> listTransaccionesDto =
          listTipoTransaccion.map((tipoProyecto) {

        return mappr.fromDto(tipoProyecto);
      }).toList();

      return listTransaccionesDto;
    } catch (e) {
      rethrow;
    }
  }
}
