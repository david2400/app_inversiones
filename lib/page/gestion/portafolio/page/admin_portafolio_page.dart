import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inversiones/page/frecuenciaPago/dto/frecuencia_pago_dto.dart';
import 'package:inversiones/page/frecuenciaPago/states/frecuencia_pago_page_state.dart';
import 'package:inversiones/page/gestion/portafolio/states/admin_portafolio_page_state.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:inversiones/ui/models/drop_down_button_model.dart';
import 'package:inversiones/ui/utils/flutter_flow_drop_down.dart';
import 'package:inversiones/ui/utils/flutter_flow_icon_button.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/flutter_flow_widgets.dart';
import 'package:inversiones/ui/utils/form_field_controller.dart';

export 'package:inversiones/page/gestion/tipoProyecto/states/tipo_proyecto_page_state.dart';
import 'package:inversiones/page/gestion/tipoProyecto/states/tipo_proyecto_page_state.dart';


class AdminPortafolioPage extends StatefulWidget {
  final int idProyecto;

  const AdminPortafolioPage({super.key, required this.idProyecto});

  @override
  State<AdminPortafolioPage> createState() => _AdminPortafolioPageState();
}

class _AdminPortafolioPageState extends State<AdminPortafolioPage> {
  late AdminPortafolioPageState _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late TipoProyectoPageState _modelTipoProyecto;
  late FrecuenciaPagoPageState _modelFrecuenciaPago;

  late List<DropDownButtonModel> _listaFrecuenciaPago = [];
  late List<DropDownButtonModel> _listaTipoPortafolio = [];

  @override
  void initState() {
    super.initState();

    _model = createModel(context, () => AdminPortafolioPageState());
    _modelTipoProyecto = createModel(context, () => TipoProyectoPageState());
    _modelFrecuenciaPago =
        createModel(context, () => FrecuenciaPagoPageState());

    _model.nombreFocus ??= FocusNode();
    _model.nombreController ??= TextEditingController();

    _model.nroCuentaFocus ??= FocusNode();
    _model.nroCuentaController ??= TextEditingController();

    _model.descripcionFocus ??= FocusNode();
    _model.descripcionController ??= TextEditingController();

    _model.interesFocus ??= FocusNode();
    _model.interesController ??= TextEditingController();
    _initParams();
  }

  void _initParams() async {
    List<DropDownButtonModel> lista = await listarFrecuenciaPago();
    List<DropDownButtonModel> listaTipoProyecto = await listarTipoProyecto();

    setState(() {
      _listaFrecuenciaPago = lista;
      _listaTipoPortafolio = listaTipoProyecto;
    });
  }

  Future<List<DropDownButtonModel>> listarFrecuenciaPago() async {
    List<FrecuenciaPagoDto> list =
        await _modelFrecuenciaPago.listarFrecuenciaPago();

    List<DropDownButtonModel> listDropDownButtonModel = [];

    for (var element in list) {
      DropDownButtonModel downButtonModel = DropDownButtonModel(
          id: element.idFrecuenciaPago,
          value: element.tiempo.toString() + " " + element.formato);
      listDropDownButtonModel.add(downButtonModel);
    }

    return listDropDownButtonModel;
  }

