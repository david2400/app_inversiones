import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

export 'package:inversiones/page/motivos/states/motivos_page_state.dart';
import 'package:inversiones/page/motivos/states/motivos_page_state.dart';

/// Listado de motivos: por qué entra o sale el dinero.
class MotivosPage extends StatefulWidget {
  const MotivosPage({super.key});

  @override
  State<MotivosPage> createState() => _MotivosPageState();
}

class _MotivosPageState extends State<MotivosPage> {
  static const _rutaNuevoMotivo = 'admin_motivos';

  late MotivosPageState _model;

  /// Consulta guardada en el State: nunca se dispara desde `build`.
  late Future<List<MotivosDto>> _motivos;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MotivosPageState());
    _motivos = listarMotivos();
  }

  /// Delega en el State de la página. Los errores se propagan para que la
  /// pantalla muestre el estado de error con "Reintentar" en lugar de una
  /// lista vacía engañosa.
  Future<List<MotivosDto>> listarMotivos() => _model.listarMotivos();

  /// Vuelve a consultar los datos (al volver de crear o editar).
  void _recargarDatos() {
    if (!mounted) return;
    setState(() {
      _motivos = listarMotivos();
    });
  }

  /// Abre el formulario para crear ([motivo] nulo) o editar.
  Future<void> _abrirFormulario([MotivosDto? motivo]) async {
    final guardado = await context.pushNamed<bool>(
      _rutaNuevoMotivo,
      queryParameters: {
        'idMotivo':
            serializeParam(motivo?.idMotivo, ParamType.int, isList: false),
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

  Future<void> _abrirNuevoMotivo() => _abrirFormulario();

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

  Future<void> _eliminar(MotivosDto motivo) async {
    final textos = FFLocalizations.of(context);
    final confirmado = await confirmarAccion(
      context,
      titulo: textos.getText('mot_eliminar_titulo'),
      mensaje: motivo.nombre,
      textoConfirmar: textos.getText('ter_eliminar'),
      textoCancelar: textos.getText('mov_cancelar'),
      destructiva: true,
    );
    if (!confirmado) return;
    await _ejecutar(() => _model.eliminar(motivo.idMotivo!), 'mot_eliminado');
  }

  Future<void> _cambiarActivo(MotivosDto motivo) => _ejecutar(
      () => _model.cambiarActivo(motivo.idMotivo!, !motivo.activo),
      motivo.activo ? 'mot_desactivado' : 'mot_activado');

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    return PantallaBase(
      titulo: textos.getText('mot_titulo'),
      botonFlotante: FloatingActionButton.extended(
        onPressed: _abrirNuevoMotivo,
        tooltip: textos.getText('mot_agregar'),
        icon: const Icon(Icons.add_rounded),
        label: Text(textos.getText('mot_agregar')),
      ),
      cuerpo: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ContenidoAsincrono<List<MotivosDto>>(
          future: _motivos,
          mensajeError: textos.getText('mot_error'),
          textoReintentar: textos.getText('mot_reintentar'),
          onReintentar: _recargarDatos,
          esVacio: (motivos) => motivos.isEmpty,
          vacio: EstadoVacio(
            icono: Icons.label_outline_rounded,
            mensaje: textos.getText('mot_vacio'),
            textoAccion: textos.getText('mot_agregar'),
            onAccion: _abrirNuevoMotivo,
          ),
          builder: (context, motivos) => RefreshIndicator(
            onRefresh: () async => _recargarDatos(),
            child: _ListaMotivos(
              motivos: motivos,
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

/// Motivos agrupados por naturaleza: ingresos, gastos y ambos.
class _ListaMotivos extends StatelessWidget {
  final List<MotivosDto> motivos;
  final ValueChanged<MotivosDto> onEditar;
  final ValueChanged<MotivosDto> onCambiarActivo;
  final ValueChanged<MotivosDto> onEliminar;

  const _ListaMotivos({
    required this.motivos,
    required this.onEditar,
    required this.onCambiarActivo,
    required this.onEliminar,
  });

  /// Deja libre el final de la lista para que el botón flotante no tape la
  /// última fila.
  static const _espacioBotonFlotante = 88.0;

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final grupos = <(String?, String, IconData, Color)>[
      (TipoFuente.ingreso, 'mot_grupo_ingresos', Icons.south_west_rounded,
          ColoresFinanzas.ingresos),
      (TipoFuente.egreso, 'mot_grupo_gastos', Icons.north_east_rounded,
          ColoresFinanzas.egresos),
      (null, 'mot_grupo_ambos', Icons.swap_vert_rounded, tema.primary),
    ];
    final filas = <Widget>[
      EncabezadoSeccion(
        titulo: '${motivos.length} ${textos.getText('mot_total')}',
        subtitulo: textos.getText('mot_subtitulo'),
      ),
    ];
    for (final (naturaleza, clave, icono, color) in grupos) {
      final grupo = motivos.where((m) => m.naturaleza == naturaleza).toList();
      if (grupo.isEmpty) continue;
      filas.add(Padding(
        padding: const EdgeInsets.only(top: Espacio.l, bottom: Espacio.xs),
        child: Row(
          children: [
            Icon(icono, size: 18, color: color),
            const SizedBox(width: Espacio.s),
            Text(textos.getText(clave),
                style: tema.labelLarge.copyWith(color: color)),
            const Spacer(),
            Text('${grupo.length}',
                style: tema.labelMedium.copyWith(color: tema.secondaryText)),
          ],
        ),
      ));
      for (var i = 0; i < grupo.length; i++) {
        if (i > 0) filas.add(Divider(height: 1, color: tema.alternate));
        final motivo = grupo[i];
        filas.add(_FilaMotivo(
          key: ValueKey(motivo.idMotivo),
          motivo: motivo,
          icono: icono,
          color: color,
          onTap: () => onEditar(motivo),
          onCambiarActivo: () => onCambiarActivo(motivo),
          onEliminar: () => onEliminar(motivo),
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

class _FilaMotivo extends StatelessWidget {
  final MotivosDto motivo;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onCambiarActivo;
  final VoidCallback onEliminar;

  const _FilaMotivo({
    super.key,
    required this.motivo,
    required this.icono,
    required this.color,
    required this.onTap,
    required this.onCambiarActivo,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final descripcion = motivo.descripcion.trim();
    final uso = motivo.cantidadMovimientos == 0
        ? textos.getText('ttrx_sin_movimientos')
        : '${motivo.cantidadMovimientos} ${textos.getText('ttrx_movimientos')}'
            ' · ${FormatoMoneda.cop(motivo.totalMovido)}';
    return Opacity(
      opacity: motivo.activo ? 1 : 0.55,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: Espacio.m,
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(Radios.s),
          ),
          child: Icon(Icons.label_rounded, size: 20, color: color),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(motivo.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.titleSmall),
            ),
            if (!motivo.activo) ...[
              const SizedBox(width: Espacio.s),
              Text(textos.getText('ttrx_inactivo'),
                  style:
                      tema.labelSmall.copyWith(color: tema.secondaryText)),
            ],
          ],
        ),
        subtitle: Text(
          descripcion.isEmpty ? uso : '$descripcion\n$uso',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: tema.bodySmall.copyWith(color: tema.secondaryText),
        ),
        trailing: PopupMenuButton<VoidCallback>(
          tooltip: textos.getText('trx_mas'),
          icon: Icon(Icons.more_vert_rounded, color: tema.secondaryText),
          onSelected: (accion) => accion(),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: onCambiarActivo,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(motivo.activo
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                title: Text(textos.getText(
                    motivo.activo ? 'ttrx_desactivar' : 'ttrx_activar')),
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
