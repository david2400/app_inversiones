import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';

abstract class IProyecto {
  Future<int> createProyecto(ProyectoDto proyectoDto);
  Future<int> deleteProyecto(int id);
  Future<List<ProyectoDto>> listarProyecto();
}