  Future<List<DropDownButtonModel>> listarTipoProyecto() async {
    List<TipoProyectoDto> list = await _modelTipoProyecto.listarTipoProyectos();

    List<DropDownButtonModel> listDropDownButtonModel = [];

    for (var element in list) {
      DropDownButtonModel downButtonModel =
          DropDownButtonModel(id: element.idTipoProyecto, value: element.nombre);
      listDropDownButtonModel.add(downButtonModel);
    }

    return listDropDownButtonModel;
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void onSubmitForm() async {
    try {
      await _model.insertPortafolio();
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
                              _headerAdminPortafolio(),
                              _formAdminPortafolio()
                            ],
                          )),
                    ),
                  ),
                ],
              ),
            )));
  }

  Widget _headerAdminPortafolio() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          FFLocalizations.of(context).getText(
            'xnadgj6u' /* Portafolio */,
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

  Widget _formAdminPortafolio() {
    List<DropDownButtonModel> _listRenta = [
      DropDownButtonModel(
          id: 'F',
          value: FFLocalizations.of(context).getText(
            'aptpkmd01' /* Tipo de proyecto */,
          )),
      DropDownButtonModel(
          id: 'V',
          value: FFLocalizations.of(context).getText(
            'aptpkmd02' /* Tipo de proyecto */,
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
                'xnadgj3u' /* Nombre proyecto */,
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
            controller: _model.nroCuentaController,
            focusNode: _model.nroCuentaFocus,
            obscureText: false,
            decoration: InputDecoration(
              labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0,
                  ),
              hintText: FFLocalizations.of(context).getText(
                'xnadgj5u' /* Numero de cuenta */,
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
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              // Limita solo a dígitos
            ],
            // validator: _model.textController1Validator
            //     .asValidator(context),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                child: FlutterFlowDropDown<int>(
                  controller: _model.tipoPortafolioController ??=
                      FormFieldController<int>(_model.tipoPortafolioId ??= 0),
                  options: _listaTipoPortafolio,
                  onChanged: (val) {
                    _model.tipoPortafolioId = val;
                  },
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Plus Jakarta Sans',
                        letterSpacing: 0,
                      ),
                  hintText: FFLocalizations.of(context).getText(
                    'bpy92db5' /* Please select... */,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 24,
                  ),
                  fillColor: FlutterFlowTheme.of(context).secondary,
                  elevation: 2,
                  borderColor: FlutterFlowTheme.of(context).alternate,
                  borderWidth: 2,
                  borderRadius: 8,
                  margin: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                  hidesUnderline: true,
                  isOverButton: true,
                  isSearchable: false,
                  labelText: FFLocalizations.of(context).getText(
                    'ig2y6wx6' /* Tipo de proyecto */,
                  ),
                  labelTextStyle:
                      FlutterFlowTheme.of(context).labelMedium.override(
                            fontFamily: 'Outfit',
                            letterSpacing: 0,
                          ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                child: FlutterFlowDropDown<int>(
                  controller: _model.frecuenciaPagoController ??=
                      FormFieldController<int>(_model.frecuenciaPagoId ??= 0),
                  options: _listaFrecuenciaPago,
                  onChanged: (val) {
                    _model.frecuenciaPagoId = val;
                  },
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Plus Jakarta Sans',
                        letterSpacing: 0,
                      ),
                  hintText: FFLocalizations.of(context).getText(
                    'afdpkmd01' /* Please select... */,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 24,
                  ),
                  fillColor: FlutterFlowTheme.of(context).secondary,
                  elevation: 2,
                  borderColor: FlutterFlowTheme.of(context).alternate,
                  borderWidth: 2,
                  borderRadius: 8,
                  margin: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                  hidesUnderline: true,
                  isOverButton: true,
                  isSearchable: false,
                  labelText: FFLocalizations.of(context).getText(
                    'afdpkmd01' /* Tipo de proyecto */,
                  ),
                  labelTextStyle:
                      FlutterFlowTheme.of(context).labelMedium.override(
                            fontFamily: 'Outfit',
                            letterSpacing: 0,
                          ),
                ),
              ),
            ),
          ].divide(SizedBox(width: 10)),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(1, 16, 0, 0),
                child: TextFormField(
                  controller: _model.interesController,
                  focusNode: _model.interesFocus,
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelStyle:
                        FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Plus Jakarta Sans',
                              letterSpacing: 0,
                            ),
                    hintText: FFLocalizations.of(context).getText(
                      'ta6s45j6' /* Interes E.A */,
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
                  // validator: _model.textController2Validator
                  //     .asValidator(context),

                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    // Limita solo a dígitos
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                child: FlutterFlowDropDown<String>(
                  controller: _model.tipoRentaController ??=
                      FormFieldController<String>(_model.tipoRenta ??= ''),
                  options: _listRenta,
                  onChanged: (val) => setState(() => _model.tipoRenta = val),
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Plus Jakarta Sans',
                        letterSpacing: 0,
                      ),
                  hintText: FFLocalizations.of(context).getText(
                    'zjglv7a7' /* Please select... */,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 24,
                  ),
                  fillColor: FlutterFlowTheme.of(context).secondary,
                  elevation: 2,
                  borderColor: FlutterFlowTheme.of(context).alternate,
                  borderWidth: 2,
                  borderRadius: 8,
                  margin: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                  hidesUnderline: true,
                  isOverButton: true,
                  isSearchable: false,
                  labelTextStyle:
                      FlutterFlowTheme.of(context).labelMedium.override(
                            fontFamily: 'Outfit',
                            letterSpacing: 0,
                          ),
                ),
              ),
            ),
          ].divide(SizedBox(width: 10)),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Theme(
              data: ThemeData(
                checkboxTheme: CheckboxThemeData(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                unselectedWidgetColor: FlutterFlowTheme.of(context).alternate,
              ),
              child: Checkbox(
                value: _model.exentaImpuesto ??= false,
                onChanged: (newValue) async {
                  safeSetState(() => _model.exentaImpuesto = newValue!);
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
                'xnadgj8u' /* Cuenta excenta del 4x1000? */,
              ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Outfit',
                    letterSpacing: 0,
                  ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
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
              contentPadding: EdgeInsetsDirectional.fromSTEB(20, 32, 24, 0),
            ),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Plus Jakarta Sans',
                  letterSpacing: 0,
                ),
            textAlign: TextAlign.start,
            maxLines: 4,
            // validator: _model.textController3Validator
            //     .asValidator(context),
          ),
        ),
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
