import 'package:flutter/material.dart';
import 'package:inversiones/page/gestion/tipoProyecto/page/perfil_inversion_ui.dart';
import 'package:inversiones/page/home/dto/patrimonio_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

const _cifras = [FontFeature.tabularFigures()];

/// Texto de un porcentaje con signo y un decimal ("+4,3 %").
String textoPorcentaje(double valor) {
  final signo = valor > 0 ? '+' : '';
  return '$signo${valor.toStringAsFixed(1).replaceAll('.', ',')} %';
}

/// Color de una ganancia: verde si gana, rojo si pierde.
Color colorGanancia(int ganancia, FlutterFlowTheme tema) => ganancia > 0
    ? ColoresFinanzas.ingresos
    : ganancia < 0
        ? ColoresFinanzas.egresos
        : tema.secondaryText;

/// Tarjeta del patrimonio neto: cifra protagonista, variación del mes y
/// el desglose en cuentas / invertido / deudas.
class TarjetaPatrimonio extends StatelessWidget {
  final PatrimonioDto patrimonio;
  final VoidCallback? onTap;

  const TarjetaPatrimonio({super.key, required this.patrimonio, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final neto = patrimonio.neto;
    final variacion = patrimonio.variacionMes;
    return Tarjeta(
      onTap: onTap,
      padding: const EdgeInsets.all(Espacio.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_rounded,
                  size: 18, color: tema.secondaryText),
              const SizedBox(width: Espacio.s),
              Expanded(
                child: Text(textos.getText('pat_neto'),
                    style: tema.labelLarge.copyWith(color: tema.secondaryText)),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded, color: tema.secondaryText),
            ],
          ),
          const SizedBox(height: Espacio.s),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              FormatoMoneda.cop(neto),
              style: tema.displaySmall.copyWith(
                color: neto < 0 ? tema.error : tema.primaryText,
                fontFeatures: _cifras,
              ),
            ),
          ),
          const SizedBox(height: Espacio.xs),
          Text(
            '${variacion >= 0 ? '+' : '−'}${FormatoMoneda.cop(variacion.abs())} '
            '${textos.getText('pat_vs_mes_anterior')}',
            style: tema.bodySmall.copyWith(
                color: colorGanancia(variacion, tema), fontFeatures: _cifras),
          ),
          const SizedBox(height: Espacio.l),
          Row(
            children: [
              Expanded(
                child: _Parte(
                  titulo: textos.getText('pat_en_cuentas'),
                  valor: patrimonio.enCuentas,
                  color: tema.primary,
                ),
              ),
              Expanded(
                child: _Parte(
                  titulo: textos.getText('pat_invertido'),
                  valor: patrimonio.invertido,
                  color: ColoresFinanzas.ingresos,
                ),
              ),
              Expanded(
                child: _Parte(
                  titulo: textos.getText('pat_deudas'),
                  valor: -patrimonio.deudas,
                  color: ColoresFinanzas.egresos,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Parte extends StatelessWidget {
  final String titulo;
  final int valor;
  final Color color;

  const _Parte(
      {required this.titulo, required this.valor, required this.color});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: Espacio.xs),
          Flexible(
            child: Text(titulo,
                overflow: TextOverflow.ellipsis,
                style: tema.bodySmall.copyWith(color: tema.secondaryText)),
          ),
        ]),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(FormatoMoneda.compacto(valor.toDouble()),
              style: tema.titleSmall.copyWith(fontFeatures: _cifras)),
        ),
      ],
    );
  }
}

/// Fila de rentabilidad: nombre y riesgo; aportado y retirado; saldo,
/// ganancia y porcentaje.
class FilaRentabilidad extends StatelessWidget {
  final RentabilidadDto dato;
  final String nombreSinDato;
  final VoidCallback? onTap;

  const FilaRentabilidad(
      {super.key, required this.dato, required this.nombreSinDato, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final porcentaje = dato.porcentaje;
    final color = colorGanancia(dato.ganancia, tema);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: Espacio.m,
      onTap: onTap,
      title: Row(
        children: [
          Flexible(
            child: Text(dato.nombre ?? nombreSinDato,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.titleSmall),
          ),
          if (dato.riesgo != null) ...[
            const SizedBox(width: Espacio.s),
            EtiquetasPerfil(riesgo: dato.riesgo),
          ],
        ],
      ),
      subtitle: Text(
        '${textos.getText('pat_aportado')} ${FormatoMoneda.cop(dato.aportado)}'
        '${dato.retirado > 0 ? ' · ${textos.getText('pat_retirado')} ${FormatoMoneda.cop(dato.retirado)}' : ''}',
        style: tema.bodySmall.copyWith(color: tema.secondaryText),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(FormatoMoneda.cop(dato.saldo),
              style: tema.bodyMedium.copyWith(fontFeatures: _cifras)),
          Text(
            '${dato.ganancia >= 0 ? '+' : '−'}${FormatoMoneda.cop(dato.ganancia.abs())}'
            '${porcentaje == null ? '' : ' (${textoPorcentaje(porcentaje)})'}',
            style: tema.bodySmall.copyWith(color: color, fontFeatures: _cifras),
          ),
        ],
      ),
    );
  }
}
