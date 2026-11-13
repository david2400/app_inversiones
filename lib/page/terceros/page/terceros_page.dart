import 'package:flutter/material.dart';
import 'package:inversiones/page/terceros/dto/tercero_dto.dart';
import 'package:inversiones/page/terceros/states/terceros_page_state.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

/// Catálogo de terceros: de quién recibes dinero y a quién le pagas.
class TercerosPage extends StatefulWidget {
  const TercerosPage({super.key});

  @override
  State<TercerosPage> createState() => _TercerosPageState();
}

class _TercerosPageState extends State<TercerosPage> {
  late TercerosPageState _model;
  late Future<List<TerceroDto>> _terceros;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TercerosPageState());
    _terceros = _model.listar();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  /// Vuelve a consultar la lista. Se llama después de crear, editar o
  /// eliminar, y también al deslizar hacia abajo.
  Future<void> _recargar() async {
    final consulta = _model.listar();
    if (!mounted) return;
    setState(() {
      _terceros = consulta;
    });
    try {
      await consulta;
    } catch (_) {
      // El error lo muestra ContenidoAsincrono con "Reintentar".
    }
  }

  Future<void> _editar([TerceroDto? tercero]) async {
    // El diálogo es dueño de sus controladores y los libera cuando termina
    // su animación de cierre (liberarlos aquí rompía la pantalla).
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoTercero(model: _model, tercero: tercero),
    );
    if (guardado == true) await _recargar();
  }

  Future<void> _eliminar(TerceroDto tercero) async {
    final confirmado = await confirmarAccion(
      context,
      titulo: _t('ter_eliminar_titulo'),
      mensaje: tercero.nombre,
      textoConfirmar: _t('ter_eliminar'),
      textoCancelar: _t('mov_cancelar'),
      destructiva: true,
    );
    if (!confirmado) return;
    try {
      await _model.eliminar(tercero.idTercero!);
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
    await _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: _t('ter_titulo'),
      botonFlotante: FloatingActionButton(
        tooltip: _t('ter_nuevo'),
        onPressed: () => _editar(),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      cuerpo: ContenidoAsincrono<List<TerceroDto>>(
        future: _terceros,
        mensajeError: _t('dash_error'),
        textoReintentar: _t('mot_reintentar'),
        onReintentar: _recargar,
        esVacio: (terceros) => terceros.isEmpty,
        vacio: EstadoVacio(
          icono: Icons.people_outline_rounded,
          mensaje: _t('ter_vacio'),
          textoAccion: _t('ter_nuevo'),
          onAccion: () => _editar(),
        ),
        builder: (context, terceros) => RefreshIndicator(
          onRefresh: _recargar,
          child: _ListaTerceros(
            terceros: terceros,
            textoEliminar: _t('ter_eliminar'),
            onEditar: _editar,
            onEliminar: _eliminar,
          ),
        ),
      ),
    );
  }
}

class _ListaTerceros extends StatelessWidget {
  final List<TerceroDto> terceros;
  final String textoEliminar;
  final ValueChanged<TerceroDto> onEditar;
  final ValueChanged<TerceroDto> onEliminar;

  const _ListaTerceros({
    required this.terceros,
    required this.textoEliminar,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          Espacio.l, Espacio.s, Espacio.l, Espacio.xxl * 3),
      itemCount: terceros.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: tema.alternate),
      itemBuilder: (context, i) {
        final tercero = terceros[i];
        final descripcion = tercero.descripcion;
        return ListTile(
          key: ValueKey(tercero.idTercero),
          contentPadding: EdgeInsets.zero,
          minVerticalPadding: Espacio.s,
          leading: CircleAvatar(
            backgroundColor: tema.secondaryBackground,
            child: Text(
              tercero.nombre.isEmpty
                  ? '?'
                  : tercero.nombre.characters.first.toUpperCase(),
              style: tema.titleSmall,
            ),
          ),
          title: Text(tercero.nombre, style: tema.bodyLarge),
          subtitle: descripcion == null || descripcion.isEmpty
              ? null
              : Text(descripcion,
                  style: tema.bodySmall.copyWith(color: tema.secondaryText)),
          onTap: () => onEditar(tercero),
          trailing: IconButton(
            tooltip: textoEliminar,
            icon: Icon(Icons.delete_outline_rounded, color: tema.secondaryText),
            onPressed: () => onEliminar(tercero),
          ),
        );
      },
    );
  }
}

/// Diálogo para crear o editar un tercero. Guarda con el state de la
/// pantalla y se cierra con `true` solo si se guardó.
class _DialogoTercero extends StatefulWidget {
  final TercerosPageState model;
  final TerceroDto? tercero;

  const _DialogoTercero({required this.model, this.tercero});

  @override
  State<_DialogoTercero> createState() => _DialogoTerceroState();
}

class _DialogoTerceroState extends State<_DialogoTercero> {
  late final TextEditingController _nombre =
      TextEditingController(text: widget.tercero?.nombre);
  late final TextEditingController _descripcion =
      TextEditingController(text: widget.tercero?.descripcion);
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  Future<void> _guardar() async {
    if (_guardando) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await widget.model.guardar(TerceroDto(
        idTercero: widget.tercero?.idTercero,
        nombre: _nombre.text,
        descripcion: _descripcion.text,
        createdAt: widget.tercero?.createdAt,
      ));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_t(widget.tercero == null ? 'ter_nuevo' : 'ter_editar')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombre,
            autofocus: true,
            enabled: !_guardando,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: _t('ter_nombre'),
              errorText: _error,
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: Espacio.m),
          TextField(
            controller: _descripcion,
            enabled: !_guardando,
            onSubmitted: (_) => _guardar(),
            decoration: InputDecoration(labelText: _t('ter_descripcion')),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: Text(_t('mov_cancelar')),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_t('ter_guardar')),
        ),
      ],
    );
  }
}
