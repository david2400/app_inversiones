import 'package:flutter/material.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:inversiones/page/gestion/tipoProyecto/page/perfil_inversion_ui.dart';
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

  /// Abre el formulario para crear ([tipo] nulo) o editar un tipo.
  Future<void> _abrirFormulario([TipoProyectoDto? tipo]) async {
    final guardado = await context.pushNamed<bool>(
      _rutaNuevoTipoProyecto,
      queryParameters: {
        'idTipoProyecto':
            serializeParam(tipo?.idTipoProyecto, ParamType.int, isList: false),
      }.withoutNulls,
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: 220),
        ),
      },
    );
    if (guardado == true) _recargarDatos();
  }

  Future<void> _abrirNuevoTipoProyecto() => _abrirFormulario();

  Future<void> _eliminar(TipoProyectoDto tipo) async {
    final textos = FFLocalizations.of(context);
    final confirmado = await confirmarAccion(
      context,
      titulo: textos.getText('tproy_eliminar_titulo'),
      mensaje: tipo.nombre,
      textoConfirmar: textos.getText('ter_eliminar'),
      textoCancelar: textos.getText('mov_cancelar'),
      destructiva: true,
    );
    if (!confirmado) return;
    try {
      await _model.eliminar(tipo.idTipoProyecto!);
      if (mounted) mostrarMensaje(context, textos.getText('tproy_eliminado'));
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
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
        builder: (context, tipos) => RefreshIndicator(
          onRefresh: () async => _recargarDatos(),
          child: _ListaTiposProyecto(
            tipos: tipos,
            onEditar: _abrirFormulario,
            onEliminar: _eliminar,
          ),
        ),
      ),
    );
  }
}

/// Lista perezosa: encabezado con el total y una fila por tipo de proyecto.
class _ListaTiposProyecto extends StatelessWidget {
  final List<TipoProyectoDto> tipos;
  final ValueChanged<TipoProyectoDto> onEditar;
  final ValueChanged<TipoProyectoDto> onEliminar;

  const _ListaTiposProyecto({
    required this.tipos,
    required this.onEditar,
    required this.onEliminar,
  });

  /// Deja libre el final de la lista para que el botón flotante no tape la
  /// última fila.
  static const _espacioBotonFlotante = 88.0;

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
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
        final tipo = tipos[indice - 1];
        return _FilaTipoProyecto(
          key: ValueKey(tipo.idTipoProyecto),
          tipo: tipo,
          onTap: () => onEditar(tipo),
          onEliminar: () => onEliminar(tipo),
        );
      },
    );
  }
}

class _FilaTipoProyecto extends StatelessWidget {
  final TipoProyectoDto tipo;
  final VoidCallback onTap;
  final VoidCallback onEliminar;

  const _FilaTipoProyecto({
    super.key,
    required this.tipo,
    required this.onTap,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final descripcion = tipo.descripcion.trim();
    final tieneDescripcion = descripcion.isNotEmpty;
    final enUso = tipo.cantidadProyectos > 0;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: Espacio.m,
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorRiesgo(tema, tipo.riesgo).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Radios.s),
        ),
        child: Icon(Icons.category_rounded,
            size: 20, color: colorRiesgo(tema, tipo.riesgo)),
      ),
      title: Text(
        tipo.nombre,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tema.titleSmall,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tieneDescripcion
                ? descripcion
                : textos.getText('tproy_sin_descripcion'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: tema.bodySmall.copyWith(
              color: tema.secondaryText,
              fontStyle:
                  tieneDescripcion ? FontStyle.normal : FontStyle.italic,
            ),
          ),
          const SizedBox(height: Espacio.xs),
          EtiquetasPerfil(riesgo: tipo.riesgo),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${tipo.cantidadProyectos} ${textos.getText('tproy_proyectos')}',
            style: tema.labelSmall.copyWith(color: tema.secondaryText),
          ),
          IconButton(
            tooltip: textos.getText(
                enUso ? 'tproy_en_uso_no_eliminar' : 'ter_eliminar'),
            icon: Icon(Icons.delete_outline_rounded,
                color: enUso ? tema.alternate : tema.secondaryText),
            onPressed: onEliminar,
          ),
        ],
      ),
    );
  }
}
