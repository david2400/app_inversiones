import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/page/movimientos/historial/states/movimientos_page_state.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/resultado_movimientos_dto.dart';
import 'package:inversiones/domain/consultas/transaccion_portafolio_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/drawer_widget.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

/// Historial de todos los movimientos con búsqueda, filtros y totales.
class MovimientosPage extends StatefulWidget {
  const MovimientosPage({super.key});

  @override
  State<MovimientosPage> createState() => _MovimientosPageState();
}

class _MovimientosPageState extends State<MovimientosPage> {
  late MovimientosPageState _model;
  late Future<ResultadoMovimientosDto> _resultado;
  Timer? _espera;

  static const _retrasoBusqueda = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MovimientosPageState());
    _resultado = _model.buscar();
    _cargarCatalogos();
  }

  @override
  void dispose() {
    _espera?.cancel();
    _model.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogos() async {
    try {
      await _model.cargarCatalogos();
      if (mounted) setState(() {});
    } catch (_) {
      // Sin catálogos, los filtros avanzados quedan vacíos.
    }
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  void _buscar([VoidCallback? cambio]) {
    setState(() {
      cambio?.call();
      _resultado = _model.buscar();
    });
  }

  void _alEscribir(String _) {
    _espera?.cancel();
    _espera = Timer(_retrasoBusqueda, _buscar);
  }

  Future<void> _abrir(String ruta,
      [Map<String, dynamic> parametros = const {}]) async {
    await context.pushNamed(ruta, queryParameters: parametros);
    if (mounted) _buscar();
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('his_titulo')),
        backgroundColor: tema.primaryBackground,
      ),
      drawer: const DrawerWidget(),
      backgroundColor: tema.primaryBackground,
      floatingActionButton: FloatingActionButton(
        tooltip: _t('frm_titulo'),
        onPressed: () => _abrir('admin_transactions'),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _filtros(tema),
            Expanded(
              child: FutureBuilder<ResultadoMovimientosDto>(
                future: _resultado,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(child: Text(_t('dash_error')));
                  }
                  return _lista(snapshot.data!, tema);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtros(FlutterFlowTheme tema) {
    final m = _model;
    Widget chip<T>(String etiqueta, T valor, T actual, ValueChanged<T> alElegir) =>
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(etiqueta),
            selected: valor == actual,
            onSelected: (_) => _buscar(() => alElegir(valor)),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: m.busquedaController,
            onChanged: _alEscribir,
            decoration: InputDecoration(
              hintText: _t('his_buscar'),
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              chip(_t('exp_mes'), PeriodoMovimientos.mesActual, m.periodo,
                  (v) => m.periodo = v),
              chip(_t('his_mes_anterior'), PeriodoMovimientos.mesAnterior,
                  m.periodo, (v) => m.periodo = v),
              chip(_t('exp_anio'), PeriodoMovimientos.anioActual, m.periodo,
                  (v) => m.periodo = v),
              chip(_t('exp_todo'), PeriodoMovimientos.todo, m.periodo,
                  (v) => m.periodo = v),
            ]),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              chip<String?>(_t('his_todos'), null, m.tipoFuente,
                  (v) => m.tipoFuente = v),
              chip<String?>(_t('rep_ingresos'), TipoFuente.ingreso,
                  m.tipoFuente, (v) => m.tipoFuente = v),
              chip<String?>(_t('rep_egresos'), TipoFuente.egreso, m.tipoFuente,
                  (v) => m.tipoFuente = v),
              chip<String?>(_t('frm_transferencia'), TipoFuente.transferencia,
                  m.tipoFuente, (v) => m.tipoFuente = v),
            ]),
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              m.filtrosAvanzadosActivos == 0
                  ? _t('his_mas_filtros')
                  : '${_t('his_mas_filtros')} (${m.filtrosAvanzadosActivos})',
              style: tema.bodyMedium,
            ),
            children: [
              _desplegable(_t('det_cuenta'), m.idPortafolio,
                  {for (final p in m.portafolios) p.idPortafolio!: p.nombre},
                  (v) => m.idPortafolio = v),
              const SizedBox(height: 8),
              _desplegable(_t('det_tercero'), m.idTercero,
                  {for (final t in m.terceros) t.idTercero!: t.nombre},
                  (v) => m.idTercero = v),
              const SizedBox(height: 8),
              _desplegable(_t('frm_motivo'), m.idMotivo,
                  {for (final mo in m.motivos) mo.idMotivo!: mo.nombre},
                  (v) => m.idMotivo = v),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _desplegable(String etiqueta, int? valor, Map<int, String> opciones,
      ValueChanged<int?> alCambiar) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: etiqueta,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: opciones.containsKey(valor) ? valor : null,
          isExpanded: true,
          isDense: true,
          items: [
            DropdownMenuItem<int>(value: null, child: Text(_t('his_todos'))),
            for (final o in opciones.entries)
              DropdownMenuItem<int>(
                  value: o.key,
                  child: Text(o.value, overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (v) => _buscar(() => alCambiar(v)),
        ),
      ),
    );
  }

  Widget _lista(ResultadoMovimientosDto r, FlutterFlowTheme tema) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      children: [
        _totales(r, tema),
        const SizedBox(height: 8),
        if (r.movimientos.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: Text(_t('his_vacio'),
                    style: tema.bodyMedium.copyWith(color: tema.secondaryText))),
          ),
        for (final mov in r.movimientos) _fila(mov, tema),
        if (r.truncado)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '${_t('his_truncado')} ${r.movimientos.length} / ${r.cantidadTotal}',
              textAlign: TextAlign.center,
              style: tema.bodySmall.copyWith(color: tema.secondaryText),
            ),
          ),
      ],
    );
  }

  Widget _totales(ResultadoMovimientosDto r, FlutterFlowTheme tema) {
    Widget dato(String titulo, int valor, Color? color) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: tema.bodySmall.copyWith(color: tema.secondaryText)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(FormatoMoneda.cop(valor),
                    style: tema.titleSmall
                        .copyWith(color: color ?? tema.primaryText)),
              ),
            ],
          ),
        );
    final t = r.totales;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tema.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tema.alternate),
      ),
      child: Row(children: [
        dato(_t('rep_ingresos'), t.ingresos, null),
        dato(_t('rep_egresos'), t.totalSalidas, null),
        dato(_t('rep_neto'), t.neto, t.neto < 0 ? tema.error : null),
      ]),
    );
  }

  Widget _fila(TransaccionPortafolioDto mov, FlutterFlowTheme tema) {
    final esIngreso = mov.tipoFuente == TipoFuente.ingreso;
    final esTransferencia = mov.tipoFuente == TipoFuente.transferencia;
    final color = esIngreso ? ColoresFinanzas.ingresos : ColoresFinanzas.egresos;
    final signo = esIngreso ? '+' : (esTransferencia ? '' : '−');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        esIngreso
            ? Icons.south_west_rounded
            : esTransferencia
                ? Icons.swap_horiz_rounded
                : Icons.north_east_rounded,
        color: esTransferencia ? tema.secondaryText : color,
      ),
      title: Text(mov.flujo, style: tema.bodyLarge, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          mov.createdAt?.substring(0, 10),
          mov.tipoTransferencia,
          mov.motivo,
          mov.descripcion,
        ].where((t) => t != null && t.isNotEmpty).join('  ·  '),
        style: tema.bodySmall.copyWith(color: tema.secondaryText),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text('$signo ${FormatoMoneda.cop(mov.valor)}',
          style: tema.titleSmall),
      onTap: () => _abrir('transactions_details', {
        'idTransaccion':
            serializeParam(mov.idTransferencia, ParamType.int, isList: false),
      }),
    );
  }
}
