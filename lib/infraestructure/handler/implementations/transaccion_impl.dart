import 'package:inversiones/domain/mappers/transaccion_mapper.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_balance_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_portafolio_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transacciones_details_dto.dart';
import 'package:inversiones/domain/entity/transferencia_entity.dart';

class TransaccionHandler implements ITransaccion {
  @override
  Future<int> createTransaccion(TransaccionDto transaccionDto) async {
    try {
      IPortafolio portafolioHandler = PortafolioHandler();
      PortafolioDto portafolio = await portafolioHandler
          .obtenerPortafolioById(transaccionDto.portafolioId);

      final mappr = TransaccionMapprImpl();
      TransferenciaShema transferenciaShema = TransferenciaShema();
      int impuesto = 0;
      if (portafolio.exentaImpuesto == 'N') {
        DateTime date = DateTime.now();
        impuesto = await calcular4xMill(date);
      }
      transaccionDto.impuesto = impuesto;

      Transaccion transaccion = mappr.fromModel(transaccionDto);
      int resultInsert = await transferenciaShema.insert(transaccion);

      if (resultInsert == 0) {
        throw Exception('No se pudo realizar el registro');
      }

      return resultInsert;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> updateTransaccion(TransaccionDto transaccionDto) async {
    final mappr = TransaccionMapprImpl();
    TransferenciaShema transferenciaShema = TransferenciaShema();

    Transaccion transaccion = mappr.fromModel(transaccionDto);
    int resultInsert = await transferenciaShema.update(transaccion);

    if (resultInsert == 0) {
      throw Exception('No se pudo realizar el registro');
    }

    return resultInsert;
  }

  @override
  Future<int> deleteTransaccion(int id) async {
    TransferenciaShema transferenciaShema = TransferenciaShema();

    var result = await transferenciaShema.deleteById(id);
    if (result != 1) {
      throw Exception('No se encontro el registro');
    }

    return result;
  }

  @override
  Future<List<TransaccionDto>> listaTransacciones() async {
    try {
      final mappr = TransaccionMapprImpl();
      TransferenciaShema transferenciaShema = TransferenciaShema();

      List<Transaccion> listTransacciones = await transferenciaShema.getAll();

      List<TransaccionDto> listTransaccionesDto =
          listTransacciones.map((transaccion) {
        return mappr.fromDto(transaccion);
      }).toList();

      return listTransaccionesDto;
    } catch (e) {
      // Manejo de errores
      print('Error obteniendo transacciones: $e');
      return [];
    }
  }

  Future<List<TransaccionBalanceDto>> getBalanceByProyectoId(
      int proyectoId) async {
    try {
      TransferenciaShema transferenciaShema = TransferenciaShema();
      List<TransaccionBalanceDto> list =
          await transferenciaShema.getBalanceByProyectoId(proyectoId);

      return list;
    } catch (e) {
      print('Error obteniendo transacciones: $e');
      return [];
    }
  }

  Future<List<TransaccionPortafolioDto>> listaTransaccionByPortafolioId(
      int portafolioId) async {
    try {
      TransferenciaShema transferenciaShema = TransferenciaShema();
      List<TransaccionPortafolioDto> list =
          await transferenciaShema.getTransaccionByPortafolioId(portafolioId);
      return list;
    } catch (e) {
      print('Error obteniendo transacciones: $e');
      return [];
    }
  }

  @override
  Future<List<TransaccionDto>> listaTransaccionesByPortafolio(int id) async {
    try {
      final mappr = TransaccionMapprImpl();
      TransferenciaShema transferenciaShema = TransferenciaShema();

      List<Transaccion> listTransacciones =
          await transferenciaShema.getByPortafolioId(id);

      List<TransaccionDto> listTransaccionesDto =
          listTransacciones.map((transaccion) {
        return mappr.fromDto(transaccion);
      }).toList();

      return listTransaccionesDto;
    } catch (e) {
      print('Error obteniendo transacciones: $e');
      return [];
    }
  }

  @override
  Future<TransaccionDto> findTransaccion(int id) async {
    final mappr = TransaccionMapprImpl();
    TransferenciaShema transferenciaShema = TransferenciaShema();

    Transaccion? result = await transferenciaShema.getById(id);

    if (result == null) {
      throw Exception('Transacción con ID $id no encontrada');
    }

    return mappr.fromDto(result);
  }

  @override
  Future<TransaccionDetailsDto> findTransaccionDetails(int id) async {
    try {
      TransferenciaShema transferenciaShema = TransferenciaShema();

      TransaccionDetailsDto? result =
          await transferenciaShema.getTransaccionDetails(id);

      if (result == null) {
        throw Exception('Transacción con ID $id no encontrada');
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TransaccionBalanceDto>> findTransaccionesByMesAndAnio(
      String year, String month) async {
    try {
      TransferenciaShema transferenciaShema = TransferenciaShema();

      List<TransaccionBalanceDto> listTransaccionesDto =
          await transferenciaShema.getTransaccionesByMesAndAnio(year, month);

      return listTransaccionesDto;
    } catch (e) {
      print('Error obteniendo transacciones: $e');
      return [];
    }
  }

  @override
  Future<int> calcular4xMill(DateTime date) async {
    List<TransaccionBalanceDto> result = await findTransaccionesByMesAndAnio(
        date.year.toString(), date.month.toString());

    int egresos = result.fold(0, (prev, element) {
      return element.tipoFuente == 'E' || (element.tipoFuente == 'M')
          ? prev + (element.valor)
          : prev;
    });
    return egresos;
  }
}
