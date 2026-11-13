import 'package:flutter/material.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
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
  late Future<List<ProyectoDto>> _proyectos;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProyectsPageModel());
    _proyectos = listarProyecto();
  }

  /// Delega en el State de la página. Los errores se propagan para que la
  /// pantalla muestre el estado de error con "Reintentar".
  Future<List<ProyectoDto>> listarProyecto() => _model.listarProyectos();

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
        child: ContenidoAsincrono<List<ProyectoDto>>(
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
          ),
        ),
      ),
    );
  }
}

/// Lista perezosa: encabezado con el total y una fila por proyecto.
class _ListaProyectos extends StatelessWidget {
  final List<ProyectoDto> proyectos;
  final ValueChanged<ProyectoDto> onSeleccionar;

  const _ListaProyectos({required this.proyectos, required this.onSeleccionar});

  /// Deja libre el final de la lista para que el botón flotante no tape la
  /// última fila.
  static const _espacioBotonFlotante = 88.0;

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    return ListView.separated(
      padding: Espacio.pantalla.copyWith(bottom: _espacioBotonFlotante),
      itemCount: proyectos.length + 1,
      separatorBuilder: (context, indice) => indice == 0
          ? const SizedBox(height: Espacio.s)
          : Divider(height: 1, color: tema.alternate),
      itemBuilder: (context, indice) {
        if (indice == 0) {
          return EncabezadoSeccion(
            titulo: '${proyectos.length} ${textos.getText('proy_total')}',
            subtitulo: textos.getText('proy_subtitulo'),
          );
        }
        final proyecto = proyectos[indice - 1];
        return _FilaProyecto(
          proyecto: proyecto,
          onTap: () => onSeleccionar(proyecto),
        );
      },
    );
  }
}

class _FilaProyecto extends StatelessWidget {
  final ProyectoDto proyecto;
  final VoidCallback onTap;

  const _FilaProyecto({required this.proyecto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final descripcion = proyecto.descripcion.trim();
    final tieneDescripcion = descripcion.isNotEmpty;
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
        tieneDescripcion
            ? descripcion
            : textos.getText('proy_sin_descripcion'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: tema.bodySmall.copyWith(
          color: tema.secondaryText,
          fontStyle: tieneDescripcion ? FontStyle.normal : FontStyle.italic,
        ),
      ),
      trailing: Tooltip(
        message: textos.getText('proy_ver_portafolios'),
        child: Icon(Icons.chevron_right_rounded, color: tema.secondaryText),
      ),
    );
  }
}
