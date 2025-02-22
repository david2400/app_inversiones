import 'package:flutter/material.dart';
import 'package:inversiones/ui/models/drop_down_button_model.dart';
import 'package:inversiones/ui/utils/flutter_flow_drop_down.dart';
import 'package:inversiones/ui/utils/flutter_flow_icon_button.dart';
import 'package:inversiones/ui/utils/flutter_flow_animations.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

import 'package:inversiones/ui/utils/flutter_flow_widgets.dart';
import 'package:inversiones/ui/utils/form_field_controller.dart';

export 'package:inversiones/page/frecuenciaPago/states/admin_frecuencia_pago_page_state.dart';
import 'package:inversiones/page/frecuenciaPago/states/admin_frecuencia_pago_page_state.dart';

class AdminFrecuenciaPagoPage extends StatefulWidget {
  const AdminFrecuenciaPagoPage({super.key});

  @override
  State<AdminFrecuenciaPagoPage> createState() =>
      _AdminFrecuenciaPagoPageState();
}

class _AdminFrecuenciaPagoPageState extends State<AdminFrecuenciaPagoPage>
    with TickerProviderStateMixin {
  late AdminFrecuenciaPagoPageState _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminFrecuenciaPagoPageState());

  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void onSubmitForm() async {
    try {
      await _model.insertFrecuenciaPago();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(FFLocalizations.of(context).getText(
          'ig2y6wx6' /* Tipo de proyecto */,
        )),
        duration: const Duration(seconds: 3),
      ));
      context.pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Material(
                  color: Colors.transparent,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                  ),
                  child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                        ),
                      ),
                      child: Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(20, 44, 20, 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              _headerFrecuenciaPago(),
                              _formFrecuenciaPago()
                            ],
                          ))),
                ),
              ],
            ),
          )),
    );
  }

  Widget _headerFrecuenciaPago() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          FFLocalizations.of(context).getText(
            'afdpkmd01' /* Tipo de proyecto */,
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
              context.pop();
            },
          ),
        ),
      ],
    );
  }

  Widget _formFrecuenciaPago() {
    List<DropDownButtonModel> _listTiempo = [
      DropDownButtonModel(id: 1, value: '1'),
      DropDownButtonModel(id: 2, value: '2'),
      DropDownButtonModel(id: 3, value: '3'),
      DropDownButtonModel(id: 4, value: '4'),
      DropDownButtonModel(id: 5, value: '5'),
      DropDownButtonModel(id: 6, value: '6'),
      DropDownButtonModel(id: 7, value: '7'),
      DropDownButtonModel(id: 15, value: '15'),
      DropDownButtonModel(id: 30, value: '30'),
      DropDownButtonModel(id: 60, value: '60'),
    ];

    List<DropDownButtonModel> _listFormato = [
      DropDownButtonModel(
          id: 'D',
          value: FFLocalizations.of(context).getText(
            'o10j3ttv' /* Dias */,
          )),
      DropDownButtonModel(
          id: 'M',
          value: FFLocalizations.of(context).getText(
            'o11j3ttv' /* Meses */,
          )),
      DropDownButtonModel(
          id: 'Y',
          value: FFLocalizations.of(context).getText(
            'o12j3ttv' /* Años */,
          )),
    ];

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20, 44, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              child: FlutterFlowDropDown<int>(
                controller: _model.tiempoController ??=
                    FormFieldController<int>(_model.tiempo ?? 0),
                options: _listTiempo,
                onChanged: (val) {
                  _model.tiempo = val;
                },
                width: MediaQuery.sizeOf(context).width * 0.9,
                height: 60,
                textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Plus Jakarta Sans',
                      letterSpacing: 0,
                    ),
                hintText: FFLocalizations.of(context).getText(
                  'afdpkmd02' /* Tiempo */,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 15,
                ),
                fillColor: FlutterFlowTheme.of(context).secondary,
                elevation: 2,
                borderColor: FlutterFlowTheme.of(context).alternate,
                borderWidth: 2,
                borderRadius: 8,
                margin: EdgeInsetsDirectional.fromSTEB(20, 20, 12, 20),
                hidesUnderline: true,
                isSearchable: false,
              )),
          Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              child: FlutterFlowDropDown<String>(
                controller: _model.formatoController ??=
                    FormFieldController<String>(_model.formato ?? ''),
                options: _listFormato,
                onChanged: (val) {
                  _model.formato = val;
                },
                width: MediaQuery.sizeOf(context).width * 0.9,
                height: 60,
                textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Plus Jakarta Sans',
                      letterSpacing: 0,
                    ),
                hintText: FFLocalizations.of(context).getText(
                  'afdpkmd03' /* Formato */,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: FlutterFlowTheme.of(context).primaryText,
                  size: 15,
                ),
                fillColor: FlutterFlowTheme.of(context).secondary,
                elevation: 2,
                borderColor: FlutterFlowTheme.of(context).alternate,
                borderWidth: 2,
                borderRadius: 8,
                margin: EdgeInsetsDirectional.fromSTEB(20, 20, 12, 20),
                hidesUnderline: true,
                isSearchable: false,
              )),
          Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      FFButtonWidget(
                        onPressed: () async {
                          onSubmitForm();
                        },
                        text: FFLocalizations.of(context).getText(
                          'xaw2jdst' /* Send Transfer */,
                        ),
                        options: FFButtonOptions(
                          width: 300,
                          height: 70,
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding:
                              EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: FlutterFlowTheme.of(context).success,
                          textStyle: FlutterFlowTheme.of(context)
                              .displaySmall
                              .override(
                                fontFamily: 'Outfit',
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0,
                              ),
                          elevation: 0,
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              )
              //.animateOnPageLoad(animationsMap['rowOnPageLoadAnimation2']!),
              ),
        ],
      ),
    );
  }
}
