import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

export 'package:inversiones/page/gestion/proyecto/states/admin_proyect_page_state.dart';
import 'package:inversiones/page/gestion/proyecto/states/admin_proyect_page_state.dart';

/// Alta o edición de un proyecto: agrupa portafolios y movimientos bajo un
/// objetivo. Con [idProyecto] edita ese proyecto.
class AdminProyectPage extends StatefulWidget {
  final int? idProyecto;

  const AdminProyectPage({super.key, this.idProyecto});

  @override
  State<AdminProyectPage> createState() => _AdminProyectPageState();
}

class _AdminProyectPageState extends State<AdminProyectPage> {
  late AdminProyectPageState _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminProyectPageState());

    _model.nombreFocus ??= FocusNode();
    _model.nombreController ??= TextEditingController();

    _model.descripcionFocus ??= FocusNode();
    _model.descripcionController ??= TextEditingController();

    _cargarDatos();
  }

  /// Sin tipo elegido (valor del desplegable).
  static const _sinTipo = 0;

  /// Cambia al terminar de cargar para reconstruir el desplegable.
  int _version = 0;
  int? _tipoInicial;

  Future<void> _cargarDatos() async {
    try {
      await _model.cargarTipos();
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
    if (widget.idProyecto != null) await _cargar(widget.idProyecto!);
    if (mounted) {
      setState(() {
        _version++;
      });
    }
  }

  bool get _editando => widget.idProyecto != null;

  /// Valores al abrir, para saber si el usuario cambió algo.
  String _nombreInicial = '';
  String _descripcionInicial = '';

  Future<void> _cargar(int id) async {
    try {
      await _model.cargarProyecto(id);
      _nombreInicial = _model.nombreController!.text;
      _descripcionInicial = _model.descripcionController!.text;
      _tipoInicial = _model.tipoProyectoId;
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool _hayCambios() =>
      _model.nombreController!.text.trim() != _nombreInicial.trim() ||
      _model.descripcionController!.text.trim() !=
          _descripcionInicial.trim() ||
      _model.tipoProyectoId != _tipoInicial;

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    return FormularioCatalogo(
      titulo: textos.getText(_editando ? 'aproy_editar' : 'aproy_titulo'),
      ayuda: textos.getText('aproy_ayuda'),
      mensajeExito: textos.getText('aproy_guardado'),
      hayCambios: _hayCambios,
      onGuardar: () => _model.guardarProyecto(),
      campos: [
        CampoTexto(
          controller: _model.nombreController,
          focusNode: _model.nombreFocus,
          etiqueta: textos.getText('aproy_nombre'),
          validator:
              validarTextoObligatorio(textos.getText('form_nombre_requerido')),
        ),
        CampoTexto(
          controller: _model.descripcionController,
          focusNode: _model.descripcionFocus,
          etiqueta: textos.getText('form_descripcion'),
          ayuda: textos.getText('form_opcional'),
          minLineas: 2,
          maxLineas: 4,
        ),
        CampoSeleccion<int>(
          key: ValueKey('tipo-$_version'),
          etiqueta: textos.getText('aproy_tipo'),
          ayuda: textos.getText('aproy_tipo_ayuda'),
          valorInicial: _model.tipos
                  .any((t) => t.idTipoProyecto == _model.tipoProyectoId)
              ? _model.tipoProyectoId
              : _sinTipo,
          opciones: [
            OpcionSeleccion(_sinTipo, textos.getText('aproy_sin_tipo')),
            for (final tipo in _model.tipos)
              OpcionSeleccion(tipo.idTipoProyecto!, tipo.nombre),
          ],
          onChanged: (valor) => _model.tipoProyectoId =
              (valor == null || valor == _sinTipo) ? null : valor,
        ),
      ],
    );
  }
}
