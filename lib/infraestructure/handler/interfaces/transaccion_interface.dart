import 'package:inversiones/domain/models/filtro_movimientos.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/resultado_movimientos_dto.dart';


import 'package:inversiones/domain/consultas/transaccion_balance_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/domain/consultas/transaccion_portafolio_dto.dart';
import 'package:inversiones/domain/consultas/transacciones_details_dto.dart';

abstract class ITransaccion {
  Future<int> createTransaccion(TransaccionDto transaccionDto);
  Future<int> updateTransaccion(TransaccionDto transaccionDto);
  Future<int> deleteTransaccion(int id);
  Future<List<TransaccionDto>> listaTransacciones();
  Future<List<TransaccionBalanceDto>> getBalanceByProyectoId(int portafolioId);
  Future<List<TransaccionPortafolioDto>> listaTransaccionByPortafolioId(int id);
  Future<List<TransaccionDto>> listaTransaccionesByPortafolio(int id);
  Future<TransaccionDto> findTransaccion(int id);
  Future<TransaccionDetailsDto> findTransaccionDetails(int id);
  Future<List<TransaccionBalanceDto>> findTransaccionesByMesAndAnio(String year,String month);

  /// GMF (4x1000) de un movimiento según su tipo y la exención del
  /// portafolio origen.
  int calcularGmf(
      {required int valor,
      required String tipoFuente,
      required String? exentaImpuesto});

  /// Busca movimientos con filtros y totaliza todo el resultado.
  Future<ResultadoMovimientosDto> buscarMovimientos(FiltroMovimientos filtro);

  /// Cuadra el saldo del portafolio con el saldo real (extracto del banco):
  /// registra un ingreso o egreso por la diferencia, sin 4x1000, con la
  /// descripción "Ajuste de saldo". Retorna el id del movimiento.
  Future<int> ajustarSaldo(int idPortafolio, int saldoReal);

  /// Aporte a un portafolio (inversión, cajita, CDT): transferencia desde
  /// el portafolio principal de su cuenta de aportes, o de "Efectivo / Sin
  /// definir" si no tiene. Paga 4x1000 si la cuenta de aportes lo paga.
  /// Retorna el id del movimiento.
  Future<int> registrarAporte(int idPortafolio, int valor,
      {String? descripcion, String? fecha, int? motivoId});

  /// Rendimiento de un portafolio: registra el ingreso en el portafolio y,
  /// salvo que se [reinvierta], lo traslada al portafolio principal de su
  /// cuenta de rendimientos (o de aportes, o de su propia cuenta, o de
  /// "Efectivo / Sin definir"). Todo en una sola transacción. Retorna el id
  /// del ingreso.
  Future<int> registrarRendimiento(int idPortafolio, int valor,
      {String? descripcion,
      String? fecha,
      int? motivoId,
      bool reinvertir = false});
}
