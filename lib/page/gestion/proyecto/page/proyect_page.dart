import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/ui/utils/animation.dart';
import 'package:inversiones/ui/widgets/drawer_widget.dart';

import 'package:inversiones/ui/utils/flutter_flow_animations.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:percent_indicator/percent_indicator.dart';

export 'package:inversiones/page/gestion/proyecto/states/proyect_page_state.dart';
import 'package:inversiones/page/gestion/proyecto/states/proyect_page_state.dart';

class ProyectPage extends StatefulWidget {
  const ProyectPage({super.key});

  @override
  State<ProyectPage> createState() => _ProyectsPageState();
}

class _ProyectsPageState extends State<ProyectPage>
    with TickerProviderStateMixin {
  late ProyectsPageModel _model;

  // late List<ProyectoDto> _listaProyecto;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProyectsPageModel());

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
      'containerOnPageLoadAnimation3':
          getAnimaciones('containerOnPageLoadAnimation3') ?? animeinfo,
    });

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
    // _listaProyecto = [];
    // _initParams();
  }

  // void _initParams() async {
  //   List<ProyectoDto> listaProyecto = await listarProyecto();
  //   setState(() {
  //     _listaProyecto = listaProyecto;
  //   });
  // }

  Future<List<ProyectoDto>> listarProyecto() async {
    try {
      List<ProyectoDto> result = await _model.listarProyectos();
      return result;
    } catch (e) {
      return [];
    }
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await context.pushNamed(
              'admin_proyect',
              extra: <String, dynamic>{
                kTransitionInfoKey: TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.bottomToTop,
                  duration: Duration(milliseconds: 220),
                ),
              },
            );
            // if (result == true) {
            //   // Vuelve a cargar la lista de motivos
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
          title: Text(FFLocalizations.of(context).getText(
            'wv1862li' /* Tipo de proyecto */,
          )), // Customize your app bar title here
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        ),
        drawer: const DrawerWidget(),
        body: FutureBuilder<List<ProyectoDto>>(
          future: listarProyecto(), // Llama al método que obtiene los datos
          builder: (BuildContext context,
              AsyncSnapshot<List<ProyectoDto>> snapshot) {
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
              List<ProyectoDto> proyecto = snapshot.data!;

              return GestureDetector(
                onTap: () => _model.unfocusNode.canRequestFocus
                    ? FocusScope.of(context).requestFocus(_model.unfocusNode)
                    : FocusScope.of(context).unfocus(),
                child: Scaffold(
                  key: scaffoldKey,
                  backgroundColor:
                      FlutterFlowTheme.of(context).primaryBackground,
                  body: Column(
                    children: [
                      _balanceDetails(proyecto),
                      _listItems(proyecto),
                    ],
                  ),
                ),
              );
            }

            return Center(
              child: Text('No data available'),
            );
          },
        ));
  }

  Widget _balanceDetails(List<ProyectoDto> lista) {
    return Column(children: [
      Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FFLocalizations.of(context).getText(
                'hhb6veym' /* Wallet Balance */,
              ),
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontFamily: 'Plus Jakarta Sans',
                    letterSpacing: 0,
                  ),
            ),
            Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              color: FlutterFlowTheme.of(context).primary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Container(
                  width: 40,
                  height: 40,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    'https://picsum.photos/seed/750/600',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              FFLocalizations.of(context).getText(
                'fgf8icmv' /* $23,000 */,
              ),
              style: FlutterFlowTheme.of(context).displaySmall.override(
                    fontFamily: 'Lexend',
                    fontSize: 36,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w300,
                  ),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lista.length.toString() +
                  ' ' +
                  FFLocalizations.of(context).getText(
                    '2rrr446m' /* 3 currencies */,
                  ),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Plus Jakarta Sans',
                    color: FlutterFlowTheme.of(context).tertiary,
                    letterSpacing: 0,
                  ),
            ),
          ],
        ),
      )
    ]);
  }

  Widget _listItems(List<ProyectoDto> lista) {
    double height = MediaQuery.of(context).size.height * (0.70);
    return Container(
        height: height,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Otros widgets
              SizedBox(
                height: MediaQuery.of(context)
                    .size
                    .height, // Ajusta la altura según tus necesidades
                child: ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final item = lista[index];

                    return GestureDetector(
                      onTap: () => {
                        context.goNamed(
                          'portafolio',
                          queryParameters: {
                            'idProyecto': serializeParam(item.idProyecto, ParamType.int,
                                isList: false),
                          }.withoutNulls,
                        )
                      },
                      child: itemsList(item),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget itemsList(ProyectoDto data) {
    Random random = Random();
    int red = random.nextInt(256);
    int green = random.nextInt(256);
    int blue = random.nextInt(256);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FlutterFlowTheme.of(context).secondary,
              Color.fromRGBO(red, green, blue, 1)
            ],
            stops: [0, 1],
            begin: AlignmentDirectional(1, -1),
            end: AlignmentDirectional(-1, 1),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.nombre,
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      fontFamily: 'Outfit',
                      letterSpacing: 0,
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                    child: Text(
                      data.descripcion,
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            fontFamily: 'Outfit',
                            letterSpacing: 0,
                          ),
                    ),
                  ),
                  Text(
                    FFLocalizations.of(context).getText(
                      '4mvfe3pe' /* 40% of portfolio */,
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0x7DEEEEEE),
                          letterSpacing: 0,
                        ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                    child: LinearPercentIndicator(
                      percent: 0.4,
                      width: MediaQuery.sizeOf(context).width * 0.87,
                      lineHeight: 15,
                      animation: true,
                      animateFromLastPercent: true,
                      progressColor: FlutterFlowTheme.of(context).primaryText,
                      backgroundColor: Color(0x33F1F4F8),
                      center: Text(
                        FFLocalizations.of(context).getText(
                          '6cm4jjje' /*   */,
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Plus Jakarta Sans',
                              color: FlutterFlowTheme.of(context).primary,
                              letterSpacing: 0,
                            ),
                      ),
                      barRadius: Radius.circular(40),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation3']!),
    );
  }
}
