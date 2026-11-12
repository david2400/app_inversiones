
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/saldo_portafolio_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/update_portafolio_dto.dart';

abstract class IPortafolio {
  Future<int> createPortafolio(PortafolioDto portafolioDto);
  Future<int> updatePortafolio(UpdatePortafolioDto UpdatePortafolioDto);
  Future<int> deletePortafolio(int id);
  Future<PortafolioDto> obtenerPortafolioById(int idProyecto);
  Future<List<PortafolioDto>> listarPortafolioByProyecto(int idProyecto);
  Future<List<PortafolioDto>> listarPortafolios();

  /// Saldo disponible del portafolio calculado desde sus movimientos.
  Future<int> obtenerSaldo(int idPortafolio);

  /// Saldos de todos los portafolios activos.
  Future<List<SaldoPortafolioDto>> listarSaldos();
}
