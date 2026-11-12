import 'package:inversiones/domain/mappers/total_mensual_mapper.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/resumen_financiero_interface.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';

class ResumenFinancieroHandler implements IResumenFinanciero {
  /// Cantidad de meses (incluido el actual) que muestra el histórico.
  static const mesesHistorico = 6;

  /// Cantidad de movimientos recientes del dashboard.
  static const limiteMovimientos = 5;

  final IPortafolio _portafolioHandler;
  final TransferenciaShema _transferenciaShema;

  ResumenFinancieroHandler(
      {IPortafolio? portafolioHandler, TransferenciaShema? transferenciaShema})
      : _portafolioHandler = portafolioHandler ?? PortafolioHandler(),
        _transferenciaShema = transferenciaShema ?? TransferenciaShema();

  @override
  Future<ResumenFinancieroDto> obtenerResumen({DateTime? fecha}) async {
    try {
      final hoy = fecha ?? DateTime.now();
      final inicio = DateTime(hoy.year, hoy.month - (mesesHistorico - 1), 1);
      final fin = DateTime(hoy.year, hoy.month + 1, 1);

      final saldos = await _portafolioHandler.listarSaldos();
      final totales = await _transferenciaShema.obtenerTotalesMensuales(
          desde: _fecha(inicio), hasta: _fecha(fin));
      final movimientos = await _transferenciaShema
          .obtenerUltimosMovimientos(limiteMovimientos);

      final mappr = TotalMensualMapprImpl();
      final porPeriodo = {
        for (final total in totales) total.periodo: mappr.fromDto(total)
      };

      // Completa con ceros los meses sin movimientos.
      final historico = List.generate(mesesHistorico, (i) {
        final periodo = _periodo(DateTime(inicio.year, inicio.month + i, 1));
        return porPeriodo[periodo] ??
            TotalMensualDto(
                periodo: periodo, ingresos: 0, egresos: 0, impuestos: 0);
      });

      return ResumenFinancieroDto(
        saldoTotal: saldos.fold(0, (total, s) => total + s.saldo),
        mesActual: historico.last,
        historico: historico,
        saldos: saldos,
        ultimosMovimientos: movimientos,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TotalesDto> resumenPortafolio(int idPortafolio) async {
    try {
      final saldos =
          await _transferenciaShema.obtenerSaldos(idPortafolio: idPortafolio);
      if (saldos.isEmpty) {
        throw Exception('El portafolio $idPortafolio no existe');
      }
      final s = saldos.first;
      return TotalesDto(
          ingresos: s.ingresos,
          egresos: s.egresos,
          impuestos: s.impuestos,
          saldo: s.saldo);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TotalesDto> resumenProyecto(int idProyecto) async {
    try {
      final t = await _transferenciaShema.obtenerTotalesProyecto(idProyecto);
      return TotalesDto(
          ingresos: t.ingresos,
          egresos: t.egresos,
          impuestos: t.impuestos,
          saldo: t.ingresos - t.egresos - t.impuestos);
    } catch (e) {
      rethrow;
    }
  }

  static String _dosDigitos(int n) => n.toString().padLeft(2, '0');

  static String _periodo(DateTime d) => '${d.year}-${_dosDigitos(d.month)}';

  static String _fecha(DateTime d) => '${_periodo(d)}-${_dosDigitos(d.day)}';
}
