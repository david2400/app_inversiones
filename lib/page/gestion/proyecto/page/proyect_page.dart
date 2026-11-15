import 'package:flutter/material.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_resumen_dto.dart';
import 'package:inversiones/page/gestion/tipoProyecto/page/perfil_inversion_ui.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

export 'package:inversiones/page/gestion/proyecto/states/proyect_page_state.dart';
import 'package:inversiones/page/gestion/proyecto/states/proyect_page_state.dart';

/// Listado de proyectos: agrupan portafolios y movimientos.
class ProyectPage extends StatefulWidget {
  const ProyectPage({super.key});

  @override
  State<ProyectPage> createState() => _ProyectsPageState();
}

class _ProyectsPageState extends State<ProyectPage> {
  static const _rutaNuevoProyecto = 'admin_proyect';
  static const _rutaPortafolio = 'portafolio';
  static const _parametroProyecto = 'idProyecto';

  late ProyectsPageModel _model;

  /// Consulta guardada en el State: nunca se dispara desde `build`.
  late Future<List<ProyectoResumenDto>> _proyectos;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProyectsPageModel());
    _proyectos = listarProyecto();
  }

  /// Delega en el State de la página. Los errores se propagan para que la
  /// pantalla muestre el estado de error con "Reintentar".
  Future<List<ProyectoResumenDto>> listarProyecto() => _model.listarResumen();

  /// Vuelve a consultar los datos (al volver de crear o editar).
  void _recargarDatos() {
    if (!mounted) return;
    setState(() {
      _proyectos = listarProyecto();
    });
  }

  Future<void> _abrirNuevoProyecto() async {
    await context.pushNamed(
      _rutaNuevoProyecto,
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: 220),
        ),
      },
    );
    _recargarDatos();
  }

  Future<void> _editarProyecto(ProyectoDto proyecto) async {
    final guardado = await context.pushNamed<bool>(
      _rutaNuevoProyecto,
      queryParameters: {
        _parametroProyecto: serializeParam(
          proyecto.idProyecto,
          ParamType.int,
          isList: false,
        ),
      }.withoutNulls,
    );
    if (guardado == true) _recargarDatos();
  }

  void _abrirPortafolios(ProyectoDto proyecto) {
    context.goNamed(
      _rutaPortafolio,
      queryParameters: {
        _parametroProyecto: serializeParam(
          proyecto.idProyecto,
          ParamType.int,
          isList: false,
        ),
      }.withoutNulls,
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    return PantallaBase(
      titulo: textos.getText('proy_titulo'),
      botonFlotante: FloatingActionButton.extended(
        onPressed: _abrirNuevoProyecto,
        tooltip: textos.getText('proy_agregar'),
        icon: const Icon(Icons.add_rounded),
        label: Text(textos.getText('proy_agregar')),
      ),
      cuerpo: GestureDetector(
        onTap: () => _model.unfocusNode.canRequestFocus
            ? FocusScope.of(context).requestFocus(_model.unfocusNode)
            : FocusScope.of(context).unfocus(),
        child: ContenidoAsincrono<List<ProyectoResumenDto>>(
          future: _proyectos,
          mensajeError: textos.getText('proy_error'),
          textoReintentar: textos.getText('proy_reintentar'),
          onReintentar: _recargarDatos,
          esVacio: (proyectos) => proyectos.isEmpty,
          vacio: EstadoVacio(
            icono: Icons.folder_open_rounded,
            mensaje: textos.getText('proy_vacio'),
            textoAccion: textos.getText('proy_agregar'),
            onAccion: _abrirNuevoProyecto,
          ),
          builder: (context, proyectos) => _ListaProyectos(
            proyectos: proyectos,
            onSeleccionar: _abrirPortafolios,
            onEditar: _editarProyecto,
          ),
        ),
      ),
    );
  }
}

/// Proyectos agrupados por tipo: cada grupo con su total y perfil
/// (riesgo y renta); los proyectos sin tipo van al final.
class _ListaProyectos extends StatelessWidget {
  final List<ProyectoResumenDto> proyectos;
  final ValueChanged<ProyectoDto> onSeleccionar;
  final ValueChanged<ProyectoDto> onEditar;

