import 'package:inversiones/domain/entity/portafolio_entity.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/update_portafolio_dto.dart';
import 'package:inversiones/domain/mappers/portafolio_mapper.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';

class PortafolioHandler implements IPortafolio {
  @override
  Future<int> createPortafolio(PortafolioDto portafolioDto) async {
    final mappr = PortafolioMapprImpl();
    PortafolioSchema portafolioSchema = PortafolioSchema();

    Portafolio portafolio = mappr.fromModel(portafolioDto);
    int resultInsert = await portafolioSchema.insert(portafolio);

    if (resultInsert == 0) {
      throw Exception('No se pudo realizar el registro');
    }
    return resultInsert;
  }

  @override
  Future<int> updatePortafolio(UpdatePortafolioDto UpdatePortafolioDto) async {
    PortafolioSchema portafolioSchema = PortafolioSchema();

    int resultUpdate = await portafolioSchema.update(UpdatePortafolioDto);

    if (resultUpdate == 0) {
      throw Exception('No se pudo realizar la operacion!');
    }
    return resultUpdate;
  }

  @override
  Future<int> deletePortafolio(int id) async {
    PortafolioSchema portafolioSchema = PortafolioSchema();

    var result = await portafolioSchema.deleteById(id);
    if (result != 1) {
      throw Exception('No se encontro el registro');
    }

    return result;
  }

  @override
  Future<List<PortafolioDto>> listarPortafolioByProyecto(int idProyecto) async {
    try {
      final mappr = PortafolioMapprImpl();

      PortafolioSchema portafolioSchema = PortafolioSchema();
      List<Portafolio> listPortafolio =
          await portafolioSchema.getByIdProyecto(idProyecto);

      // List<PortafolioDto> listPortafolioDto = mappr.convertList<Portafolio,PortafolioDto>(listPortafolio);
      List<PortafolioDto> listPortafolioDto = listPortafolio.map((portafolio) {
        return mappr.fromDto(portafolio);
      }).toList();

      return listPortafolioDto;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<PortafolioDto> obtenerPortafolioById(int idProyecto) async {
    try {
      final mappr = PortafolioMapprImpl();

      PortafolioSchema portafolioSchema = PortafolioSchema();
      Portafolio? portafolio = await portafolioSchema.getById(idProyecto);
      if (portafolio == null) {
        throw Exception('No se pudo realizar el registro');
      }
      PortafolioDto listPortafolioDto = mappr.fromDto(portafolio);

      // List<PortafolioDto> listPortafolioDto = mappr.convertList<Portafolio,PortafolioDto>(listPortafolio);

      return listPortafolioDto;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PortafolioDto>> listarPortafolios() async {
    try {
      final mappr = PortafolioMapprImpl();
      PortafolioSchema portafolioSchema = PortafolioSchema();

      List<Portafolio> listTransacciones = await portafolioSchema.getAll();

      List<PortafolioDto> listPortafolio = listTransacciones.map((transaccion) {
        return mappr.fromDto(transaccion);
      }).toList();

      return listPortafolio;
    } catch (e) {
      print('Error obteniendo transacciones: $e');
      return [];
    }
  }

  @override
  Future<PortafolioDto> validarTotalPortafolio(
      int idProyecto, int valor) async {
    try {
      PortafolioDto portafolio = await obtenerPortafolioById(idProyecto);
      int newTotal = portafolio.total! - valor;

      if (newTotal < 0) {
        throw Exception('El valor sobre pasa el valor actual de la cuenta');
      }

      return portafolio;
    } catch (e) {
      rethrow;
    }
  }
}
