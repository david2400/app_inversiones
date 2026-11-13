import 'package:flutter/material.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_portafolio_dto.dart';
import 'package:inversiones/ui/utils/animation.dart';

import 'package:inversiones/ui/utils/flutter_flow_icon_button.dart';

import 'package:inversiones/ui/utils/flutter_flow_animations.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

import 'package:inversiones/ui/widgets/drawer_widget.dart';
export 'package:inversiones/page/movimientos/transacciones/states/transactions_page_state.dart';
import 'package:inversiones/page/movimientos/transacciones/states/transactions_page_state.dart';

class TransactionsPage extends StatefulWidget {
  final int idProyecto;
  final int idPortafolio;

  const TransactionsPage(
      {super.key, required this.idProyecto, required this.idPortafolio});

  @override
  State<TransactionsPage> createState() => _TransactionsWidgetState();
}

class _TransactionsWidgetState extends State<TransactionsPage>
    with TickerProviderStateMixin {
  late TransactionsPageState _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  late List<TransaccionPortafolioDto> _listaTransacciones = [];
  late int _ingresos = 0;
  late int _egresos = 0;
  late int _total = 0;

  /// Totales del portafolio calculados por el handler (incluye GMF y
  /// transferencias entrantes/salientes).
  Future<void> detailPortafolio() async {
    try {
      final totales = await _model.resumenPortafolio(widget.idPortafolio);
      if (!mounted) return;
      setState(() {
        _ingresos = totales.ingresos;
        _egresos = totales.totalSalidas;
        _total = totales.saldo;
      });
    } catch (_) {
      // Si falla, se conservan los valores en cero.
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TransactionsPageState());

    final animeinfo = AnimationInfo(
        // Valor por defecto
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => createAnimationEffects(
              fadeBegin: 0.0,
              fadeEnd: 1.0,
              moveBegin: Offset(0.0, 0.0),
              moveEnd: Offset(0.0, 0.0),
              scaleBegin: Offset(1.0, 1.0),
              scaleEnd: Offset(1.0, 1.0),
              delay: Duration(milliseconds: 0),
            ));

    animationsMap.addAll({
      'containerOnPageLoadAnimation1':
          getAnimaciones('containerOnPageLoadAnimation1') ?? animeinfo,
      'containerOnPageLoadAnimation2':
          getAnimaciones('containerOnPageLoadAnimation2') ?? animeinfo,
      'listViewOnPageLoadAnimation':
          getAnimaciones('listViewOnPageLoadAnimation') ?? animeinfo,
    });

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
    _initParams();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _initParams() async {
    List<TransaccionPortafolioDto> lista = await listarTransacciones();
    await detailPortafolio();
    if (!mounted) return;

    setState(() {
      _listaTransacciones = lista;
    });
  }

  Future<List<TransaccionPortafolioDto>> listarTransacciones() async {
    try {
      List<TransaccionPortafolioDto> result =
          await _model.listaTransaccionByPortafolioId(widget.idPortafolio);
      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await context.pushNamed(
              'admin_transactions',
              queryParameters: {
                'idPortafolio': serializeParam(
                    widget.idPortafolio, ParamType.int,
                    isList: false),
              }.withoutNulls,
              extra: <String, dynamic>{
                kTransitionInfoKey: const TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.bottomToTop,
                  duration: Duration(milliseconds: 220),
                ),
              },
            );

            // Recarga movimientos y totales al volver del formulario.
            _initParams();
          },
          backgroundColor: FlutterFlowTheme.of(context).tertiary,
          elevation: 8,
          child: Icon(
            Icons.post_add_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 32,
          ),
        ),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          // automaticallyImplyLeading: false,
          title: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    FFLocalizations.of(context).getText(
                      'r13uhw9n' /* Transferencias */,
                    ),
                    style: FlutterFlowTheme.of(context).displaySmall.override(
                          fontFamily: 'Outfit',
                          letterSpacing: 0,
                        ),
                  ),
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 30,
                      buttonSize: 48,
                      icon: Icon(
                        Icons.close_rounded,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 25,
                      ),
                      onPressed: () async {
                        context.goNamed(
                          'portafolio',
                          queryParameters: {
                            'idProyecto': serializeParam(
                                widget.idProyecto, ParamType.int,
                                isList: false),
                          }.withoutNulls,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [],
          centerTitle: false,
          elevation: 0,
        ),
        drawer: const DrawerWidget(),
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              _creditCard(),
              _detailsPortafolio(context),
              _listTransaction(),
            ],
          ),
        ));
  }

  Widget _creditCard() {
    final formatCOP = NumberFormat.currency(
        locale: 'es_CO', symbol: '\$', customPattern: '\u00A4 #,##0.00');

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width * 0.92,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Color(0x4B1A1F24),
                  offset: Offset(
                    0.0,
                    2,
                  ),
                )
              ],
              gradient: LinearGradient(
                colors: [Color(0xFF00968A), Color(0xFFF2A384)],
                stops: [0, 1],
                begin: AlignmentDirectional(0.94, -1),
                end: AlignmentDirectional(-0.94, 1),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset(
                        'assets/images/visa@3x.png',
                        width: 44,
                        height: 14,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 24, 20, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          '6t7n9ugd' /* Balance */,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Plus Jakarta Sans',
                              color: FlutterFlowTheme.of(context).primary,
                              letterSpacing: 0,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        formatCOP.format(_total),
                        style:
                            FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: 'Outfit',
                                  color: FlutterFlowTheme.of(context).tertiary,
                                  fontSize: 32,
                                  letterSpacing: 0,
                                ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          'lr97k2rc' /* **** 0149 */,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Roboto Mono',
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0,
                            ),
                      ),
                      Text(
                        FFLocalizations.of(context).getText(
                          'l9racj60' /* 05/25 */,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Roboto Mono',
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _detailsPortafolio() {
  //   final formatCOP = NumberFormat.currency(
  //       locale: 'es_CO', symbol: '\$', customPattern: '\u00A4 #,##0.00');
  //
  //   return Padding(
  //     padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.max,
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Container(
  //           width: MediaQuery.sizeOf(context).width * 0.44,
  //           height: 140,
  //           decoration: BoxDecoration(
  //             color: FlutterFlowTheme.of(context).secondary,
  //             boxShadow: [
  //               BoxShadow(
  //                 blurRadius: 4,
  //                 color: Color(0x3F14181B),
  //                 offset: Offset(
  //                   0.0,
  //                   3,
  //                 ),
  //               )
  //             ],
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Padding(
  //             padding: EdgeInsets.all(12),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.max,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   FFLocalizations.of(context).getText(
  //                     'hfwbiivj' /* Income */,
  //                   ),
  //                   textAlign: TextAlign.start,
  //                   style: FlutterFlowTheme.of(context).bodySmall.override(
  //                         fontFamily: 'Plus Jakarta Sans',
  //                         letterSpacing: 0,
  //                       ),
  //                 ),
  //                 Padding(
  //                   padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 12),
  //                   child: Text(
  //                     formatCOP.format(_ingresos),
  //                     textAlign: TextAlign.start,
  //                     style: FlutterFlowTheme.of(context).displaySmall.override(
  //                           fontFamily: 'Outfit',
  //                           color: FlutterFlowTheme.of(context).tertiary,
  //                           fontSize: 25,
  //                           letterSpacing: 0,
  //                         ),
  //                   ),
  //                 ),
  //                 Container(
  //                   width: 80,
  //                   height: 28,
  //                   decoration: BoxDecoration(
  //                     color: Color(0x4D39D2C0),
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.max,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Text(
  //                         FFLocalizations.of(context).getText(
  //                           'ns4vt604' /* 4.5%  */,
  //                         ),
  //                         textAlign: TextAlign.start,
  //                         style: FlutterFlowTheme.of(context)
  //                             .bodyMedium
  //                             .override(
  //                               fontFamily: 'Plus Jakarta Sans',
  //                               color: FlutterFlowTheme.of(context).tertiary,
  //                               letterSpacing: 0,
  //                             ),
  //                       ),
  //                       Icon(
  //                         Icons.trending_up_rounded,
  //                         color: FlutterFlowTheme.of(context).tertiary,
  //                         size: 24,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation1']!),
  //         Container(
  //           width: MediaQuery.sizeOf(context).width * 0.44,
  //           height: 140,
  //           decoration: BoxDecoration(
  //             color: FlutterFlowTheme.of(context).secondary,
  //             boxShadow: [
  //               BoxShadow(
  //                 blurRadius: 4,
  //                 color: Color(0x3F14181B),
  //                 offset: Offset(
  //                   0.0,
  //                   3,
  //                 ),
  //               )
  //             ],
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Padding(
  //             padding: EdgeInsets.all(12),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.max,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   FFLocalizations.of(context).getText(
  //                     'wcsc04wg' /* Spending */,
  //                   ),
  //                   textAlign: TextAlign.start,
  //                   style: FlutterFlowTheme.of(context).bodySmall.override(
  //                         fontFamily: 'Plus Jakarta Sans',
  //                         letterSpacing: 0,
  //                       ),
  //                 ),
  //                 Padding(
  //                   padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 12),
  //                   child: Text(
  //                     formatCOP.format(_egresos),
  //                     textAlign: TextAlign.start,
  //                     style: FlutterFlowTheme.of(context).titleSmall.override(
  //                           fontFamily: 'Outfit',
  //                           color: FlutterFlowTheme.of(context).error,
  //                           fontSize: 25,
  //                           letterSpacing: 0,
  //                         ),
  //                   ),
  //                 ),
  //                 Container(
  //                   width: 80,
  //                   height: 28,
  //                   decoration: BoxDecoration(
  //                     color: Color(0x9AF06A6A),
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   child: Row(
  //                     mainAxisSize: MainAxisSize.max,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Text(
  //                         FFLocalizations.of(context).getText(
  //                           '8xnbsdnb' /* 4.5%  */,
  //                         ),
  //                         textAlign: TextAlign.start,
  //                         style:
  //                             FlutterFlowTheme.of(context).bodyMedium.override(
  //                                   fontFamily: 'Plus Jakarta Sans',
  //                                   color: FlutterFlowTheme.of(context).error,
  //                                   letterSpacing: 0,
  //                                 ),
  //                       ),
  //                       Icon(
  //                         Icons.trending_down,
  //                         color: FlutterFlowTheme.of(context).error,
  //                         size: 24,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation2']!),
  //       ],
  //     ),
  //   );
  // }

  Widget _detailsPortafolio(BuildContext context) {
    final formatCOP = NumberFormat.currency(
        locale: 'es_CO', symbol: '\$', customPattern: '¤ #,##0.00');

    return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCard(
                context,
                FFLocalizations.of(context).getText(
                  'hfwbiivj' /* Income */,
                ),
                formatCOP.format(_ingresos),
                Colors.green,
                Icons.trending_up),
            _buildCard(
                context,
                FFLocalizations.of(context).getText(
                  'wcsc04wg' /* Spending */,
                ),
                formatCOP.format(_egresos),
                Colors.red,
                Icons.trending_down),
          ],
        ));
  }

  Widget _buildCard(BuildContext context, String title, String amount,
      Color color, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.44,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondary,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black26,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(amount,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: 4),
              Text("4.5%", style: TextStyle(color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _listTransaction() {
    return Expanded(
        child: ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: _listaTransacciones.length,
      itemBuilder: (context, index) {
        return _itemsListTransaction(_listaTransacciones[index]);
      },
    )).animateOnPageLoad(animationsMap['listViewOnPageLoadAnimation']!);
  }

  Widget _itemsListTransaction(TransaccionPortafolioDto transaccion) {
    final formatCOP = NumberFormat.currency(
        locale: 'es_CO', symbol: '\$', customPattern: '\u00A4 #,##0.00');

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          await context.pushNamed(
            'transactions_details',
            queryParameters: {
              'idTransaccion': serializeParam(
                  transaccion.idTransferencia, ParamType.int,
                  isList: false),
            }.withoutNulls,
            extra: <String, dynamic>{
              kTransitionInfoKey: const TransitionInfo(
                hasTransition: true,
                transitionType: PageTransitionType.bottomToTop,
                duration: Duration(milliseconds: 220),
              ),
            },
          );
          // Si el movimiento se anuló, recarga lista y totales.
          _initParams();
        },
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).success,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transaccion.idTransferencia.toString(),
                        style: FlutterFlowTheme.of(context)
                            .titleMedium
                            .override(
                              fontFamily: 'Plus Jakarta Sans',
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0,
                            ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: FlutterFlowTheme.of(context).accent4,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                Text(
                  transaccion.destinoCuenta ??
                      transaccion.destinoAlternativo ??
                      '',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Outfit',
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0,
                      ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transaccion.tipoTransferencia,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Plus Jakarta Sans',
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0,
                            ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
                            child: Text(
                              FFLocalizations.of(context).getText(
                                'c81i1ybg' /* Total Spent */,
                              ),
                              textAlign: TextAlign.end,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: Color(0xB3FFFFFF),
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w300,
                                  ),
                            ),
                          ),
                          Text(
                            formatCOP.format(transaccion.valor),
                            textAlign: TextAlign.end,
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                  fontFamily: 'Outfit',
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