  const _ListaProyectos({
    required this.proyectos,
    required this.onSeleccionar,
    required this.onEditar,
  });

  /// Deja libre el final de la lista para que el botón flotante no tape la
  /// última fila.
  static const _espacioBotonFlotante = 88.0;

  /// Grupos en orden alfabético por tipo; "sin tipo" al final.
  List<List<ProyectoResumenDto>> _agrupar() {
    final grupos = <int?, List<ProyectoResumenDto>>{};
    for (final p in proyectos) {
      grupos.putIfAbsent(p.tipo?.idTipoProyecto, () => []).add(p);
    }
    final lista = grupos.values.toList()
      ..sort((a, b) {
        final ta = a.first.tipo, tb = b.first.tipo;
        if (ta == null) return 1;
        if (tb == null) return -1;
        return ta.nombre.toLowerCase().compareTo(tb.nombre.toLowerCase());
      });
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final total = proyectos.fold<int>(0, (suma, p) => suma + p.saldo);
    final filas = <Widget>[
      EncabezadoSeccion(
        titulo: '${proyectos.length} ${textos.getText('proy_total')}',
        subtitulo:
            '${textos.getText('proy_invertido')} ${FormatoMoneda.cop(total)}',
      ),
    ];
    for (final grupo in _agrupar()) {
      final tipo = grupo.first.tipo;
      final totalGrupo = grupo.fold<int>(0, (suma, p) => suma + p.saldo);
      filas.add(Padding(
        padding: const EdgeInsets.only(top: Espacio.l, bottom: Espacio.xs),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tipo?.nombre ?? textos.getText('proy_sin_tipo'),
                      style: tema.labelLarge),
                  if (tipo != null) ...[
                    const SizedBox(height: Espacio.xs),
                    EtiquetasPerfil(riesgo: tipo.riesgo),
                  ],
                ],
              ),
            ),
            Text(FormatoMoneda.cop(totalGrupo),
                style: tema.labelLarge.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()])),
          ],
        ),
      ));
      for (var i = 0; i < grupo.length; i++) {
        if (i > 0) filas.add(Divider(height: 1, color: tema.alternate));
        final resumen = grupo[i];
        filas.add(_FilaProyecto(
          key: ValueKey(resumen.proyecto.idProyecto),
          resumen: resumen,
          onTap: () => onSeleccionar(resumen.proyecto),
          onEditar: () => onEditar(resumen.proyecto),
        ));
      }
    }
    return ListView(
      padding: Espacio.pantalla.copyWith(bottom: _espacioBotonFlotante),
      children: filas,
    );
  }
}

class _FilaProyecto extends StatelessWidget {
  final ProyectoResumenDto resumen;
  final VoidCallback onTap;
  final VoidCallback onEditar;

  const _FilaProyecto({
    super.key,
    required this.resumen,
    required this.onTap,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final proyecto = resumen.proyecto;
    final descripcion = proyecto.descripcion.trim();
    final detalle = [
      '${resumen.cantidadPortafolios} ${textos.getText('proy_portafolios')}',
      if (descripcion.isNotEmpty) descripcion,
    ].join(' · ');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: Espacio.m,
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tema.accent1,
          borderRadius: BorderRadius.circular(Radios.s),
        ),
        child: Icon(Icons.folder_rounded, size: 20, color: tema.primary),
      ),
      title: Text(
        proyecto.nombre,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tema.titleSmall,
      ),
      subtitle: Text(
        detalle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: tema.bodySmall.copyWith(color: tema.secondaryText),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            FormatoMoneda.cop(resumen.saldo),
            style: tema.bodyMedium.copyWith(
              color: resumen.saldo < 0 ? tema.error : tema.primaryText,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          IconButton(
            tooltip: textos.getText('proy_editar'),
            icon: Icon(Icons.edit_outlined, color: tema.secondaryText),
            onPressed: onEditar,
          ),
        ],
      ),
    );
  }
}
