import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';

/// Tipos de proyecto: clasifican las inversiones (renta fija, finca raíz,
/// negocio propio...) con su nivel de riesgo.
abstract class ITipoProyecto {
  /// Tipos activos ordenados por nombre, con la cantidad de proyectos que
  /// usa cada uno.
  Future<List<TipoProyectoDto>> listarTipoProyecto();

  /// Tipo activo por id; lanza excepción si no existe.
  Future<TipoProyectoDto> obtenerTipoProyecto(int id);

  /// Crea (sin id) o actualiza el tipo. El nombre es obligatorio y único;
  /// el riesgo es opcional pero debe ser un código válido.
  /// Retorna el id.
  Future<int> guardarTipoProyecto(TipoProyectoDto tipoProyectoDto);

  /// Borrado lógico; no se permite si hay proyectos activos de este tipo.
  Future<int> deleteTipoProyecto(int id);
}
