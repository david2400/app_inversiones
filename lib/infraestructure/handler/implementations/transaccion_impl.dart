import 'package:inversiones/domain/mappers/transaccion_mapper.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/domain/entity/tipo_transaccion_entity.dart';
import 'package:inversiones/domain/models/calculadora_gmf.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
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
  /// Si es `true`, no se permite que un egreso o transferencia deje el
  /// portafolio origen con saldo negativo.
  static const validarSaldoSuficiente = true;

  @override
  Future<int> createTransaccion(TransaccionDto transaccionDto) async {
    try {
      if (transaccionDto.valor <= 0) {
        throw Exception('El valor debe ser mayor a cero');
      }

      TipoTransaccion? tipo = await TipoTransaccionSchema()
          .getById(transaccionDto.tipoTransferenciaId);
      if (tipo == null || !TipoFuente.esValido(tipo.tipoFuente)) {
        throw Exception('El tipo de transacción no es válido');
      }

      IPortafolio portafolioHandler = PortafolioHandler();
      PortafolioDto origen = await portafolioHandler
          .obtenerPortafolioById(transaccionDto.portafolioId);

      if (tipo.tipoFuente == TipoFuente.transferencia) {
        await _validarDestino(transaccionDto, portafolioHandler);
      } else {
        // Solo las transferencias tienen portafolio destino.
        transaccionDto.destinoCuenta = null;
      }

      int impuesto = calcularGmf(
          valor: transaccionDto.valor,
          tipoFuente: tipo.tipoFuente,
          exentaImpuesto: origen.exentaImpuesto);

      if (validarSaldoSuficiente &&
          TipoFuente.debitaOrigen(tipo.tipoFuente)) {
        int saldo =
            await portafolioHandler.obtenerSaldo(transaccionDto.portafolioId);
        int requerido = transaccionDto.valor + impuesto;
        if (saldo < requerido) {
          throw Exception(
              'Saldo insuficiente: disponible $saldo, requerido $requerido (incluye GMF $impuesto)');
        }
      }

      transaccionDto.impuesto = impuesto;

      final mappr = TransaccionMapprImpl();
      TransferenciaShema transferenciaShema = TransferenciaShema();
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

  Future<void> _validarDestino(
      TransaccionDto transaccionDto, IPortafolio portafolioHandler) async {
    final destino = transaccionDto.destinoCuenta;
    final destinoExterno = transaccionDto.destinoAlternativo?.trim() ?? '';

    if (destino == null && destinoExterno.isEmpty) {
      throw Exception('Una transferencia requiere un portafolio o cuenta destino');
    }
    if (destino != null) {
      if (destino == transaccionDto.portafolioId) {
        throw Exception('El portafolio origen y destino no pueden ser el mismo');
      }
      // Lanza excepción si el destino no existe o fue eliminado.
      await portafolioHandler.obtenerPortafolioById(destino);
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
  int calcularGmf(
      {required int valor,
      required String tipoFuente,
      required String? exentaImpuesto}) {
    return CalculadoraGmf.calcular(
        valor: valor, tipoFuente: tipoFuente, exentaImpuesto: exentaImpuesto);
  }
}
