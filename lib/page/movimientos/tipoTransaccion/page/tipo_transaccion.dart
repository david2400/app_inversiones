import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

export 'package:inversiones/page/movimientos/tipoTransaccion/states/tipo_transaccion_page_state.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/states/tipo_transaccion_page_state.dart';

/// Listado de tipos de transacción (ingreso, egreso o movimiento).
class TipoTransaccionPage extends StatefulWidget {
  const TipoTransaccionPage({super.key});

  @override
  State<TipoTransaccionPage> createState() => _TipoTransaccionPageState();
}

class _TipoTransaccionPageState extends State<TipoTransaccionPage> {
  static const _rutaNuevoTipoTransaccion = 'admin_tipo_Transaccion';

  late TipoTransaccionPageState _model;

  /// Consulta guardada en el State: nunca se dispara desde `build`.
  late Future<List<TipoTransaccionDto>> _tiposTransaccion;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TipoTransaccionPageState());
    _tiposTransaccion = listarTipoTransacciones();
  }

  /// Delega en el State de la página. Los errores se propagan para que la
  /// pantalla muestre el estado de error con "Reintentar".
  Future<List<TipoTransaccionDto>> listarTipoTransacciones() =>
      _model.listarTipoTransaccion();

  /// Vuelve a consultar los datos (al volver de crear o editar).
  void _recargarDatos() {
    if (!mounted) return;
    setState(() {
      _tiposTransaccion = listarTipoTransacciones();
    });
  }

  /// Abre el formulario para crear ([tipo] nulo) o editar.
  Future<void> _abrirFormulario([TipoTransaccionDto? tipo]) async {
    final guardado = await context.pushNamed<bool>(
      _rutaNuevoTipoTransaccion,
      queryParameters: {
        'idTipoTransaccion': serializeParam(
            tipo?.idTipoTransaccion, ParamType.int,
            isList: false),
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

  Future<void> _abrirNuevoTipoTransaccion() => _abrirFormulario();

  Future<void> _ejecutar(Future<void> Function() accion, String exito) async {
    final textos = FFLocalizations.of(context);
    try {
      await accion();
      if (mounted) mostrarMensaje(context, textos.getText(exito));
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
    _recargarDatos();
  }

  Future<void> _eliminar(TipoTransaccionDto tipo) async {
    final textos = FFLocalizations.of(context);
    final confirmado = await confirmarAccion(
      context,
      titulo: textos.getText('ttrx_eliminar_titulo'),
      mensaje: tipo.nombre,
      textoConfirmar: textos.getText('ter_eliminar'),
      textoCancelar: textos.getText('mov_cancelar'),
      destructiva: true,
    );
    if (!confirmado) return;
    await _ejecutar(
        () => _model.eliminar(tipo.idTipoTransaccion!), 'ttrx_eliminado');
  }

  Future<void> _cambiarActivo(TipoTransaccionDto tipo) => _ejecutar(
      () => _model.cambiarActivo(tipo.idTipoTransaccion!, !tipo.activo),
      tipo.activo ? 'ttrx_desactivado' : 'ttrx_activado');

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    return PantallaBase(
      titulo: textos.getText('ttrx_titulo'),
      botonFlotante: FloatingActionButton.extended(
        onPressed: _abrirNuevoTipoTransaccion,
        tooltip: textos.getText('ttrx_agregar'),
        icon: const Icon(Icons.add_rounded),
        label: Text(textos.getText('ttrx_agregar')),
      ),
      cuerpo: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ContenidoAsincrono<List<TipoTransaccionDto>>(
          future: _tiposTransaccion,
          mensajeError: textos.getText('ttrx_error'),
          textoReintentar: textos.getText('ttrx_reintentar'),
          onReintentar: _recargarDatos,
          esVacio: (tipos) => tipos.isEmpty,
          vacio: EstadoVacio(
            icono: Icons.swap_vert_rounded,
            mensaje: textos.getText('ttrx_vacio'),
            textoAccion: textos.getText('ttrx_agregar'),
            onAccion: _abrirNuevoTipoTransaccion,
          ),
          builder: (context, tipos) => RefreshIndicator(
            onRefresh: () async => _recargarDatos(),
            child: _ListaTiposTransaccion(
              tipos: tipos,
              onEditar: _abrirFormulario,
              onCambiarActivo: _cambiarActivo,
              onEliminar: _eliminar,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tipos agrupados por naturaleza (ingresos, egresos, transferencias).
class _ListaTiposTransaccion extends StatelessWidget {
  final List<TipoTransaccionDto> tipos;
  final ValueChanged<TipoTransaccionDto> onEditar;
  final ValueChanged<TipoTransaccionDto> onCambiarActivo;
  final ValueChanged<TipoTransaccionDto> onEliminar;

  const _ListaTiposTransaccion({
    required this.tipos,
    required this.onEditar,
    required this.onCambiarActivo,
    required this.onEliminar,
  });

  /// Deja libre el final de la lista para que el botón flotante no tape la
  /// última fila.
  static const _espacioBotonFlotante = 88.0;

  static const _orden = [
    TipoFuente.ingreso,
    TipoFuente.egreso,
    TipoFuente.transferencia,
  ];

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final filas = <Widget>[
      EncabezadoSeccion(
        titulo: '${tipos.length} ${textos.getText('ttrx_total')}',
        subtitulo: textos.getText('ttrx_subtitulo'),
      ),
    ];
    for (final fuente in _orden) {
      final grupo = tipos.where((t) => t.tipoFuente.trim() == fuente).toList();
      if (grupo.isEmpty) continue;
      final naturaleza = _Naturaleza.de(fuente, tema);
      filas.add(Padding(
        padding: const EdgeInsets.only(top: Espacio.l, bottom: Espacio.xs),
        child: Row(
          children: [
            Icon(naturaleza.icono, size: 18, color: naturaleza.color),
            const SizedBox(width: Espacio.s),
            Text(textos.getText(naturaleza.claveGrupo),
                style: tema.labelLarge.copyWith(color: naturaleza.color)),
            const Spacer(),
            Text('${grupo.length}',
                style: tema.labelMedium.copyWith(color: tema.secondaryText)),
          ],
        ),
      ));
      for (var i = 0; i < grupo.length; i++) {
        if (i > 0) filas.add(Divider(height: 1, color: tema.alternate));
        final tipo = grupo[i];
        filas.add(_FilaTipoTransaccion(
          key: ValueKey(tipo.idTipoTransaccion),
          tipo: tipo,
          onTap: () => onEditar(tipo),
          onCambiarActivo: () => onCambiarActivo(tipo),
          onEliminar: () => onEliminar(tipo),
        ));
      }
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: Espacio.pantalla.copyWith(bottom: _espacioBotonFlotante),
      children: filas,
    );
  }
}

/// Presentación (ícono, color y etiqueta) de la naturaleza contable.
class _Naturaleza {
  final IconData icono;
  final Color color;
  final String claveEtiqueta;
  final String claveGrupo;

  const _Naturaleza(
      this.icono, this.color, this.claveEtiqueta, this.claveGrupo);

  static _Naturaleza de(String tipoFuente, FlutterFlowTheme tema) {
    switch (tipoFuente) {
      case TipoFuente.ingreso:
        return const _Naturaleza(Icons.south_west_rounded,
            ColoresFinanzas.ingresos, 'ttrx_ingreso', 'ttrx_grupo_ingresos');
      case TipoFuente.egreso:
        return const _Naturaleza(Icons.north_east_rounded,
            ColoresFinanzas.egresos, 'ttrx_egreso', 'ttrx_grupo_egresos');
      case TipoFuente.transferencia:
        return _Naturaleza(
            Icons.swap_horiz_rounded, tema.primary, 'ttrx_movimiento',
            'ttrx_grupo_transferencias');
      default:
        return _Naturaleza(
            Icons.help_outline_rounded, tema.secondaryText, 'ttrx_sin_tipo',
            'ttrx_sin_tipo');
    }
  }
}

class _FilaTipoTransaccion extends StatelessWidget {
  final TipoTransaccionDto tipo;
  final VoidCallback onTap;
  final VoidCallback onCambiarActivo;
  final VoidCallback onEliminar;

  const _FilaTipoTransaccion({
    super.key,
    required this.tipo,
    required this.onTap,
    required this.onCambiarActivo,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final naturaleza = _Naturaleza.de(tipo.tipoFuente.trim(), tema);
    final descripcion = tipo.descripcion.trim();
    final uso = tipo.cantidadMovimientos == 0
        ? textos.getText('ttrx_sin_movimientos')
        : '${tipo.cantidadMovimientos} ${textos.getText('ttrx_movimientos')}'
            ' · ${FormatoMoneda.cop(tipo.totalMovido)}';
    return Opacity(
      opacity: tipo.activo ? 1 : 0.55,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: Espacio.m,
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: naturaleza.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(Radios.s),
          ),
          child: Icon(naturaleza.icono, size: 20, color: naturaleza.color),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                tipo.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.titleSmall,
              ),
            ),
            if (tipo.esSistema) ...[
              const SizedBox(width: Espacio.s),
              _EtiquetaNaturaleza(
                  color: tema.primary, texto: textos.getText('ttrx_sistema')),
            ],
            if (!tipo.activo) ...[
              const SizedBox(width: Espacio.s),
              _EtiquetaNaturaleza(
                  color: tema.secondaryText,
                  texto: textos.getText('ttrx_inactivo')),
            ],
          ],
        ),
        subtitle: Text(
          descripcion.isEmpty ? uso : '$descripcion\n$uso',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: tema.bodySmall.copyWith(color: tema.secondaryText),
        ),
        trailing: tipo.esSistema
            ? null
            : PopupMenuButton<VoidCallback>(
                tooltip: textos.getText('trx_mas'),
                icon: Icon(Icons.more_vert_rounded, color: tema.secondaryText),
                onSelected: (accion) => accion(),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: onCambiarActivo,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(tipo.activo
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      title: Text(textos.getText(
                          tipo.activo ? 'ttrx_desactivar' : 'ttrx_activar')),
                    ),
                  ),
                  PopupMenuItem(
                    value: onEliminar,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.delete_outline_rounded),
                      title: Text(textos.getText('ter_eliminar')),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Etiqueta con borde del color de identidad: el texto siempre acompaña al
/// color, nunca se comunica solo con color.
class _EtiquetaNaturaleza extends StatelessWidget {
  final Color color;
  final String texto;

  const _EtiquetaNaturaleza({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Espacio.s, vertical: Espacio.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radios.s),
        border: Border.all(color: color),
      ),
      child: Text(texto, style: tema.labelSmall.copyWith(color: color)),
    );
  }
}
