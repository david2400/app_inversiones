
import 'package:flutter/material.dart';
import 'package:inversiones/ui/models/drop_down_button_model.dart';
import 'package:inversiones/ui/utils/flutter_flow_drop_down.dart';
import 'package:inversiones/ui/utils/flutter_flow_icon_button.dart';

import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

import 'package:inversiones/ui/utils/flutter_flow_widgets.dart';
import 'package:inversiones/ui/utils/form_field_controller.dart';

export 'package:inversiones/page/movimientos/tipoTransaccion/states/admin_transaccion_page_state.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/states/admin_transaccion_page_state.dart';

class AdminTipoTransaccionPage extends StatefulWidget {
  const AdminTipoTransaccionPage({super.key});

  @override
  State<AdminTipoTransaccionPage> createState() =>
      _AdminTipoTransaccionPageState();
}

class _AdminTipoTransaccionPageState extends State<AdminTipoTransaccionPage>
    with TickerProviderStateMixin {
  late AdminTipoTransaccionPageState _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminTipoTransaccionPageState());

    _model.nombreFocus ??= FocusNode();
    _model.nombreController ??= TextEditingController();

    _model.descripcionFocus ??= FocusNode();
    _model.descripcionController ??= TextEditingController();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void onSubmitForm() async {
    try {
      await _model.insertTipoTransaccion();
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
                              _headerTipoTransferencia(),
                              _formTipoTransferencia()
                            ],
                          ))),
                ),
              ],
            ),
          )),
    );
  }

  Widget _headerTipoTransferencia() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              FFLocalizations.of(context).getText(
                'tdtge5oj' /* Tipo de proyecto */,
              ),
              style: FlutterFlowTheme.of(context).displaySmall.override(
                    fontFamily: 'Outfit',
                    letterSpacing: 0,
                  ),
            ),
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

  Widget _formTipoTransferencia() {
    List<DropDownButtonModel> _listTipoFuente = [
      DropDownButtonModel(
          id: 'I',
          value: FFLocalizations.of(context).getText(
            'tdtge1oj' /* Select Budget */,
          )),
      DropDownButtonModel(
          id: 'E',
          value: FFLocalizations.of(context).getText(
            'tdtge2oj' /* Select Budget */,
          )),
      DropDownButtonModel(
          id: 'M',
          value: FFLocalizations.of(context).getText(
            'tdtge3oj' /* Select Budget */,
          )),
    ];

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(1, 16, 0, 0),
          child: TextFormField(
            controller: _model.nombreController,
            focusNode: _model.nombreFocus,
            obscureText: false,
            decoration: InputDecoration(
              labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0,
                  ),
              hintText: FFLocalizations.of(context).getText(
                'o07j3ttv' /* Nombre */,
              ),
              hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0,
                  ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0x00000000),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0x00000000),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0x00000000),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Plus Jakarta Sans',
                  letterSpacing: 0,
                ),
            textAlign: TextAlign.start,
            // validator: _model.textController1Validator
            //     .asValidator(context),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(1, 16, 0, 0),
          child: TextFormField(
            controller: _model.descripcionController,
            focusNode: _model.descripcionFocus,
            obscureText: false,
            decoration: InputDecoration(
              labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0,
                  ),
              hintText: FFLocalizations.of(context).getText(
                'o08j3ttv' /* Descripcion */,
              ),
              hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0,
                  ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0x00000000),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0x00000000),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0x00000000),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Plus Jakarta Sans',
                  letterSpacing: 0,
                ),
            textAlign: TextAlign.start,
            // validator: _model.textController1Validator
            //     .asValidator(context),
          ),
        ),
        Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
            child: FlutterFlowDropDown<String>(
              controller: _model.tipoFuenteController ??=
                  FormFieldController<String>(_model.tipoFuente ??= ''),
              options: _listTipoFuente,
              onChanged: (val) {
                _model.tipoFuente = val;
              },
              width: MediaQuery.sizeOf(context).width * 0.9,
              height: 60,
              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0,
                  ),
              hintText: FFLocalizations.of(context).getText(
                'tdtge6oj' /* Select Budget */,
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
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
    );
  }
}
