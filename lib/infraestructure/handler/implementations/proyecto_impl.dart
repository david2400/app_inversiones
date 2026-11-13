import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/entity/proyecto_entity.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/domain/mappers/proyecto_mapper.dart';
import 'package:inversiones/domain/schema/proyecto_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/proyecto_interface.dart';


class ProyectoHandler implements IProyecto {
  @override
  Future<int> createProyecto(ProyectoDto proyectoDto) async {
    ProyectoSchema proyectoSchema = ProyectoSchema();
    final mappr = ProyectoMapprImpl();
    Proyecto proyecto = mappr.fromModel(proyectoDto);
    int resultInsert = await proyectoSchema.insert(proyecto);

    if (resultInsert == 0) {
      throw Exception('No se pudo realizar el registro');
    }

    return resultInsert;
  }

  @override
  Future<int> deleteProyecto(int id) async {
    ProyectoSchema proyectoSchema = ProyectoSchema();

    final portafolios = await PortafolioSchema().getByIdProyecto(id);
    if (portafolios.isNotEmpty) {
      throw Exception(
          'No se puede eliminar: el proyecto tiene ${portafolios.length} portafolios activos');
    }

    var result = await proyectoSchema.deleteById(id);
    if (result != 1) {
      throw Exception('No se encontro el registro');
    }

    return result;
  }

  @override
  Future<List<ProyectoDto>> listarProyecto() async {
    try {
      final mappr = ProyectoMapprImpl();
      ProyectoSchema proyectoSchema = ProyectoSchema();
      List<Proyecto> listProyecto = await proyectoSchema.getAll();

      // List<ProyectoDto> listProyectoDto = mappr.convertList<Proyecto,ProyectoDto>(listProyecto);
      List<ProyectoDto> listaProyectoDto = listProyecto
          .map((proyecto) => mappr.fromDto(proyecto))
          .toList();

      return listaProyectoDto;
    } catch (e) {
      rethrow;
    }
  }
}
