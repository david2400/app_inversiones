import 'package:flutter/material.dart';
import 'package:inversiones/page/metas/dto/meta_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

const _cifras = [FontFeature.tabularFigures()];

/// Fecha visible de una meta ("dic. 2027").
String textoFechaMeta(BuildContext context, DateTime fecha) =>
    DateFormat.yMMM(FFLocalizations.of(context).languageCode).format(fecha);

/// Color e ícono de cada estado de meta.
({Color color, IconData icono}) estiloEstadoMeta(
        EstadoMeta estado, FlutterFlowTheme tema) =>
    switch (estado) {
      EstadoMeta.completada => (
          color: ColoresFinanzas.ingresos,
          icono: Icons.emoji_events_rounded
        ),
      EstadoMeta.alDia => (
          color: ColoresFinanzas.ingresos,
          icono: Icons.trending_up_rounded
        ),
      EstadoMeta.atrasada => (
          color: tema.warning,
          icono: Icons.schedule_rounded
        ),
      EstadoMeta.vencida => (color: tema.error, icono: Icons.event_busy_rounded),
      EstadoMeta.sinFecha => (
          color: tema.secondaryText,
          icono: Icons.savings_rounded
        ),
      EstadoMeta.pausada => (
          color: tema.secondaryText,
          icono: Icons.pause_circle_outline_rounded
        ),
    };

/// Etiqueta compacta con el estado de la meta.
class EtiquetaEstadoMeta extends StatelessWidget {
  final EstadoMeta estado;

  const EtiquetaEstadoMeta({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final estilo = estiloEstadoMeta(estado, tema);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Espacio.s, vertical: Espacio.xs),
      decoration: BoxDecoration(
        color: estilo.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radios.s),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(estilo.icono, size: 14, color: estilo.color),
        const SizedBox(width: Espacio.xs),
        Text(FFLocalizations.of(context).getText(estado.clave),
            style: tema.labelSmall.copyWith(color: estilo.color)),
      ]),
    );
  }
}

/// Barra de avance de una meta.
class BarraAvanceMeta extends StatelessWidget {
  final double porcentaje;
  final Color color;

  const BarraAvanceMeta(
      {super.key, required this.porcentaje, required this.color});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(Radios.s),
        child: LinearProgressIndicator(
          value: porcentaje,
          minHeight: 8,
          color: color,
          backgroundColor: FlutterFlowTheme.of(context).alternate,
        ),
      );
}

/// Tarjeta de una meta: nombre, estado, barra, ahorrado / objetivo y la
/// indicación de qué hacer (cuota sugerida o cuánto falta).
class TarjetaMeta extends StatelessWidget {
  final AvanceMetaDto meta;
  final VoidCallback? onTap;

  const TarjetaMeta({super.key, required this.meta, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final estilo = estiloEstadoMeta(meta.estado, tema);
    final pct = (meta.porcentaje * 100).floor();
    return Tarjeta(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(meta.nombre,
                  style: tema.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: Espacio.s),
            EtiquetaEstadoMeta(estado: meta.estado),
          ]),
          const SizedBox(height: Espacio.m),
          BarraAvanceMeta(porcentaje: meta.porcentaje, color: estilo.color),
          const SizedBox(height: Espacio.s),
          Row(children: [
            Expanded(
              child: Text(
                '${FormatoMoneda.cop(meta.ahorrado)} '
                '${textos.getText('meta_de')} ${FormatoMoneda.cop(meta.montoObjetivo)}',
                style: tema.bodyMedium.copyWith(fontFeatures: _cifras),
              ),
            ),
            Text('$pct %',
                style: tema.labelLarge
                    .copyWith(color: estilo.color, fontFeatures: _cifras)),
          ]),
          const SizedBox(height: Espacio.xs),
          Text(_detalle(context),
              style: tema.bodySmall.copyWith(color: tema.secondaryText)),
        ],
      ),
    );
  }

  String _detalle(BuildContext context) {
    final textos = FFLocalizations.of(context);
    String t(String c) => textos.getText(c);
    final fecha = meta.fechaObjetivo;
    final partes = <String>[
      if (fecha != null) '${t('meta_para')} ${textoFechaMeta(context, fecha)}',
    ];
    switch (meta.estado) {
      case EstadoMeta.completada:
        partes.add(t('meta_lograda'));
      case EstadoMeta.alDia:
        partes.add(
            '${t('meta_aportas')} ${FormatoMoneda.cop(meta.aporteProgramadoMensual)} ${t('meta_al_mes')}');
      case EstadoMeta.atrasada:
        partes.add(
            '${t('meta_ahorra')} ${FormatoMoneda.cop(meta.cuotaSugerida ?? 0)} ${t('meta_al_mes')}');
      case EstadoMeta.vencida:
        partes.add('${t('meta_faltaron')} ${FormatoMoneda.cop(meta.falta)}');
      case EstadoMeta.sinFecha:
      case EstadoMeta.pausada:
        partes.add('${t('meta_faltan')} ${FormatoMoneda.cop(meta.falta)}');
    }
    return partes.join(' · ');
  }
}

/// Resumen de metas para el inicio: avance total y las más relevantes.
class TarjetaResumenMetas extends StatelessWidget {
  final ResumenMetasDto resumen;
  final VoidCallback? onTap;

  const TarjetaResumenMetas({super.key, required this.resumen, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    return Tarjeta(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.flag_rounded, size: 18, color: tema.secondaryText),
            const SizedBox(width: Espacio.s),
            Expanded(
              child: Text(
                '${FormatoMoneda.cop(resumen.ahorradoTotal)} '
                '${textos.getText('meta_de')} ${FormatoMoneda.cop(resumen.objetivoTotal)}',
                style: tema.labelLarge.copyWith(fontFeatures: _cifras),
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: tema.secondaryText),
          ]),
          const SizedBox(height: Espacio.s),
          BarraAvanceMeta(
              porcentaje: resumen.porcentaje, color: tema.primary),
          for (final meta in resumen.destacadas) ...[
            const SizedBox(height: Espacio.m),
            _FilaMeta(meta: meta),
          ],
        ],
      ),
    );
  }
}

class _FilaMeta extends StatelessWidget {
  final AvanceMetaDto meta;

  const _FilaMeta({required this.meta});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final estilo = estiloEstadoMeta(meta.estado, tema);
    return Row(children: [
      Icon(estilo.icono, size: 18, color: estilo.color),
      const SizedBox(width: Espacio.s),
      Expanded(
        child: Text(meta.nombre,
            style: tema.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
      Text('${(meta.porcentaje * 100).floor()} %',
          style: tema.bodyMedium
              .copyWith(color: estilo.color, fontFeatures: _cifras)),
    ]);
  }
}
