import 'package:flutter/material.dart';
import 'package:inversiones/page/agenda/dto/agenda_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

const _cifras = [FontFeature.tabularFigures()];

/// Ícono de cada tipo de evento.
IconData iconoEventoAgenda(TipoEventoAgenda tipo) => switch (tipo) {
      TipoEventoAgenda.ingreso => Icons.south_west_rounded,
      TipoEventoAgenda.gasto => Icons.north_east_rounded,
      TipoEventoAgenda.transferencia => Icons.swap_horiz_rounded,
      TipoEventoAgenda.deuda => Icons.credit_card_rounded,
      TipoEventoAgenda.vencimiento => Icons.event_available_rounded,
      TipoEventoAgenda.meta => Icons.flag_rounded,
    };

/// Color del efecto en el disponible: entra, sale o neutro.
Color colorEfecto(int efecto, FlutterFlowTheme tema) => efecto > 0
    ? ColoresFinanzas.ingresos
    : efecto < 0
        ? ColoresFinanzas.egresos
        : tema.secondaryText;

/// Valor con signo según su efecto ("+ $ 3.000.000", "− $ 1.500.000").
String textoEfecto(int efecto, int valor) {
  if (efecto > 0) return '+ ${FormatoMoneda.cop(efecto)}';
  if (efecto < 0) return '− ${FormatoMoneda.cop(-efecto)}';
  return FormatoMoneda.cop(valor);
}

/// Nombre del día: "Hoy", "Mañana" o "vie., 5 dic.".
String textoDiaAgenda(BuildContext context, DateTime fecha, DateTime hoy) {
  final textos = FFLocalizations.of(context);
  final dias = fecha.difference(DateTime(hoy.year, hoy.month, hoy.day)).inDays;
  if (dias == 0) return textos.getText('agenda_hoy');
  if (dias == 1) return textos.getText('agenda_manana');
  return DateFormat.MMMEd(textos.languageCode).format(fecha);
}

/// Resumen del flujo: disponible hoy, cierre de mes, final del horizonte y
/// la alerta si el disponible quedaría negativo.
class ResumenFlujo extends StatelessWidget {
  final AgendaDto agenda;
  final VoidCallback? onTap;

  const ResumenFlujo({super.key, required this.agenda, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    String t(String c) => textos.getText(c);
    Widget cifra(String etiqueta, int valor) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(etiqueta,
                style: tema.bodySmall.copyWith(color: tema.secondaryText)),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(FormatoMoneda.cop(valor),
                  style: tema.titleMedium.copyWith(
                      color: valor < 0 ? tema.error : tema.primaryText,
                      fontFeatures: _cifras)),
            ),
          ]),
        );
    return Tarjeta(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            cifra(t('agenda_disponible_hoy'), agenda.saldoInicial),
            cifra(t('agenda_fin_de_mes'), agenda.saldoFinDeMes),
            cifra(t('agenda_en_3_meses'), agenda.saldoFinal),
          ]),
          const SizedBox(height: Espacio.m),
          Row(children: [
            Expanded(
              child: Text('+ ${FormatoMoneda.cop(agenda.entradas)}',
                  style: tema.bodySmall.copyWith(
                      color: ColoresFinanzas.ingresos, fontFeatures: _cifras)),
            ),
            Expanded(
              child: Text('− ${FormatoMoneda.cop(agenda.salidas)}',
                  style: tema.bodySmall.copyWith(
                      color: ColoresFinanzas.egresos, fontFeatures: _cifras)),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: tema.secondaryText),
          ]),
          if (agenda.primerNegativo != null) ...[
            const SizedBox(height: Espacio.m),
            AlertaSaldoNegativo(agenda: agenda),
          ],
        ],
      ),
    );
  }
}

/// Aviso de que el disponible quedaría negativo, con fecha y mínimo.
class AlertaSaldoNegativo extends StatelessWidget {
  final AgendaDto agenda;

  const AlertaSaldoNegativo({super.key, required this.agenda});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final fecha = textoDiaAgenda(context, agenda.primerNegativo!, agenda.desde);
    return Container(
      padding: const EdgeInsets.all(Espacio.m),
      decoration: BoxDecoration(
        color: tema.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radios.s),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.warning_amber_rounded, color: tema.error, size: 20),
        const SizedBox(width: Espacio.s),
        Expanded(
          child: Text(
            '${textos.getText('agenda_alerta_negativo')} $fecha. '
            '${textos.getText('agenda_minimo')} ${FormatoMoneda.cop(agenda.saldoMinimo)}.',
            style: tema.bodySmall.copyWith(color: tema.error),
          ),
        ),
      ]),
    );
  }
}

/// Fila de un evento: ícono, título, detalle, marcas y valor.
class FilaEventoAgenda extends StatelessWidget {
  final EventoAgendaDto evento;
  final VoidCallback? onTap;

  const FilaEventoAgenda({super.key, required this.evento, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final marcas = [
      textos.getText(evento.tipo.clave),
      if (evento.atrasado) textos.getText('agenda_atrasado'),
      if (evento.estimado) textos.getText('agenda_estimado'),
      if (evento.detalle != null) evento.detalle!,
    ].join(' · ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor:
            colorEfecto(evento.efecto, tema).withValues(alpha: 0.12),
        child: Icon(iconoEventoAgenda(evento.tipo),
            size: 18, color: colorEfecto(evento.efecto, tema)),
      ),
      title: Text(evento.titulo,
          style: tema.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(marcas,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: tema.bodySmall.copyWith(
              color: evento.atrasado ? tema.error : tema.secondaryText)),
      trailing: Text(textoEfecto(evento.efecto, evento.valor),
          style: tema.titleSmall.copyWith(
              color: colorEfecto(evento.efecto, tema), fontFeatures: _cifras)),
    );
  }
}
