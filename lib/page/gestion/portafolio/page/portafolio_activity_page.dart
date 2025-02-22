import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_charts.dart';
import 'package:inversiones/ui/utils/flutter_flow_icon_button.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

export 'package:inversiones/page/gestion/portafolio/states/portafolio_activiy_page_state.dart';
import 'package:inversiones/page/gestion/portafolio/states/portafolio_activiy_page_state.dart';

class PortafolioActivityPage extends StatefulWidget {
  final int idProyecto;

  const PortafolioActivityPage({super.key, required this.idProyecto});

  // final DocumentReference? budgetDetails;

  @override
  State<PortafolioActivityPage> createState() => _PortafolioActiviyPageState();
}

class _PortafolioActiviyPageState extends State<PortafolioActivityPage> {
  late PortafolioActiviyPageState _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PortafolioActiviyPageState());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Widget detalleProyecto() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
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
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: Text(
                        "budgetname",
                        // portafolioActiviyPageBudgetsRecord
                        //     .budetName,
                        style: FlutterFlowTheme.of(context)
                            .displaySmall
                            .override(
                              fontFamily: 'Outfit',
                              color: FlutterFlowTheme.of(context).primaryText,
                              letterSpacing: 0,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                    child: Text(
                      formatNumber(
                        456456,
                        // portafolioActiviyPageBudgetsRecord
                        //     .budgetAmountNumber,
                        formatType: FormatType.decimal,
                        decimalType: DecimalType.automatic,
                        currency: '\$',
                      ),
                      style: FlutterFlowTheme.of(context).displaySmall.override(
                            fontFamily: 'Outfit',
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 36,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 4),
                    child: Text(
                      FFLocalizations.of(context).getText(
                        'p0gf1lfy' /* Per Month */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Plus Jakarta Sans',
                            color: Color(0xB3FFFFFF),
                            letterSpacing: 0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Time",
                    // valueOrDefault<String>(
                    //   portafolioActiviyPageBudgetsRecord.budgetTime,
                    //   '4 Days Left',
                    // ),
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Plus Jakarta Sans',
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
                            'ti7ipegi' /* Total Spent */,
                          ),
                          textAlign: TextAlign.end,
                          style:
                              FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: Color(0xB3FFFFFF),
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.w300,
                                  ),
                        ),
                      ),
                      Text(
                        valueOrDefault<String>(
                          formatNumber(
                            123,
                            // portafolioActiviyPageBudgetsRecord
                            //     .budgetSpentNumber,
                            formatType: FormatType.decimal,
                            decimalType: DecimalType.automatic,
                            currency: '\$',
                          ),
                          '2,502',
                        ),
                        textAlign: TextAlign.end,
                        style: FlutterFlowTheme.of(context)
                            .headlineSmall
                            .override(
                              fontFamily: 'Outfit',
                              color: FlutterFlowTheme.of(context).primaryText,
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
    );
  }


  Widget graficosDetalle() {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
      ),
      child: Container(
        width: double.infinity,
        height: 250,
        child: FlutterFlowLineChart(
          data: [
            // FFLineChartData(
            //   xData: chartTransactionsRecordList,
            //   yData: chartTransactionsRecordList,
            //   settings: LineChartBarData(
            //     color: Color(0xFF39D2C0),
            //     barWidth: 2,
            //     isCurved: true,
            //     preventCurveOverShooting: true,
            //     dotData: FlDotData(show: false),
            //     belowBarData: BarAreaData(
            //       show: true,
            //       color: Color(0x6639D2C0),
            //     ),
            //   ),
            // ),
          ],
          chartStylingInfo: ChartStylingInfo(
            enableTooltip: true,
            tooltipBackgroundColor:
            FlutterFlowTheme.of(context).alternate,
            backgroundColor:
            FlutterFlowTheme.of(context).primary,
            showBorder: false,
          ),
          axisBounds: AxisBounds(),
          xAxisLabelInfo: AxisLabelInfo(
            showLabels: true,
            labelTextStyle: FlutterFlowTheme.of(context)
                .bodyMedium
                .override(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              letterSpacing: 0,
            ),
            labelInterval: 10,
          ),
          yAxisLabelInfo: AxisLabelInfo(
            showLabels: true,
            labelTextStyle: FlutterFlowTheme.of(context)
                .bodyMedium
                .override(
              fontFamily: 'Plus Jakarta Sans',
              letterSpacing: 0,
            ),
            labelInterval: 10,
          ),
        ),
      ),
    );
  }


  Widget trasaccionesList() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          FFLocalizations.of(context).getText(
            'ifi6fmsa' /* Transactions */,
          ),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: 'Plus Jakarta Sans',
            letterSpacing: 0,
          ),
        ),
        Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 24),
            child: InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.pushNamed('paymentDetailsPage');
              },
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: List.generate(
                    0,
                    // transactionListTransactionsRecordList.length,
                        (transactionListIndex) {
                      // final transactionListTransactionsRecord =
                      //     transactionListTransactionsRecordList[
                      //         transactionListIndex];
                      return Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            0, 0, 0, 8),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            // context.pushNamed(
                            //   'paymentDetailsPage',
                            //   queryParameters: {
                            //     'transactionDetails': serializeParam(
                            //       transactionListTransactionsRecord
                            //           .reference,
                            //       ParamType.DocumentReference,
                            //     ),
                            //     'userSpent': serializeParam(
                            //       transactionListTransactionsRecord
                            //           .user,
                            //       ParamType.DocumentReference,
                            //     ),
                            //   }.withoutNulls,
                            // );
                          },
                          child: Container(
                            width: MediaQuery.sizeOf(context).width *
                                0.92,
                            height: 70,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondary,
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
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context
                                    .pushNamed('paymentDetailsPage');
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional
                                        .fromSTEB(8, 0, 0, 0),
                                    child: Card(
                                      clipBehavior:
                                      Clip.antiAliasWithSaveLayer,
                                      color: Color(0x6639D2C0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(40),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons
                                              .monetization_on_rounded,
                                          color: FlutterFlowTheme.of(
                                              context)
                                              .tertiary,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional
                                          .fromSTEB(12, 0, 0, 0),
                                      child: Column(
                                        mainAxisSize:
                                        MainAxisSize.max,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "",
                                              // transactionListTransactionsRecord
                                              //     .transactionName,
                                              style: FlutterFlowTheme
                                                  .of(context)
                                                  .headlineSmall
                                                  .override(
                                                fontFamily:
                                                'Outfit',
                                                letterSpacing: 0,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            EdgeInsetsDirectional
                                                .fromSTEB(
                                                0, 4, 0, 0),
                                            child: Text(
                                              FFLocalizations.of(
                                                  context)
                                                  .getText(
                                                'ak9m8szp' /* Income */,
                                              ),
                                              style: FlutterFlowTheme
                                                  .of(context)
                                                  .bodyMedium
                                                  .override(
                                                fontFamily:
                                                'Plus Jakarta Sans',
                                                letterSpacing: 0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional
                                        .fromSTEB(12, 0, 12, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "0",
                                          // transactionListTransactionsRecord
                                          //     .transactionAmount,
                                          textAlign: TextAlign.end,
                                          style: FlutterFlowTheme.of(
                                              context)
                                              .titleSmall
                                              .override(
                                            fontFamily:
                                            'Plus Jakarta Sans',
                                            color: FlutterFlowTheme
                                                .of(context)
                                                .tertiary,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          EdgeInsetsDirectional
                                              .fromSTEB(
                                              0, 4, 0, 0),
                                          child: Text(
                                            "",
                                            // dateTimeFormat(
                                            //   'MMMEd',
                                            //   transactionListTransactionsRecord
                                            //       .transactionTime!,
                                            //   locale:
                                            //       FFLocalizations.of(
                                            //               context)
                                            //           .languageCode,
                                            // ),
                                            textAlign: TextAlign.end,
                                            style: FlutterFlowTheme
                                                .of(context)
                                                .bodyMedium
                                                .override(
                                              fontFamily:
                                              'Plus Jakarta Sans',
                                              fontSize: 12,
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
                          ),
                        ),
                      );
                    }),
              ),
            )),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        leading: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            context.pop();
          },
          child: Icon(
            Icons.chevron_left_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 32,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
            child: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30,
              buttonSize: 48,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 25,
              ),
              onPressed: () async {
                // context.pushNamed(
                //   'budget_DELETE',
                //   queryParameters: {
                //     'budgetList': serializeParam(
                //       portafolioActiviyPageBudgetsRecord.reference,
                //       ParamType.DocumentReference,
                //     ),
                //   }.withoutNulls,
                //   extra: <String, dynamic>{
                //     kTransitionInfoKey: TransitionInfo(
                //       hasTransition: true,
                //       transitionType: PageTransitionType.bottomToTop,
                //       duration: Duration(milliseconds: 220),
                //     ),
                //   },
                // );
              },
            ),
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            detalleProyecto(),
            graficosDetalle(),
            trasaccionesList()
          ],
        ),
      ),
    );
    //   },
    // );
  }
}
