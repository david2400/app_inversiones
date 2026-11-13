import 'package:inversiones/domain/mappers/total_mensual_mapper.dart';
import 'package:inversiones/domain/mappers/total_por_concepto_mapper.dart';
import 'package:inversiones/domain/models/agrupacion_concepto.dart';
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
      final inicioMes = _fecha(DateTime(hoy.year, hoy.month, 1));
      final egresosPorMotivo = await _transferenciaShema.obtenerTotalesPorConcepto(
          desde: inicioMes,
          hasta: _fecha(fin),
          ingresos: false,
          agrupacion: AgrupacionConcepto.motivo);
      final ingresosPorOrigen =
          await _transferenciaShema.obtenerTotalesPorConcepto(
              desde: inicioMes,
              hasta: _fecha(fin),
              ingresos: true,
              agrupacion: AgrupacionConcepto.contraparte);
      final mapprConcepto = TotalPorConceptoMapprImpl();

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
        egresosPorMotivo: egresosPorMotivo.map(mapprConcepto.fromDto).toList(),
        ingresosPorOrigen:
            ingresosPorOrigen.map(mapprConcepto.fromDto).toList(),
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

  @override
  Future<ReporteAnualDto> reporteAnual(
      {required int anio, int? idProyecto}) async {
    try {
      final desde = _fecha(DateTime(anio, 1, 1));
      final hasta = _fecha(DateTime(anio + 1, 1, 1));
      final totales = idProyecto == null
          ? await _transferenciaShema.obtenerTotalesMensuales(
              desde: desde, hasta: hasta)
          : await _transferenciaShema.obtenerTotalesMensualesProyecto(
              idProyecto,
              desde: desde,
              hasta: hasta);

      final mappr = TotalMensualMapprImpl();
      final porPeriodo = {for (final t in totales) t.periodo: mappr.fromDto(t)};
      final meses = List.generate(DateTime.monthsPerYear, (i) {
        final periodo = _periodo(DateTime(anio, i + 1, 1));
        return porPeriodo[periodo] ??
            TotalMensualDto(
                periodo: periodo, ingresos: 0, egresos: 0, impuestos: 0);
      });

      final mapprConcepto = TotalPorConceptoMapprImpl();
      Future<List<TotalPorConceptoDto>> conceptos(
              bool ingresos, AgrupacionConcepto agrupacion) async =>
          (await _transferenciaShema.obtenerTotalesPorConcepto(
                  desde: desde,
                  hasta: hasta,
                  ingresos: ingresos,
                  agrupacion: agrupacion,
                  idProyecto: idProyecto))
              .map(mapprConcepto.fromDto)
              .toList();

      final flujos = await _transferenciaShema.obtenerFlujosEntreCuentas(
          desde: desde, hasta: hasta, idProyecto: idProyecto);

      // Saldo al 1 de enero: neto de todo lo anterior al año.
      int saldoInicial;
      if (idProyecto == null) {
        final previos = await _transferenciaShema.obtenerTotalesMensuales(
            desde: TransferenciaShema.fechaInicioHistorico, hasta: desde);
        saldoInicial = previos.fold(
            0, (s, t) => s + t.ingresos - t.egresos - t.impuestos);
      } else {
        final previo = await _transferenciaShema
            .obtenerTotalesProyectoHasta(idProyecto, hasta: desde);
        saldoInicial = previo.ingresos - previo.egresos - previo.impuestos;
      }
      final hoy = DateTime.now();
      final mesesConDatos = anio < hoy.year
          ? DateTime.monthsPerYear
          : anio == hoy.year
              ? hoy.month
              : 0;

      return ReporteAnualDto(
        anio: anio,
        idProyecto: idProyecto,
        meses: meses,
        ingresosPorOrigen:
            await conceptos(true, AgrupacionConcepto.contraparte),
        egresosPorDestino:
            await conceptos(false, AgrupacionConcepto.contraparte),
        egresosPorMotivo: await conceptos(false, AgrupacionConcepto.motivo),
        flujosEntreCuentas: flujos.map(mapprConcepto.fromFlujo).toList(),
        saldoInicialAnio: saldoInicial,
        mesesConDatos: mesesConDatos,
      );
    } catch (e) {
      rethrow;
    }
  }

  static String _dosDigitos(int n) => n.toString().padLeft(2, '0');

  static String _periodo(DateTime d) => '${d.year}-${_dosDigitos(d.month)}';

  static String _fecha(DateTime d) => '${_periodo(d)}-${_dosDigitos(d.day)}';
}
