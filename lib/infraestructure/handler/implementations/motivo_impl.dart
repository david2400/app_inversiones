import 'package:inversiones/domain/entity/motivos_entity.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:inversiones/domain/mappers/motivos_mapper.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/motivo_interface.dart';

class MotivoHandler implements IMotivo {
  @override
  Future<int> createMotivo(MotivosDto motivoDto) async {
    MotivosSchema motivosSchema = MotivosSchema();
    final mappr = MotivoMapprImpl();
    Motivos motivo = mappr.fromModel(motivoDto);
    int resultInsert = await motivosSchema.insert(motivo);

    if (resultInsert == 0) {
      throw Exception('No se pudo realizar el registro');
    }

    return resultInsert;
  }

  @override
  Future<int> deleteMotivo(int id) async {
    MotivosSchema motivosSchema = MotivosSchema();

    var result = await motivosSchema.deleteById(id);
    if (result != 1) {
      throw Exception('No se encontro el registro');
    }

    return result;
  }

  @override
  Future<List<MotivosDto>> listarMotivos() async {
    try {
      final mappr = MotivoMapprImpl();
      MotivosSchema motivosSchema = MotivosSchema();
      List<Motivos> listMotivo = await motivosSchema.getAll();

      List<MotivosDto> listMotivoDto = listMotivo.map((motivo) {
        return mappr.fromDto(motivo);
      }).toList();

      return listMotivoDto;
    } catch (e) {
      // Manejo de errores
      print('Error obteniendo transacciones: $e');
      return [];
    }
  }
}
