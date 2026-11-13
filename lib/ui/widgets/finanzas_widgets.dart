import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:inversiones/page/presupuestos/dto/presupuesto_dto.dart';
import 'package:inversiones/page/recurrentes/dto/recurrente_dto.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';

/// Colores de identidad de ingresos y egresos (validados para daltonismo
/// sobre el fondo oscuro). Se usan igual en tarjetas, barras y leyendas.
class ColoresFinanzas {
  static const ingresos = Color(0xFF3987E5);
  static const egresos = Color(0xFFD95926);

  ColoresFinanzas._();
}

/// Barras horizontales de una sola serie, de mayor a menor, con valor y
/// porcentaje como texto. Para "¿de dónde vino?" / "¿a dónde se fue?".
class BarrasPorConcepto extends StatelessWidget {
  final List<TotalPorConceptoDto> datos;
  final Color color;
  final String textoSinDato;
  final String textoVacio;

  /// Máximo de filas visibles; el resto se suma en "Otros".
  final int maximoFilas;
  final String textoOtros;

  static const _altoBarra = 6.0;

  const BarrasPorConcepto({
    super.key,
    required this.datos,
    required this.color,
    required this.textoSinDato,
    required this.textoVacio,
    this.maximoFilas = 6,
    this.textoOtros = 'Otros',
  });

  List<TotalPorConceptoDto> get _filas {
    if (datos.length <= maximoFilas) return datos;
    final visibles = datos.take(maximoFilas - 1).toList();
    final resto = datos.skip(maximoFilas - 1);
    return [
      ...visibles,
      TotalPorConceptoDto(
        nombre: textoOtros,
        total: resto.fold(0, (s, d) => s + d.total),
        cantidad: resto.fold(0, (s, d) => s + d.cantidad),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    if (datos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(textoVacio,
            style: tema.bodyMedium.copyWith(color: tema.secondaryText)),
      );
    }
    final filas = _filas;
    final total = filas.fold<int>(0, (s, d) => s + d.total);
    final mayor = filas.map((d) => d.total).reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        for (final d in filas)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(d.nombre ?? textoSinDato,
                          style: tema.bodyMedium,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      '${FormatoMoneda.cop(d.total)}  ·  '
                      '${total == 0 ? 0 : (d.total * 100 / total).round()} %',
                      style: tema.bodySmall.copyWith(color: tema.secondaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(_altoBarra / 2),
                  child: LinearProgressIndicator(
                    value: mayor == 0 ? 0 : d.total / mayor,
                    minHeight: _altoBarra,
                    color: color,
                    backgroundColor: tema.alternate,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Lista de recorridos de transferencias: "Origen → Destino", total y GMF.
class ListaFlujos extends StatelessWidget {
  final List<FlujoEntreCuentasDto> flujos;
  final String textoVacio;
  final String textoExterna;
  final String textoGmf;

  const ListaFlujos({
    super.key,
    required this.flujos,
    required this.textoVacio,
    required this.textoExterna,
    required this.textoGmf,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    if (flujos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(textoVacio,
            style: tema.bodyMedium.copyWith(color: tema.secondaryText)),
      );
    }
    return Column(
      children: [
        for (final f in flujos)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
                f.externo ? Icons.call_made_rounded : Icons.swap_horiz_rounded,
                color: tema.secondaryText),
            title: Text('${f.origen} → ${f.destino ?? textoExterna}',
                style: tema.bodyLarge),
            subtitle: Text(
              [
                '${f.cantidad} ×',
                if (f.externo) textoExterna,
                if (f.impuestos > 0)
                  '$textoGmf ${FormatoMoneda.cop(f.impuestos)}',
              ].join('  ·  '),
              style: tema.bodySmall.copyWith(color: tema.secondaryText),
            ),
            trailing: Text(FormatoMoneda.cop(f.total), style: tema.titleSmall),
          ),
      ],
    );
  }
}

/// Avance de un presupuesto: gastado / límite, barra y estado con ícono y
/// texto (el color nunca va solo).
class FilaPresupuesto extends StatelessWidget {
  final EjecucionPresupuestoDto presupuesto;
  final String textoDisponible;
  final String textoExcedido;
  final VoidCallback? onTap;
  final Widget? accion;

  static const _altoBarra = 6.0;

  const FilaPresupuesto({
    super.key,
    required this.presupuesto,
    required this.textoDisponible,
    required this.textoExcedido,
    this.onTap,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final p = presupuesto;
    final (color, icono) = switch (p.estado) {
      EstadoPresupuesto.excedido => (tema.error, Icons.error_rounded),
      EstadoPresupuesto.alerta => (tema.warning, Icons.warning_amber_rounded),
      EstadoPresupuesto.normal =>
        (ColoresFinanzas.ingresos, Icons.check_circle_outline_rounded),
    };
    final detalle = p.estado == EstadoPresupuesto.excedido
        ? '$textoExcedido ${FormatoMoneda.cop(-p.disponible)}'
        : '$textoDisponible ${FormatoMoneda.cop(p.disponible)}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icono, size: 16, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                            p.cuenta == null
                                ? p.motivo
                                : '${p.motivo} · ${p.cuenta}',
                            style: tema.bodyMedium,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        '${FormatoMoneda.cop(p.gastado)} / ${FormatoMoneda.cop(p.montoMensual)}',
                        style: tema.bodySmall.copyWith(color: tema.secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(_altoBarra / 2),
                    child: LinearProgressIndicator(
                      value: (p.porcentaje / 100).clamp(0.0, 1.0),
                      minHeight: _altoBarra,
                      color: color,
                      backgroundColor: tema.alternate,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${p.porcentaje} %  ·  $detalle',
                      style: tema.bodySmall.copyWith(color: tema.secondaryText)),
                ],
              ),
            ),
            if (accion != null) accion!,
          ],
        ),
      ),
    );
  }
}

