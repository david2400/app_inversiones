import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_resumen_dto.dart';

abstract class IProyecto {
  Future<int> createProyecto(ProyectoDto proyectoDto);
  Future<int> deleteProyecto(int id);
  Future<List<ProyectoDto>> listarProyecto();

  /// Proyecto activo por id; lanza excepción si no existe.
  Future<ProyectoDto> obtenerProyecto(int id);

  /// Proyectos activos con su tipo, saldo y cantidad de portafolios.
  Future<List<ProyectoResumenDto>> listarResumen();

  /// Edita nombre, descripción y tipo del proyecto.
  Future<int> actualizarProyecto(ProyectoDto proyectoDto);
}
