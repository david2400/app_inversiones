import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

export 'package:inversiones/page/motivos/states/admin_motivos_page_state.dart';
import 'package:inversiones/page/motivos/states/admin_motivos_page_state.dart';

/// Alta de un motivo: por qué entra o sale el dinero.
class AdminMotivosPage extends StatefulWidget {
  const AdminMotivosPage({super.key});

  @override
  State<AdminMotivosPage> createState() => _AdminMotivosPageState();
}

class _AdminMotivosPageState extends State<AdminMotivosPage> {
  late AdminMotivosPageState _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminMotivosPageState());

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
      titulo: textos.getText('amot_titulo'),
      ayuda: textos.getText('amot_ayuda'),
      mensajeExito: textos.getText('amot_guardado'),
      hayCambios: _hayCambios,
      onGuardar: () => _model.insertMotivo(),
      campos: [
        CampoTexto(
          controller: _model.nombreController,
          focusNode: _model.nombreFocus,
          etiqueta: textos.getText('form_nombre'),
          validator:
              validarTextoObligatorio(textos.getText('form_nombre_requerido')),
        ),
        CampoTexto(
          controller: _model.descripcionController,
          focusNode: _model.descripcionFocus,
          etiqueta: textos.getText('form_descripcion'),
          ayuda: textos.getText('form_opcional'),
          maxLineas: 3,
        ),
      ],
    );
  }
}