/// Movimiento fijo: nombre, recorrido, valor, día y estado del mes, con
/// botón para registrarlo si está pendiente.
class FilaRecurrente extends StatelessWidget {
  final RecurrenteDto fijo;
  final String textoRegistrado;
  final String textoPendiente;
  final String textoPausado;
  final String textoRegistrar;
  final VoidCallback? onRegistrar;
  final VoidCallback? onTap;
  final Widget? menu;

  const FilaRecurrente({
    super.key,
    required this.fijo,
    required this.textoRegistrado,
    required this.textoPendiente,
    required this.textoPausado,
    required this.textoRegistrar,
    this.onRegistrar,
    this.onTap,
    this.menu,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final hoy = DateTime.now();
    final vencido = fijo.pendiente &&
        fijo.fechaProgramada != null &&
        fijo.fechaProgramada!.isBefore(DateTime(hoy.year, hoy.month, hoy.day));
    final (icono, color, estado) = !fijo.activo
        ? (Icons.pause_circle_outline_rounded, tema.secondaryText, textoPausado)
        : fijo.registradoEnMes
            ? (Icons.check_circle_outline_rounded, ColoresFinanzas.ingresos,
                textoRegistrado)
            : (vencido ? Icons.warning_amber_rounded : Icons.schedule_rounded,
                vencido ? tema.warning : tema.secondaryText, textoPendiente);
    final esIngreso = fijo.tipoFuente == TipoFuente.ingreso;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icono, color: color),
      title: Text(fijo.nombre, style: tema.bodyLarge),
      subtitle: Text(
        '${fijo.flujo}\n$estado  ·  ${fijo.fechaProgramada == null ? fijo.diaMes : '${fijo.fechaProgramada!.day}/${fijo.fechaProgramada!.month}'}',
        style: tema.bodySmall.copyWith(color: tema.secondaryText),
      ),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${esIngreso ? '+' : '−'} ${FormatoMoneda.cop(fijo.valor)}',
                  style: tema.titleSmall),
              if (fijo.pendiente && onRegistrar != null)
                TextButton(
                  onPressed: onRegistrar,
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text(textoRegistrar),
                ),
            ],
          ),
          if (menu != null) menu!,
        ],
      ),
    );
  }
}

/// Línea del saldo al cierre de cada mes (una sola serie: el título de la
/// sección la nombra). Tooltip con el valor exacto al tocar cada punto.
class GraficoSaldo extends StatelessWidget {
  final List<int> saldos;

  /// Etiqueta del eje X para el índice de mes (0 = enero).
  final String Function(int indice) etiquetaMes;

  static const _alto = 200.0;
  static const _grosorLinea = 2.0;
  static const _radioPunto = 4.0;

  const GraficoSaldo({
    super.key,
    required this.saldos,
    required this.etiquetaMes,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    if (saldos.isEmpty) return const SizedBox.shrink();
    final estiloEje = tema.bodySmall.copyWith(color: tema.secondaryText);
    final minimo = saldos.reduce((a, b) => a < b ? a : b);
    final maximo = saldos.reduce((a, b) => a > b ? a : b);
    final margen = ((maximo - minimo).abs() * 0.15).clamp(1, double.infinity);
    final color = tema.primary;

    return SizedBox(
      height: _alto,
      child: LineChart(
        LineChartData(
          minY: (minimo > 0 ? 0 : minimo - margen).toDouble(),
          maxY: (maximo + margen).toDouble(),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: tema.alternate, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                getTitlesWidget: (valor, meta) =>
                    valor == meta.max || valor == meta.min
                        ? const SizedBox.shrink()
                        : Text(FormatoMoneda.compacto(valor), style: estiloEje),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (valor, meta) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(etiquetaMes(valor.toInt()), style: estiloEje),
                ),
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => tema.secondaryBackground,
              getTooltipItems: (puntos) => [
                for (final p in puntos)
                  LineTooltipItem(
                    '${etiquetaMes(p.x.toInt())}\n${FormatoMoneda.cop(p.y)}',
                    tema.bodySmall.copyWith(color: tema.primaryText),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < saldos.length; i++)
                  FlSpot(i.toDouble(), saldos[i].toDouble()),
              ],
              color: color,
              barWidth: _grosorLinea,
              dotData: FlDotData(
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: _radioPunto,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: tema.primaryBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
