import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/page/gestion/portafolio/dto/saldo_portafolio_dto.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:inversiones/page/home/states/home_page_state.dart';
import 'package:inversiones/page/presupuestos/dto/presupuesto_dto.dart';
import 'package:inversiones/page/recurrentes/dto/recurrente_dto.dart';
import 'package:inversiones/domain/consultas/transaccion_portafolio_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/drawer_widget.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomePageState _model;
  late Future<ResumenFinancieroDto> _resumen;
  late Future<List<EjecucionPresupuestoDto>> _presupuestos;
  late Future<List<RecurrenteDto>> _pendientes;

  /// Presupuestos visibles en el inicio (los de mayor porcentaje usado).
  static const _maximoPresupuestos = 4;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageState());
    _resumen = _model.cargarResumen();
    _presupuestos = _model.cargarPresupuestos();
    _pendientes = _model.cargarPendientes();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _recargar() async {
    final nuevo = _model.cargarResumen();
    setState(() {
      _resumen = nuevo;
      _presupuestos = _model.cargarPresupuestos();
      _pendientes = _model.cargarPendientes();
    });
    await nuevo;
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(_t('dash_titulo')),
        backgroundColor: tema.primaryBackground,
      ),
      drawer: const DrawerWidget(),
      backgroundColor: tema.primaryBackground,
      body: SafeArea(
        child: FutureBuilder<ResumenFinancieroDto>(
          future: _resumen,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: tema.primary),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _Mensaje(
                texto: _t('dash_error'),
                accion: _t('dash_reintentar'),
                onAccion: _recargar,
              );
            }
            final resumen = snapshot.data!;
            if (resumen.sinPortafolios) {
              return _Mensaje(
                texto: _t('dash_sin_portafolios'),
                accion: _t('dash_crear_portafolio'),
                onAccion: () async => context.goNamed('proyects'),
              );
            }
            return RefreshIndicator(
              onRefresh: _recargar,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _tarjetaSaldo(resumen),
                  const SizedBox(height: 12),
                  _tarjetasMes(resumen.mesActual),
                  _seccionPendientes(),
                  _seccionPresupuestos(),
                  const SizedBox(height: 24),
                  _titulo(_t('dash_historico')),
                  _GraficoHistorico(
                    historico: resumen.historico,
                    etiquetaIngresos: _t('dash_ingresos'),
                    etiquetaEgresos: _t('dash_egresos'),
                  ),
                  const SizedBox(height: 24),
                  _titulo(_t('dash_por_origen')),
                  BarrasPorConcepto(
                    datos: resumen.ingresosPorOrigen,
                    color: ColoresFinanzas.ingresos,
                    textoSinDato: _t('dash_sin_especificar'),
                    textoVacio: _t('dash_sin_ingresos'),
                    textoOtros: _t('dash_otros'),
                  ),
                  const SizedBox(height: 24),
                  _titulo(_t('dash_por_motivo')),
                  BarrasPorConcepto(
                    datos: resumen.egresosPorMotivo,
                    color: ColoresFinanzas.egresos,
                    textoSinDato: _t('dash_sin_motivo'),
                    textoVacio: _t('dash_sin_egresos'),
                    textoOtros: _t('dash_otros'),
                  ),
                  const SizedBox(height: 24),
                  _titulo(_t('dash_portafolios')),
                  ...resumen.saldos.map(_filaPortafolio),
                  const SizedBox(height: 24),
                  _titulo(_t('dash_movimientos')),
                  if (resumen.ultimosMovimientos.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(_t('dash_sin_movimientos'),
                          style: tema.bodyMedium
                              .copyWith(color: tema.secondaryText)),
                    ),
                  ...resumen.ultimosMovimientos.map(_filaMovimiento),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Movimientos fijos del mes aún sin registrar, con botón "Registrar".
  Widget _seccionPendientes() {
    return FutureBuilder<List<RecurrenteDto>>(
      future: _pendientes,
      builder: (context, snapshot) {
        final pendientes = snapshot.data ?? [];
        if (pendientes.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _titulo(_t('dash_pendientes'))),
                  TextButton(
                    onPressed: () => context.goNamed('recurrentes'),
                    child: Text(_t('dash_ver_todos')),
                  ),
                ],
              ),
              for (final fijo in pendientes)
                FilaRecurrente(
                  fijo: fijo,
                  textoRegistrado: _t('fij_registrado'),
                  textoPendiente: _t('fij_pendiente'),
                  textoPausado: _t('fij_pausado'),
                  textoRegistrar: _t('fij_registrar'),
                  onRegistrar: () => _registrarFijo(fijo),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _registrarFijo(RecurrenteDto fijo) async {
    final messenger = ScaffoldMessenger.of(context);
    final textoGuardado = _t('frm_guardado');
    try {
      await _model.registrarFijo(fijo.idRecurrente);
      messenger.showSnackBar(
          SnackBar(content: Text('${fijo.nombre}: $textoGuardado')));
      await _recargar();
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  /// Presupuestos del mes con mayor avance; no se muestra si no hay.
  Widget _seccionPresupuestos() {
    return FutureBuilder<List<EjecucionPresupuestoDto>>(
      future: _presupuestos,
      builder: (context, snapshot) {
        final presupuestos = snapshot.data ?? [];
        if (presupuestos.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _titulo(_t('dash_presupuestos'))),
                  TextButton(
                    onPressed: () => context.goNamed('presupuestos'),
                    child: Text(_t('dash_ver_todos')),
                  ),
                ],
              ),
              for (final p in presupuestos.take(_maximoPresupuestos))
                FilaPresupuesto(
                  presupuesto: p,
                  textoDisponible: _t('pre_disponible'),
                  textoExcedido: _t('pre_excedido'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(texto, style: FlutterFlowTheme.of(context).titleMedium),
      );

  Widget _tarjetaSaldo(ResumenFinancieroDto resumen) {
    final tema = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tema.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tema.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_t('dash_saldo_total'),
              style: tema.bodySmall.copyWith(color: tema.secondaryText)),
          const SizedBox(height: 4),
          Text(FormatoMoneda.cop(resumen.saldoTotal),
              style: tema.displaySmall.copyWith(
                  color: resumen.saldoTotal < 0 ? tema.error : tema.primaryText)),
          const SizedBox(height: 8),
          Text(
            '${_t('dash_neto_mes')}: ${FormatoMoneda.cop(resumen.mesActual.neto)}'
            '  ·  ${_t('dash_gmf_mes')}: ${FormatoMoneda.cop(resumen.mesActual.impuestos)}',
            style: tema.bodySmall.copyWith(color: tema.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _tarjetasMes(TotalMensualDto mes) {
    return Row(
      children: [
        Expanded(
          child: _TarjetaIndicador(
            titulo: _t('dash_ingresos_mes'),
            valor: FormatoMoneda.cop(mes.ingresos),
            color: ColoresFinanzas.ingresos,
            icono: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TarjetaIndicador(
            titulo: _t('dash_egresos_mes'),
            valor: FormatoMoneda.cop(mes.totalSalidas),
            color: ColoresFinanzas.egresos,
            icono: Icons.trending_down,
          ),
        ),
      ],
    );
  }

  Widget _filaPortafolio(SaldoPortafolioDto saldo) {
    final tema = FlutterFlowTheme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.account_balance_wallet_outlined,
          color: tema.secondaryText),
      title: Text(saldo.nombre, style: tema.bodyLarge),
      trailing: Text(
        FormatoMoneda.cop(saldo.saldo),
        style: tema.titleSmall.copyWith(
            color: saldo.saldo < 0 ? tema.error : tema.primaryText),
      ),
      onTap: saldo.proyectoId == null
          ? null
          : () => context.pushNamed(
                'transactions',
                queryParameters: {
                  'idPortafolio': serializeParam(
                      saldo.idPortafolio, ParamType.int,
                      isList: false),
                  'idProyecto': serializeParam(
                      saldo.proyectoId, ParamType.int,
                      isList: false),
                }.withoutNulls,
              ),
    );
  }

  Widget _filaMovimiento(TransaccionPortafolioDto movimiento) {
    final tema = FlutterFlowTheme.of(context);
    final esIngreso = movimiento.tipoFuente == TipoFuente.ingreso;
    final color =
        esIngreso ? ColoresFinanzas.ingresos : ColoresFinanzas.egresos;
    final detalle = movimiento.flujo;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
          esIngreso ? Icons.south_west_rounded : Icons.north_east_rounded,
          color: color),
      title: Text(movimiento.tipoTransferencia, style: tema.bodyLarge),
      subtitle: Text(
        [movimiento.createdAt?.substring(0, 10), detalle]
            .where((t) => t != null && t.isNotEmpty)
            .join('  ·  '),
        style: tema.bodySmall.copyWith(color: tema.secondaryText),
      ),
      trailing: Text(
        '${esIngreso ? '+' : '−'} ${FormatoMoneda.cop(movimiento.valor)}',
        style: tema.titleSmall.copyWith(color: tema.primaryText),
      ),
    );
  }
}

class _TarjetaIndicador extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color color;
  final IconData icono;

  const _TarjetaIndicador({
    required this.titulo,
    required this.valor,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tema.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tema.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(titulo,
                    style: tema.bodySmall.copyWith(color: tema.secondaryText),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valor, style: tema.titleLarge),
          ),
        ],
      ),
    );
  }
}

/// Barras agrupadas de ingresos y egresos (incluye GMF) por mes.
class _GraficoHistorico extends StatelessWidget {
  final List<TotalMensualDto> historico;
  final String etiquetaIngresos;
  final String etiquetaEgresos;

  static const _anchoBarra = 8.0;
  static const _separacionBarras = 2.0;
  static const _alto = 200.0;

  const _GraficoHistorico({
    required this.historico,
    required this.etiquetaIngresos,
    required this.etiquetaEgresos,
  });

  /// `2026-11` -> `11/26` (independiente del idioma).
  static String _mesCorto(String periodo) {
    final partes = periodo.split('-');
    if (partes.length != 2 || partes[0].length < 2) return periodo;
    return '${partes[1]}/${partes[0].substring(partes[0].length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final estiloEje = tema.bodySmall.copyWith(color: tema.secondaryText);
    final maximo = historico.fold<int>(
        0,
        (m, t) => [m, t.ingresos, t.totalSalidas]
            .reduce((a, b) => a > b ? a : b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Leyenda(color: ColoresFinanzas.ingresos, texto: etiquetaIngresos),
            const SizedBox(width: 16),
            _Leyenda(color: ColoresFinanzas.egresos, texto: etiquetaEgresos),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _alto,
          child: BarChart(
            BarChartData(
              maxY: maximo == 0 ? 1 : maximo * 1.15,
              alignment: BarChartAlignment.spaceAround,
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
                    getTitlesWidget: (valor, meta) => valor == meta.max
                        ? const SizedBox.shrink()
                        : Text(FormatoMoneda.compacto(valor),
                            style: estiloEje),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (valor, meta) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(_mesCorto(historico[valor.toInt()].periodo),
                          style: estiloEje),
                    ),
                  ),
                ),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => tema.secondaryBackground,
                  getTooltipItem: (grupo, _, barra, indiceBarra) =>
                      BarTooltipItem(
                    '${indiceBarra == 0 ? etiquetaIngresos : etiquetaEgresos}\n'
                    '${FormatoMoneda.cop(barra.toY)}',
                    tema.bodySmall.copyWith(color: tema.primaryText),
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < historico.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: _separacionBarras,
                    barRods: [
                      _barra(historico[i].ingresos, ColoresFinanzas.ingresos),
                      _barra(historico[i].totalSalidas,
                          ColoresFinanzas.egresos),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartRodData _barra(int valor, Color color) => BarChartRodData(
        toY: valor.toDouble(),
        color: color,
        width: _anchoBarra,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      );
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String texto;

  const _Leyenda({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(texto, style: tema.bodySmall.copyWith(color: tema.primaryText)),
      ],
    );
  }
}

/// Mensaje centrado con una acción (estado vacío o de error).
class _Mensaje extends StatelessWidget {
  final String texto;
  final String accion;
  final Future<void> Function() onAccion;

  const _Mensaje(
      {required this.texto, required this.accion, required this.onAccion});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texto, textAlign: TextAlign.center, style: tema.bodyLarge),
            const SizedBox(height: 16),
            FilledButton(onPressed: onAccion, child: Text(accion)),
          ],
        ),
      ),
    );
  }
}
