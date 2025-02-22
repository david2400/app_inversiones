
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';

abstract class IMotivo {
  Future<int> createMotivo(MotivosDto motivoDto);
  Future<int> deleteMotivo(int id);
  Future<List<MotivosDto>> listarMotivos();


}
