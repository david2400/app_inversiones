import 'package:flutter/material.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:inversiones/ui/utils/flutter_fluw_datatable.dart';

import 'package:inversiones/ui/widgets/drawer_widget.dart';

import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:google_fonts/google_fonts.dart';

export 'package:inversiones/page/gestion/tipoProyecto/states/tipo_proyecto_page_state.dart';
import 'package:inversiones/page/gestion/tipoProyecto/states/tipo_proyecto_page_state.dart';

class TipoProyectoPage extends StatefulWidget {
  const TipoProyectoPage({super.key});

  @override
  State<TipoProyectoPage> createState() => _TipoProyectoPageState();
}

class _TipoProyectoPageState extends State<TipoProyectoPage>
    with TickerProviderStateMixin {
  late TipoProyectoPageState _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // late List<TipoProyectoDto> _listaTipoProyecto;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TipoProyectoPageState());

    // _listaTipoProyecto = [];
    // _initParams();
  }

  Future<List<TipoProyectoDto>> listarTipoProyecto() async {
    try {
      List<TipoProyectoDto> result = await _model.listarTipoProyectos();

      return result.isEmpty ? [] : result;
    } catch (e) {
      return [];
    }
  }

  // void _initParams() async {
  //   List<TipoProyectoDto> lista = await listarTipoProyecto();
  //   setState(() {
  //     _listaTipoProyecto = lista;
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
    _model.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FFLocalizations.of(context).getText(
            'ig2y6wx6' /* Tipo de proyecto */,
          ),
          style: FlutterFlowTheme.of(context).titleLarge.override(
                fontFamily: 'Outfit',
                letterSpacing: 0.0,
              ),
        ), // Customize your app bar title here
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      ),
      drawer: const DrawerWidget(),
      body: GestureDetector(
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryText,
          body: Column(
            children: [_menu(), _datatable()],
          ),
        ),
      ),
    );
  }

  Widget _menu() {
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
                  final result = await context.pushNamed(
                    'admin_tipo_proyecto',
                    extra: <String, dynamic>{
                      kTransitionInfoKey: const TransitionInfo(
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
                            Icons.add_circle_outline_rounded,
                            color: FlutterFlowTheme.of(context).tertiary,
                            size: 36,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'r04m9nxs' /* Transfer */,
                            ),
                            style: GoogleFonts.getFont(
                              'Lexend Deca',
                              color: FlutterFlowTheme.of(context).tertiary,
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

  Widget _datatable() {
    return FutureBuilder<List<TipoProyectoDto>>(
      future: listarTipoProyecto(), // Llama al método que obtiene los datos
      builder: (BuildContext context,
          AsyncSnapshot<List<TipoProyectoDto>> snapshot) {
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
          List<TipoProyectoDto> tipoProyecto = snapshot.data!;

          return Expanded(
            child: FlutterFlowDataTable<dynamic>(
              controller: _model.paginatedDataTableController,
              data: tipoProyecto,
              columnsBuilder: (onSortChanged) => [
                DataColumn2(
                  label: DefaultTextStyle.merge(
                    softWrap: true,
                    child: Text(
                      FFLocalizations.of(context).getText(
                        'o07j3ttv' /* Edit Header 1 */,
                      ),
                      style: FlutterFlowTheme.of(context).labelLarge.override(
                          fontFamily: 'Outfit',
                          letterSpacing: 0.0,
                          color: FlutterFlowTheme.of(context).primaryText),
                    ),
                  ),
                ),
                DataColumn2(
                  label: DefaultTextStyle.merge(
                    softWrap: true,
                    child: Text(
                      FFLocalizations.of(context).getText(
                        'o08j3ttv' /* Edit Header 2 */,
                      ),
                      style: FlutterFlowTheme.of(context).labelLarge.override(
                          fontFamily: 'Outfit',
                          letterSpacing: 0.0,
                          color: FlutterFlowTheme.of(context).primaryText),
                    ),
                  ),
                ),
                // DataColumn2(
                //   label: DefaultTextStyle.merge(
                //     softWrap: true,
                //     child: Text(
                //       'Acciones',
                //       style: FlutterFlowTheme.of(context).labelLarge.override(
                //             fontFamily: 'Outfit',
                //             letterSpacing: 0.0,
                //           ),
                //     ),
                //   ),
                // ),
              ],
              dataRowBuilder:
                  (Item, paginatedDataTableIndex, selected, onSelectChanged) =>
                      DataRow(
                color: WidgetStateProperty.all(
                  paginatedDataTableIndex % 2 == 0
                      ? FlutterFlowTheme.of(context).secondary
                      : FlutterFlowTheme.of(context).primaryBackground,
                ),
                cells: [
                  Text(
                    Item.nombre,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Plus Jakarta Sans',
                          letterSpacing: 0.0,
                        ),
                  ),
                  Text(
                    Item.descripcion,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Plus Jakarta Sans',
                          letterSpacing: 0.0,
                        ),
                  ),
                  // Text(
                  //   'acciones',
                  //   style: FlutterFlowTheme.of(context).bodyMedium.override(
                  //         fontFamily: 'Plus Jakarta Sans',
                  //         letterSpacing: 0.0,
                  //       ),
                  // ),
                ].map((c) => DataCell(c)).toList(),
              ),
              paginated: true,
              selectable: false,
              hidePaginator: false,
              showFirstLastButtons: false,
              headingRowHeight: 40.0,
              dataRowHeight: 48.0,
              columnSpacing: 20.0,
              headingRowColor: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.circular(8.0),
              addHorizontalDivider: true,
              addTopAndBottomDivider: false,
              hideDefaultHorizontalDivider: true,
              horizontalDividerColor: FlutterFlowTheme.of(context).primaryText,
              horizontalDividerThickness: 1.0,
              addVerticalDivider: false,
            ),
          );
        }

        return Center(
          child: Text('No data available'),
        );
      },
    );
  }
}
