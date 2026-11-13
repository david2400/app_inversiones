import 'package:flutter/material.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

export 'package:inversiones/page/gestion/tipoProyecto/states/tipo_proyecto_page_state.dart';
import 'package:inversiones/page/gestion/tipoProyecto/states/tipo_proyecto_page_state.dart';

/// Listado de tipos de proyecto: clasifican los proyectos.
class TipoProyectoPage extends StatefulWidget {
  const TipoProyectoPage({super.key});

  @override
  State<TipoProyectoPage> createState() => _TipoProyectoPageState();
}

class _TipoProyectoPageState extends State<TipoProyectoPage> {
  static const _rutaNuevoTipoProyecto = 'admin_tipo_proyecto';

  late TipoProyectoPageState _model;

  /// Consulta guardada en el State: nunca se dispara desde `build`.
  late Future<List<TipoProyectoDto>> _tiposProyecto;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TipoProyectoPageState());
    _tiposProyecto = listarTipoProyecto();
  }

  /// Delega en el State de la página. Los errores se propagan para que la
  /// pantalla muestre el estado de error con "Reintentar".
  Future<List<TipoProyectoDto>> listarTipoProyecto() =>
      _model.listarTipoProyectos();

  /// Vuelve a consultar los datos (al volver de crear o editar).
  void _recargarDatos() {
    if (!mounted) return;
    setState(() {
      _tiposProyecto = listarTipoProyecto();
    });
  }

  Future<void> _abrirNuevoTipoProyecto() async {
    await context.pushNamed(
      _rutaNuevoTipoProyecto,
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

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    return PantallaBase(
      titulo: textos.getText('tproy_titulo'),
      botonFlotante: FloatingActionButton.extended(
        onPressed: _abrirNuevoTipoProyecto,
        tooltip: textos.getText('tproy_agregar'),
        icon: const Icon(Icons.add_rounded),
        label: Text(textos.getText('tproy_agregar')),
      ),
      cuerpo: ContenidoAsincrono<List<TipoProyectoDto>>(
        future: _tiposProyecto,
        mensajeError: textos.getText('tproy_error'),
        textoReintentar: textos.getText('tproy_reintentar'),
        onReintentar: _recargarDatos,
        esVacio: (tipos) => tipos.isEmpty,
        vacio: EstadoVacio(
          icono: Icons.category_outlined,
          mensaje: textos.getText('tproy_vacio'),
          textoAccion: textos.getText('tproy_agregar'),
          onAccion: _abrirNuevoTipoProyecto,
        ),
        builder: (context, tipos) => _ListaTiposProyecto(tipos: tipos),
      ),
    );
  }
}

/// Lista perezosa: encabezado con el total y una fila por tipo de proyecto.
class _ListaTiposProyecto extends StatelessWidget {
  final List<TipoProyectoDto> tipos;

  const _ListaTiposProyecto({required this.tipos});

  /// Deja libre el final de la lista para que el botón flotante no tape la
  /// última fila.
  static const _espacioBotonFlotante = 88.0;

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    return ListView.separated(
      padding: Espacio.pantalla.copyWith(bottom: _espacioBotonFlotante),
      itemCount: tipos.length + 1,
      separatorBuilder: (context, indice) => indice == 0
          ? const SizedBox(height: Espacio.s)
          : Divider(height: 1, color: tema.alternate),
      itemBuilder: (context, indice) {
        if (indice == 0) {
          return EncabezadoSeccion(
            titulo: '${tipos.length} ${textos.getText('tproy_total')}',
            subtitulo: textos.getText('tproy_subtitulo'),
          );
        }
        return _FilaTipoProyecto(tipo: tipos[indice - 1]);
      },
    );
  }
}

class _FilaTipoProyecto extends StatelessWidget {
  final TipoProyectoDto tipo;

  const _FilaTipoProyecto({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final descripcion = tipo.descripcion.trim();
    final tieneDescripcion = descripcion.isNotEmpty;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: Espacio.m,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tema.accent1,
          borderRadius: BorderRadius.circular(Radios.s),
        ),
        child: Icon(Icons.category_rounded, size: 20, color: tema.primary),
      ),
      title: Text(
        tipo.nombre,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tema.titleSmall,
      ),
      subtitle: Text(
        tieneDescripcion
            ? descripcion
            : textos.getText('tproy_sin_descripcion'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: tema.bodySmall.copyWith(
          color: tema.secondaryText,
          fontStyle: tieneDescripcion ? FontStyle.normal : FontStyle.italic,
        ),
      ),
    );
  }
}
