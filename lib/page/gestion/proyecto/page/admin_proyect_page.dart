import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

export 'package:inversiones/page/gestion/proyecto/states/admin_proyect_page_state.dart';
import 'package:inversiones/page/gestion/proyecto/states/admin_proyect_page_state.dart';

/// Alta de un proyecto: agrupa portafolios y movimientos bajo un objetivo.
class AdminProyectPage extends StatefulWidget {
  const AdminProyectPage({super.key});

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
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool _hayCambios() =>
      _model.nombreController.text.trim().isNotEmpty ||
      _model.descripcionController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    return FormularioCatalogo(
      titulo: textos.getText('aproy_titulo'),
      ayuda: textos.getText('aproy_ayuda'),
      mensajeExito: textos.getText('aproy_guardado'),
      hayCambios: _hayCambios,
      onGuardar: () => _model.insertProyecto(),
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
      ],
    );
  }
}
