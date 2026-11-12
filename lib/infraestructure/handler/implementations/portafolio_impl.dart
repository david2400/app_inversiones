import 'package:inversiones/domain/entity/portafolio_entity.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/update_portafolio_dto.dart';
import 'package:inversiones/domain/mappers/portafolio_mapper.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/domain/mappers/saldo_portafolio_mapper.dart';
import 'package:inversiones/page/gestion/portafolio/dto/saldo_portafolio_dto.dart';
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
    TransferenciaShema transferenciaShema = TransferenciaShema();

    final usos = await transferenciaShema.contarActivosPor(
            TransferenciaShema.portafolioId, id) +
        await transferenciaShema.contarActivosPor(
            TransferenciaShema.destino, id);
    if (usos > 0) {
      throw Exception(
          'No se puede eliminar: el portafolio tiene $usos movimientos asociados');
    }

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
        throw Exception('El portafolio $idProyecto no existe');
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
  Future<int> obtenerSaldo(int idPortafolio) async {
    TransferenciaShema transferenciaShema = TransferenciaShema();
    final saldos =
        await transferenciaShema.obtenerSaldos(idPortafolio: idPortafolio);
    if (saldos.isEmpty) {
      throw Exception('El portafolio $idPortafolio no existe');
    }
    return saldos.first.saldo;
  }

  @override
  Future<List<SaldoPortafolioDto>> listarSaldos() async {
    final mappr = SaldoPortafolioMapprImpl();
    TransferenciaShema transferenciaShema = TransferenciaShema();
    final saldos = await transferenciaShema.obtenerSaldos();
    return saldos.map(mappr.fromDto).toList();
  }
}
