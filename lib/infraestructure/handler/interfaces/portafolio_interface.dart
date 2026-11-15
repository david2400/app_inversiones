import 'package:inversiones/page/gestion/portafolio/dto/aporte_programado_dto.dart';

import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/vencimiento_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/saldo_portafolio_dto.dart';

abstract class IPortafolio {
  /// Crea el portafolio. Si [saldoInicial] > 0 registra un ingreso con ese
  /// valor y la descripción "Saldo inicial", para que el saldo calculado
  /// parta del dinero que ya hay en la cuenta.
  ///
  /// Con [aporteProgramado] crea también su aporte programado.
  Future<int> createPortafolio(PortafolioDto portafolioDto,
      {int saldoInicial = 0, AporteProgramadoDto? aporteProgramado});

  /// Edita los datos de un portafolio de proyecto o una cajita de cuenta.
  /// Conserva su dueño; en cuentas, el 4x1000 sigue heredándose de la
  /// cuenta. El portafolio principal se edita desde la cuenta.
  ///
  /// [aporteProgramado] crea o actualiza su aporte programado y
  /// [quitarAporte] lo elimina; sin ninguno, el aporte existente solo se
  /// sincroniza (nombre y cuenta de origen).
  Future<int> actualizarPortafolio(PortafolioDto portafolioDto,
      {AporteProgramadoDto? aporteProgramado, bool quitarAporte = false});

  /// Elimina el portafolio (y su aporte programado) si no tiene movimientos.
  Future<int> deletePortafolio(int id);
  Future<PortafolioDto> obtenerPortafolioById(int idProyecto);
  Future<List<PortafolioDto>> listarPortafolioByProyecto(int idProyecto);
  Future<List<PortafolioDto>> listarPortafolios();

  /// Portafolios activos de una cuenta (el principal primero).
  Future<List<PortafolioDto>> listarPortafoliosDeCuenta(int idCuenta);

  /// Saldo disponible del portafolio calculado desde sus movimientos.
  Future<int> obtenerSaldo(int idPortafolio);

  /// Portafolios con fecha de vencimiento en los próximos [dias] días (o
  /// ya vencidos) que aún tienen saldo, del más próximo al más lejano.
  Future<List<VencimientoDto>> listarVencimientos(
      {DateTime? hoy, int dias = 30});

  /// Saldos de todos los portafolios activos.
  Future<List<SaldoPortafolioDto>> listarSaldos();
}
