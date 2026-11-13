
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/saldo_portafolio_dto.dart';
import 'package:inversiones/domain/consultas/update_portafolio_dto.dart';

abstract class IPortafolio {
  /// Crea el portafolio. Si [saldoInicial] > 0 registra un ingreso con ese
  /// valor y la descripción "Saldo inicial", para que el saldo calculado
  /// parta del dinero que ya hay en la cuenta.
  Future<int> createPortafolio(PortafolioDto portafolioDto,
      {int saldoInicial = 0});
  Future<int> updatePortafolio(UpdatePortafolioDto UpdatePortafolioDto);
  Future<int> deletePortafolio(int id);
  Future<PortafolioDto> obtenerPortafolioById(int idProyecto);
  Future<List<PortafolioDto>> listarPortafolioByProyecto(int idProyecto);
  Future<List<PortafolioDto>> listarPortafolios();

  /// Portafolios activos de una cuenta (el principal primero).
  Future<List<PortafolioDto>> listarPortafoliosDeCuenta(int idCuenta);

  /// Saldo disponible del portafolio calculado desde sus movimientos.
  Future<int> obtenerSaldo(int idPortafolio);

  /// Saldos de todos los portafolios activos.
  Future<List<SaldoPortafolioDto>> listarSaldos();
}
