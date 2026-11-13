import 'package:flutter/material.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:inversiones/page/reportes/states/reporte_anual_page_state.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/drawer_widget.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

class ReporteAnualPage extends StatefulWidget {
  const ReporteAnualPage({super.key});

  @override
  State<ReporteAnualPage> createState() => _ReporteAnualPageState();
}

class _ReporteAnualPageState extends State<ReporteAnualPage> {
  late ReporteAnualPageState _model;
  late Future<ReporteAnualDto> _reporte;
  List<ProyectoDto> _proyectos = [];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReporteAnualPageState());
    _reporte = _model.cargarReporte();
    _cargarProyectos();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _cargarProyectos() async {
    try {
      final proyectos = await _model.listarProyectos();
      if (mounted) setState(() => _proyectos = proyectos);
    } catch (_) {
      // Sin proyectos el reporte sigue disponible para "Todos".
    }
  }

  void _recargar(VoidCallback cambio) {
    setState(() {
      cambio();
      _reporte = _model.cargarReporte();
    });
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('rep_titulo')),
        backgroundColor: tema.primaryBackground,
      ),
      drawer: const DrawerWidget(),
      backgroundColor: tema.primaryBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _filtros(tema),
            const SizedBox(height: 16),
            FutureBuilder<ReporteAnualDto>(
              future: _reporte,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text(_t('dash_error'), style: tema.bodyMedium);
                }
                final reporte = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _resumen(reporte.total, tema),
                    const SizedBox(height: 24),
                    _tablaMensual(reporte, tema),
                    ..._seccionesFlujo(reporte, tema),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtros(FlutterFlowTheme tema) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => _recargar(() => _model.anio--),
            ),
            Text('${_model.anio}', style: tema.titleMedium),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: _model.esAnioActual
                  ? null
                  : () => _recargar(() => _model.anio++),
            ),
          ],
        ),
        DropdownButton<int?>(
          value: _model.idProyecto,
          dropdownColor: tema.secondaryBackground,
          items: [
            DropdownMenuItem<int?>(
                value: null, child: Text(_t('rep_todos'))),
            for (final p in _proyectos)
              DropdownMenuItem<int?>(
                  value: p.idProyecto, child: Text(p.nombre)),
          ],
          onChanged: (valor) => _recargar(() => _model.idProyecto = valor),
        ),
      ],
    );
  }

  Widget _resumen(TotalMensualDto total, FlutterFlowTheme tema) {
    Widget dato(String titulo, int valor, {bool resaltar = false}) =>
        Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tema.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tema.alternate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: tema.bodySmall.copyWith(color: tema.secondaryText)),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(FormatoMoneda.cop(valor),
                    style: tema.titleMedium.copyWith(
                        color: resaltar && valor < 0
                            ? tema.error
                            : tema.primaryText)),
              ),
            ],
          ),
        );

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        dato(_t('rep_ingresos'), total.ingresos),
        dato(_t('rep_egresos'), total.egresos),
        dato(_t('rep_gmf'), total.impuestos),
        dato(_t('rep_neto'), total.neto, resaltar: true),
      ],
    );
  }

  Widget _tablaMensual(ReporteAnualDto reporte, FlutterFlowTheme tema) {
    final estiloNumero = tema.bodyMedium;
    DataCell celda(int valor) => DataCell(Text(FormatoMoneda.cop(valor),
        style: estiloNumero.copyWith(
            color: valor < 0 ? tema.error : tema.primaryText)));

    final total = reporte.total;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: tema.bodySmall.copyWith(color: tema.secondaryText),
        columns: [
          DataColumn(label: Text(_t('rep_mes'))),
          DataColumn(label: Text(_t('rep_ingresos')), numeric: true),
          DataColumn(label: Text(_t('rep_egresos')), numeric: true),
          DataColumn(label: Text(_t('rep_gmf')), numeric: true),
          DataColumn(label: Text(_t('rep_neto')), numeric: true),
        ],
        rows: [
          for (final mes in reporte.meses)
            DataRow(cells: [
              DataCell(Text(_mes(mes.periodo), style: estiloNumero)),
              celda(mes.ingresos),
              celda(mes.egresos),
              celda(mes.impuestos),
              celda(mes.neto),
            ]),
          DataRow(cells: [
            DataCell(Text(_t('rep_total'), style: tema.titleSmall)),
            celda(total.ingresos),
            celda(total.egresos),
            celda(total.impuestos),
            celda(total.neto),
          ]),
        ],
      ),
    );
  }

  List<Widget> _seccionesFlujo(ReporteAnualDto reporte, FlutterFlowTheme tema) {
    Widget titulo(String clave, String ayuda) => Padding(
          padding: const EdgeInsets.only(top: 28, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_t(clave), style: tema.titleMedium),
              Text(_t(ayuda),
                  style: tema.bodySmall.copyWith(color: tema.secondaryText)),
            ],
          ),
        );

    return [
      titulo('rep_origen', 'rep_origen_ayuda'),
      BarrasPorConcepto(
        datos: reporte.ingresosPorOrigen,
        color: ColoresFinanzas.ingresos,
        textoSinDato: _t('dash_sin_especificar'),
        textoVacio: _t('dash_sin_ingresos'),
        textoOtros: _t('dash_otros'),
        maximoFilas: 8,
      ),
      titulo('rep_destino', 'rep_destino_ayuda'),
      BarrasPorConcepto(
        datos: reporte.egresosPorDestino,
        color: ColoresFinanzas.egresos,
        textoSinDato: _t('dash_sin_especificar'),
        textoVacio: _t('dash_sin_egresos'),
        textoOtros: _t('dash_otros'),
        maximoFilas: 8,
      ),
      titulo('rep_motivo', 'rep_motivo_ayuda'),
      BarrasPorConcepto(
        datos: reporte.egresosPorMotivo,
        color: ColoresFinanzas.egresos,
        textoSinDato: _t('dash_sin_motivo'),
        textoVacio: _t('dash_sin_egresos'),
        textoOtros: _t('dash_otros'),
        maximoFilas: 8,
      ),
      titulo('rep_flujos', 'rep_flujos_ayuda'),
      ListaFlujos(
        flujos: reporte.flujosEntreCuentas,
        textoVacio: _t('rep_sin_flujos'),
        textoExterna: _t('rep_cuenta_externa'),
        textoGmf: _t('rep_gmf'),
      ),
    ];
  }

  /// `2026-03` -> `03/2026`.
  static String _mes(String periodo) {
    final partes = periodo.split('-');
    return partes.length == 2 ? '${partes[1]}/${partes[0]}' : periodo;
  }
}
