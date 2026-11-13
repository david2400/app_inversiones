import 'package:inversiones/page/terceros/dto/tercero_dto.dart';

abstract class ITercero {
  Future<List<TerceroDto>> listarTerceros();

  /// Crea o actualiza (si trae `idTercero`). Retorna el id.
  Future<int> guardarTercero(TerceroDto terceroDto);

  /// Borrado lógico; falla si el tercero tiene movimientos activos.
  Future<void> eliminarTercero(int id);
}
