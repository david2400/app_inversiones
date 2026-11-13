import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
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

  Future<void> _abrirNuevoTipoTransaccion() async {
    await context.pushNamed(
      _rutaNuevoTipoTransaccion,
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
      titulo: textos.getText('ttrx_titulo'),
      botonFlotante: FloatingActionButton.extended(
        onPressed: _abrirNuevoTipoTransaccion,
        tooltip: textos.getText('ttrx_agregar'),
        icon: const Icon(Icons.add_rounded),
        label: Text(textos.getText('ttrx_agregar')),
      ),
      cuerpo: GestureDetector(
        onTap: () => _model.unfocusNode.canRequestFocus
            ? FocusScope.of(context).requestFocus(_model.unfocusNode)
            : FocusScope.of(context).unfocus(),
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
          builder: (context, tipos) => _ListaTiposTransaccion(tipos: tipos),
        ),
      ),
    );
  }
}

/// Lista perezosa: encabezado con el total y una fila por tipo.
class _ListaTiposTransaccion extends StatelessWidget {
  final List<TipoTransaccionDto> tipos;

  const _ListaTiposTransaccion({required this.tipos});

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
            titulo: '${tipos.length} ${textos.getText('ttrx_total')}',
            subtitulo: textos.getText('ttrx_subtitulo'),
          );
        }
        return _FilaTipoTransaccion(tipo: tipos[indice - 1]);
      },
    );
  }
}

/// Presentación (ícono, color y etiqueta) de la naturaleza contable.
class _Naturaleza {
  final IconData icono;
  final Color color;
  final String claveEtiqueta;

  const _Naturaleza(this.icono, this.color, this.claveEtiqueta);

  static _Naturaleza de(String tipoFuente, FlutterFlowTheme tema) {
    switch (tipoFuente) {
      case TipoFuente.ingreso:
        return const _Naturaleza(Icons.south_west_rounded,
            ColoresFinanzas.ingresos, 'ttrx_ingreso');
      case TipoFuente.egreso:
        return const _Naturaleza(Icons.north_east_rounded,
            ColoresFinanzas.egresos, 'ttrx_egreso');
      case TipoFuente.transferencia:
        return _Naturaleza(
            Icons.swap_horiz_rounded, tema.primary, 'ttrx_movimiento');
      default:
        return _Naturaleza(
            Icons.help_outline_rounded, tema.secondaryText, 'ttrx_sin_tipo');
    }
  }
}

class _FilaTipoTransaccion extends StatelessWidget {
  final TipoTransaccionDto tipo;

  const _FilaTipoTransaccion({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final naturaleza = _Naturaleza.de(tipo.tipoFuente.trim(), tema);
    final descripcion = tipo.descripcion.trim();
    final tieneDescripcion = descripcion.isNotEmpty;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: Espacio.m,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tema.accent4,
          borderRadius: BorderRadius.circular(Radios.s),
        ),
        child: Icon(naturaleza.icono, size: 20, color: naturaleza.color),
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
            : textos.getText('ttrx_sin_descripcion'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: tema.bodySmall.copyWith(
          color: tema.secondaryText,
          fontStyle: tieneDescripcion ? FontStyle.normal : FontStyle.italic,
        ),
      ),
      trailing: _EtiquetaNaturaleza(
        color: naturaleza.color,
        texto: textos.getText(naturaleza.claveEtiqueta),
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
