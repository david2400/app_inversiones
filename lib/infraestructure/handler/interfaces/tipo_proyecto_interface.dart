
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';

abstract class ITipoProyecto {
  Future<int> createTipoProyecto(TipoProyectoDto tipoProyectoDto);
  Future<int> deleteTipoProyecto(int id);
  Future<List<TipoProyectoDto>> listarTipoProyecto();
}
