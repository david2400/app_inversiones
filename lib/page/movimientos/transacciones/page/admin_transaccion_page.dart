import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/states/tipo_transaccion_page_state.dart';
import 'package:inversiones/ui/models/drop_down_button_model.dart';
import 'package:inversiones/ui/utils/animation.dart';

import 'package:inversiones/ui/utils/flutter_flow_animations.dart';
import 'package:inversiones/ui/utils/flutter_flow_drop_down.dart';
import 'package:inversiones/ui/utils/flutter_flow_icon_button.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/flutter_flow_widgets.dart';
import 'package:inversiones/ui/utils/form_field_controller.dart';

import 'package:inversiones/page/motivos/states/motivos_page_state.dart';

export 'package:inversiones/page/movimientos/transacciones/states/admin_transaccion_page_state.dart';
import 'package:inversiones/page/movimientos/transacciones/states/admin_transaccion_page_state.dart';

class AdminTransaccionPage extends StatefulWidget {
  final int? idPortafolio;

  const AdminTransaccionPage({super.key, this.idPortafolio});

  @override
  State<AdminTransaccionPage> createState() => _AdminTransaccionPageState();
}

class _AdminTransaccionPageState extends State<AdminTransaccionPage>
    with TickerProviderStateMixin {
  late AdminTransaccionPageState _model;
  late TipoTransaccionPageState _modelTipoTransaccion;
  late MotivosPageState _modelMotivo;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  late List<DropDownButtonModel> _listaTipoTransferencia = [];
  late List<DropDownButtonModel> _listaMotivos = [];
  late List<DropDownButtonModel> _listaPortafolios = [];
  late List<TipoTransaccionDto> _listaTipoTransferenciaDto = [];
  late bool _mostrarPortafolio = false;
  late bool _mostrarCuentaDestino = false;

  Future listarTipoTransaccion() async {
    List<TipoTransaccionDto> list =
        await _modelTipoTransaccion.listarTipoTransaccion();

    List<DropDownButtonModel> listDropDownButtonModel = [];

    for (var element in list) {
      DropDownButtonModel downButtonModel = DropDownButtonModel(
          id: element.idTipoTransaccion,
          value: element.nombre.toString() + " - " + element.tipoFuente);
      listDropDownButtonModel.add(downButtonModel);
    }

    setState(() {
      _listaTipoTransferencia = listDropDownButtonModel;
      _listaTipoTransferenciaDto = list;
    });
  }

  Future<List<DropDownButtonModel>> listarMotivos() async {
    List<MotivosDto> list = await _modelMotivo.listarMotivos();

    List<DropDownButtonModel> listDropDownButtonModel = [];

    for (var element in list) {
      DropDownButtonModel downButtonModel =
          DropDownButtonModel(id: element.idMotivo, value: element.nombre);
      listDropDownButtonModel.add(downButtonModel);
    }

    return listDropDownButtonModel;
  }

  Future<List<DropDownButtonModel>> listarPortafolios() async {
    List<PortafolioDto> list = await _model.listarPortafolios();

    List<DropDownButtonModel> listDropDownButtonModel = [];

    for (var element in list) {
      DropDownButtonModel downButtonModel =
          DropDownButtonModel(id: element.idPortafolio, value: element.nombre);
      listDropDownButtonModel.add(downButtonModel);
    }

    return listDropDownButtonModel;
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminTransaccionPageState());
    _modelTipoTransaccion =
        createModel(context, () => TipoTransaccionPageState());
    _modelMotivo = createModel(context, () => MotivosPageState());

    _model.valorController ??= TextEditingController();
    _model.valorFocus ??= FocusNode();

    _model.nroCuentaDestinoAlternativa ??= FocusNode();
    _model.nroCuentaDestinoAlternativaController ??= TextEditingController();

    _model.descripcionFocus ??= FocusNode();
    _model.descripcionController ??= TextEditingController();

    _model.portafolioId = widget.idPortafolio != null ? widget.idPortafolio : 0;
    final animeinfo = AnimationInfo(
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
      'buttonOnPageLoadAnimation':
          getAnimaciones('buttonOnPageLoadAnimation') ?? animeinfo,
      'textFieldOnPageLoadAnimation1':
          getAnimaciones('textFieldOnPageLoadAnimation1') ?? animeinfo,
      'dropDownOnPageLoadAnimation1':
          getAnimaciones('dropDownOnPageLoadAnimation1') ?? animeinfo,
      'dropDownOnPageLoadAnimation2':
          getAnimaciones('dropDownOnPageLoadAnimation2') ?? animeinfo,
      'textFieldOnPageLoadAnimation2':
          getAnimaciones('textFieldOnPageLoadAnimation2') ?? animeinfo
    });

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
    _initParams();
  }

  void onSubmitForm() async {
    try {
      await _model.insertTransaccion();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(FFLocalizations.of(context).getText(
          'ig2y6wx6' /* Tipo de proyecto */,
        )),
        duration: const Duration(seconds: 3),
      ));
      context.pushNamed(
        'transfer_complete',
        extra: <String, dynamic>{
          kTransitionInfoKey: const TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.bottomToTop,
            duration: Duration(milliseconds: 220),
          ),
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  void _initParams() async {
    await listarTipoTransaccion();
    List<DropDownButtonModel> listaMotivos = await listarMotivos();
    List<DropDownButtonModel> listaPortafolios = await listarPortafolios();

    setState(() {
      _mostrarPortafolio = widget.idPortafolio == null ? true : false;
      _listaMotivos = listaMotivos;
      _listaPortafolios = listaPortafolios;
    });
  }

  void onChangeTipoTransaccion(int tipoTransaccion) {
    var tipoSeleccionado = _listaTipoTransferenciaDto.firstWhere(
      (tipo) => tipo.idTipoTransaccion == tipoTransaccion,
    );
    if (tipoSeleccionado.tipoFuente == TipoFuente.transferencia) {
      _mostrarCuentaDestino = true;
    } else {
      _mostrarCuentaDestino = false;
    }
    setState(() => _model.tipoTransferenciaId = tipoTransaccion);
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
            children: [_headerTrasacciones(), _formTrasacciones()],
          ))),
    );
  }

  Widget _headerTrasacciones() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(25, 16, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            FFLocalizations.of(context).getText(
              'pe3o18oh' /* Transferencia */,
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
      ).animateOnPageLoad(animationsMap['dropDownOnPageLoadAnimation2']!),
    );
  }

  Widget _formTrasacciones() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Visibility(
          visible: _mostrarPortafolio,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
            child: FlutterFlowDropDown<int>(
              controller: _model.portafolioController ??=
                  FormFieldController<int>(_model.portafolioId ??= 0),
              options: _listaPortafolios,
              onChanged: (val) {
                _model.portafolioId = val;
              },
              width: MediaQuery.sizeOf(context).width * 0.5,
              height: 60,
              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0,
                  ),
              hintText: FFLocalizations.of(context).getText(
                '3ct4fj7p' /* Tipo de transferencia */,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: FlutterFlowTheme.of(context).secondaryText,
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
            ).animateOnPageLoad(animationsMap['dropDownOnPageLoadAnimation2']!),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
          child: TextFormField(
            controller: _model.valorController,
            focusNode: _model.valorFocus,
            obscureText: false,
            decoration: InputDecoration(
              labelStyle: FlutterFlowTheme.of(context).displaySmall.override(
                    fontFamily: 'Outfit',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w300,
                  ),
              hintText: FFLocalizations.of(context).getText(
                'r89hyhq3' /* Cantidad */,
              ),
              hintStyle: FlutterFlowTheme.of(context).displaySmall.override(
                    fontFamily: 'Outfit',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w300,
                  ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0x00000000),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0x00000000),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0x00000000),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 24, 24),
              prefixIcon: Icon(
                Icons.attach_money_rounded,
                color: FlutterFlowTheme.of(context).primaryText,
                size: 32,
              ),
            ),
            style: FlutterFlowTheme.of(context).displaySmall.override(
                  fontFamily: 'Outfit',
                  letterSpacing: 0,
                ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please input required';
              }
              return null;
            },
          ).animateOnPageLoad(animationsMap['textFieldOnPageLoadAnimation1']!),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
          child: FlutterFlowDropDown<int>(
            controller: _model.tipoTransferenciaController ??=
                FormFieldController<int>(_model.tipoTransferenciaId ??= 0),
            options: _listaTipoTransferencia,
            onChanged: (val) {
              onChangeTipoTransaccion(val!);
            },
            width: MediaQuery.sizeOf(context).width * 0.9,
            height: 60,
            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Plus Jakarta Sans',
                  letterSpacing: 0,
                ),
            hintText: FFLocalizations.of(context).getText(
              'tdtge5oj' /* Tipo de transferencia */,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
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
          ).animateOnPageLoad(animationsMap['dropDownOnPageLoadAnimation2']!),
        ),
        Visibility(
          visible: _mostrarCuentaDestino,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                FlutterFlowDropDown<int>(
                  controller: _model.nroCuentaDestinoController ??=
                      FormFieldController<int>(_model.nroCuentaDestinoId ??= 0),
                  options: _listaPortafolios,
                  onChanged: (val) {
                    _model.nroCuentaDestinoId = val;
                  },
                  disabled: _model.cuentaExterma!,
                  width: MediaQuery.sizeOf(context).width,
                  height: 60,
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Plus Jakarta Sans',
                        letterSpacing: 0,
                      ),
                  hintText: FFLocalizations.of(context).getText(
                    'tdtge7oj' /* Motivo */,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText,
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
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Theme(
                      data: ThemeData(
                        checkboxTheme: CheckboxThemeData(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        unselectedWidgetColor:
                            FlutterFlowTheme.of(context).alternate,
                      ),
                      child: Checkbox(
                        value: _model.cuentaExterma ??= false,
                        onChanged: (newValue) async {
                          _model.nroCuentaDestinoId = 0;
                          _model.nroCuentaDestinoAlternativaController.text =
                              "";
                          safeSetState(() => _model.cuentaExterma = newValue!);
                        },
                        side: BorderSide(
                          width: 2,
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                        activeColor: FlutterFlowTheme.of(context).primary,
                        checkColor: FlutterFlowTheme.of(context).info,
                      ),
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        'tdtge8oj' /* Tipo de proyecto */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Outfit',
                            letterSpacing: 0,
                          ),
                    ),
                  ],
                )
              ],
            ),
          ).animateOnPageLoad(animationsMap['dropDownOnPageLoadAnimation2']!),
        ),
        Visibility(
          visible: _model.cuentaExterma!,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
            child: TextFormField(
              focusNode: _model.nroCuentaDestinoAlternativa,
              controller: _model.nroCuentaDestinoAlternativaController,
              obscureText: false,
              decoration: InputDecoration(
                labelText: FFLocalizations.of(context).getText(
                  'uxo88fjc' /* Cuenta Alterna */,
                ),
                labelStyle: FlutterFlowTheme.of(context).displaySmall.override(
                      fontFamily: 'Outfit',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 14,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w500,
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
                contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 24, 24),
              ),
              style: FlutterFlowTheme.of(context).displaySmall.override(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    letterSpacing: 0,
                    fontWeight: FontWeight.normal,
                  ),
            ).animateOnPageLoad(
                animationsMap['textFieldOnPageLoadAnimation2']!),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
          child: FlutterFlowDropDown<int>(
            controller: _model.motivoController ??=
                FormFieldController<int>(_model.motivoId ??= 0),
            options: _listaMotivos,
            onChanged: (val) {
              _model.motivoId = val;
            },
            width: MediaQuery.sizeOf(context).width * 0.9,
            height: 60,
            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Plus Jakarta Sans',
                  letterSpacing: 0,
                ),
            hintText: FFLocalizations.of(context).getText(
              'tcckgjcg' /* Motivo */,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
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
          ).animateOnPageLoad(animationsMap['dropDownOnPageLoadAnimation2']!),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
          child: TextFormField(
            controller: _model.descripcionController,
            focusNode: _model.descripcionFocus,
            obscureText: false,
            decoration: InputDecoration(
              labelText: FFLocalizations.of(context).getText(
                'o08j3ttv' /* Descripcion */,
              ),
              labelStyle: FlutterFlowTheme.of(context).displaySmall.override(
                    fontFamily: 'Outfit',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 14,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                  ),
              hintText: FFLocalizations.of(context).getText(
                'n5mlnxrm' /* Descripcion */,
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
              contentPadding: EdgeInsetsDirectional.fromSTEB(20, 24, 24, 24),
            ),
            style: FlutterFlowTheme.of(context).displaySmall.override(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal,
                ),
            // validator: _model.textController1Validator
            //     .asValidator(context),
          ).animateOnPageLoad(animationsMap['textFieldOnPageLoadAnimation2']!),
        ),
        Padding(
            padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
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
                        // context.pushNamed(
                        //   'transfer_complete',
                        //   extra: <String, dynamic>{
                        //     kTransitionInfoKey: TransitionInfo(
                        //       hasTransition: true,
                        //       transitionType: PageTransitionType.bottomToTop,
                        //       duration: Duration(milliseconds: 220),
                        //     ),
                        //   },
                        // );
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
