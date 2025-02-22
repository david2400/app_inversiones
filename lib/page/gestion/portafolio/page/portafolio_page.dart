import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_balance_dto.dart';
import 'package:inversiones/ui/utils/animation.dart';

import 'package:inversiones/ui/utils/flutter_flow_icon_button.dart';
import 'package:inversiones/ui/utils/flutter_flow_animations.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:inversiones/ui/widgets/drawer_widget.dart';

export 'package:inversiones/page/gestion/portafolio/states/portafolio_page_state.dart';
import 'package:inversiones/page/gestion/portafolio/states/portafolio_page_state.dart';

class PortafolioPage extends StatefulWidget {
  final int idProyecto;

  const PortafolioPage({super.key, required this.idProyecto});

  @override
  State<PortafolioPage> createState() => _PortafolioPageState();
}

class _PortafolioPageState extends State<PortafolioPage>
    with TickerProviderStateMixin {
  late PortafolioPageState _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PortafolioPageState());

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
      'containerOnPageLoadAnimation3':
          getAnimaciones('containerOnPageLoadAnimation3') ?? animeinfo,
    });

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
    // _initParams();
    dataBalancePortafolio();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<List<PortafolioDto>> listarPortafolio() async {
    try {
      List<PortafolioDto> result =
          await _model.listarPortafolio(widget.idProyecto);
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<List<TransaccionBalanceDto>> dataBalancePortafolio() async {
    try {
      List<TransaccionBalanceDto> result =
          await _model.getBalanceProyecto(widget.idProyecto);

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
          final result = await context.pushNamed(
            'admin_portafolio',
            queryParameters: {
              'idProyecto': serializeParam(widget.idProyecto, ParamType.int,
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
          // if (result == true) {
          //   _initParams();
          // }
        },
        backgroundColor: FlutterFlowTheme.of(context).tertiary,
        elevation: 8,
        child: Icon(
          Icons.add_rounded,
          color: FlutterFlowTheme.of(context).primaryText,
          size: 36,
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
                    'xn2so8km' /* Portafolios */,
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
                        'proyects',
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
      body: GestureDetector(
          onTap: () => _model.unfocusNode.canRequestFocus
              ? FocusScope.of(context).requestFocus(_model.unfocusNode)
              : FocusScope.of(context).unfocus(),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _portafolioDetails(),
                        _menuPortafolio(),
                        _conteinerlistPortafolio()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _portafolioDetails() {
    final formatCOP = NumberFormat.currency(
        locale: 'es_CO', symbol: '\$', customPattern: '\u00A4 #,##0.00');

    return FutureBuilder<List<TransaccionBalanceDto>>(
      future: dataBalancePortafolio(),
      builder: (BuildContext context,
          AsyncSnapshot<List<TransaccionBalanceDto>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.hasData) {
          List<TransaccionBalanceDto> detalle = snapshot.data!;
          print(detalle);
          int ingresos = detalle.fold(0, (prev, element) {

            bool condicion = element.tipoFuente == 'I' ||
                (element.tipoFuente == 'M' &&
                    element.proyectoId != widget.idProyecto);

            return
              condicion? prev + element.valor
                : prev;
          });

          int egresos = detalle.fold(0, (prev, element) {
            bool condicion = element.tipoFuente == 'E' ||
                (element.tipoFuente == 'M' &&
                    (element.proyectoId == widget.idProyecto ||
                        element.destinoAlternativo != null));
            return condicion ? prev + element.valor : prev;
          });
          int total = ingresos - egresos;

          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondary,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x3F14181B),
                      offset: Offset(
                        0.0,
                        3,
                      ),
                    )
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          '6z1sm34j' /* Total Balance */,
                        ),
                        textAlign: TextAlign.start,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Plus Jakarta Sans',
                              letterSpacing: 0,
                            ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 12),
                        child: Text(
                          formatCOP.format(total),
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .displaySmall
                              .override(
                                fontFamily: 'Outfit',
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 32,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animateOnPageLoad(
                  animationsMap['containerOnPageLoadAnimation1']!),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.44,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondary,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x3F14181B),
                          offset: Offset(
                            0.0,
                            3,
                          ),
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FFLocalizations.of(context).getText(
                              '9b0j67se' /* Income */,
                            ),
                            textAlign: TextAlign.start,
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Plus Jakarta Sans',
                                      letterSpacing: 0,
                                    ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 8, 0, 12),
                            child: Text(
                              formatCOP.format(ingresos),
                              textAlign: TextAlign.start,
                              style: FlutterFlowTheme.of(context)
                                  .displaySmall
                                  .override(
                                    fontFamily: 'Outfit',
                                    color:
                                        FlutterFlowTheme.of(context).tertiary,
                                    fontSize: 25,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(0x4D39D2C0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  FFLocalizations.of(context).getText(
                                    '0d7w9e0i' /* 4.5%  */,
                                  ),
                                  textAlign: TextAlign.start,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Plus Jakarta Sans',
                                        color: FlutterFlowTheme.of(context)
                                            .tertiary,
                                        letterSpacing: 0,
                                      ),
                                ),
                                Icon(
                                  Icons.trending_up_rounded,
                                  color: FlutterFlowTheme.of(context).tertiary,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animateOnPageLoad(
                      animationsMap['containerOnPageLoadAnimation1']!),
                  Container(
                    width: MediaQuery.sizeOf(context).width * 0.44,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondary,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          color: Color(0x3F14181B),
                          offset: Offset(
                            0.0,
                            3,
                          ),
                        )
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FFLocalizations.of(context).getText(
                              'mggh8wu7' /* Spending */,
                            ),
                            textAlign: TextAlign.start,
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Plus Jakarta Sans',
                                      letterSpacing: 0,
                                    ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 8, 0, 12),
                            child: Text(
                              formatCOP.format(egresos),
                              textAlign: TextAlign.start,
                              style: FlutterFlowTheme.of(context)
                                  .displaySmall
                                  .override(
                                    fontFamily: 'Outfit',
                                    color: FlutterFlowTheme.of(context).error,
                                    fontSize: 25,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(0x9AF06A6A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  FFLocalizations.of(context).getText(
                                    '85pb8msl' /* 4.5%  */,
                                  ),
                                  textAlign: TextAlign.start,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Plus Jakarta Sans',
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        letterSpacing: 0,
                                      ),
                                ),
                                Icon(
                                  Icons.trending_down,
                                  color: FlutterFlowTheme.of(context).error,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animateOnPageLoad(
                      animationsMap['containerOnPageLoadAnimation2']!),
                ],
              )
            ],
          );
        }

        return Center(
          child: Text('No data available'),
        );
      },
    );
  }

  Widget _menuPortafolio() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed(
                    'admin_transactions',
                    queryParameters: {
                      'idPortafolio':
                          serializeParam(null, ParamType.int, isList: false),
                    },
                    extra: <String, dynamic>{
                      kTransitionInfoKey: const TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.bottomToTop,
                        duration: Duration(milliseconds: 220),
                      ),
                    },
                  );
                },
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.24,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                          child: Icon(
                            Icons.account_balance,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 36,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'xw3lkljd' /* Pull Out */,
                            ),
                            style: GoogleFonts.getFont(
                              'Lexend Deca',
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  final result = await context.pushNamed(
                    'portafolio_activity',
                    queryParameters: {
                      'idProyecto': serializeParam(widget.idProyecto, ParamType.int,
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

                },
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.24,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                          child: Icon(
                            Icons.stacked_line_chart_rounded,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 36,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              's56t3xya' /* Transfer */,
                            ),
                            style: GoogleFonts.getFont(
                              'Lexend Deca',
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conteinerlistPortafolio() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 12, 20, 12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  FFLocalizations.of(context).getText(
                    'bpkc110o' /* Portafolios */,
                  ),
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Plus Jakarta Sans',
                        letterSpacing: 0,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24),
            child: _listPortafolio(),
          ),
        ],
      ),
    ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation3']!);
  }

  Widget _listPortafolio() {
    return FutureBuilder<List<PortafolioDto>>(
      future: listarPortafolio(), // Llama al método que obtiene los datos
      builder:
          (BuildContext context, AsyncSnapshot<List<PortafolioDto>> snapshot) {
        // Muestra un indicador de carga mientras los datos se cargan
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          );
        }

        // Maneja los errores si la llamada falla
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.hasData) {
          List<PortafolioDto> portafolio = snapshot.data!;

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: List.generate(portafolio.length, (index) {
              return Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  // onTap: () async {
                  //   // context.pushNamed(
                  //   //   'paymentDetailsPage',
                  //   //   queryParameters: {
                  //   //     'transactionDetails':
                  //   //     serializeParam(
                  //   //       transactionListTransactionsRecord
                  //   //           .reference,
                  //   //       ParamType.DocumentReference,
                  //   //     ),
                  //   //     'userSpent': serializeParam(
                  //   //       transactionListTransactionsRecord
                  //   //           .user,
                  //   //       ParamType.DocumentReference,
                  //   //     ),
                  //   //   }.withoutNulls,
                  //   // );
                  // },
                  child: _itemsList(portafolio[index]),
                ),
              );
            }),
          );
        }

        return Center(
          child: Text('No data available'),
        );
      },
    );
  }

  Widget _itemsList(PortafolioDto portafolio) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.92,
      height: 70,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          final result = context.goNamed(
            'transactions',
            queryParameters: {
              'idPortafolio': serializeParam(
                  portafolio.idPortafolio, ParamType.int,
                  isList: false),
              'idProyecto': serializeParam(portafolio.proyectoId, ParamType.int,
                  isList: false),
            }.withoutNulls,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: Color(0x6639D2C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: FlutterFlowTheme.of(context).tertiary,
                    size: 24,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      portafolio.nombre,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            fontFamily: 'Plus Jakarta Sans',
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0,
                          ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: Text(
                        portafolio.interes.toString(),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Plus Jakarta Sans',
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    portafolio.nroCuenta ?? '',
                    // transactionListTransactionsRecord
                    //     .transactionAmount,
                    textAlign: TextAlign.end,
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Plus Jakarta Sans',
                          color: FlutterFlowTheme.of(context).tertiary,
                          letterSpacing: 0,
                        ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                    child: Text(
                      portafolio.createdAt!,
                      // dateTimeFormat(
                      //   'relative',
                      //   transactionListTransactionsRecord
                      //       .transactionTime!,
                      //   locale:
                      //   FFLocalizations.of(
                      //       context)
                      //       .languageCode,
                      // ),
                      textAlign: TextAlign.end,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Plus Jakarta Sans',
                            letterSpacing: 0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
