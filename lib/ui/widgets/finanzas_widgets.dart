import 'package:flutter/material.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
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
