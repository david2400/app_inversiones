import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

export 'package:inversiones/page/gestion/tipoProyecto/states/admin_tipo_proyecto_page_state.dart';
import 'package:inversiones/page/gestion/tipoProyecto/states/admin_tipo_proyecto_page_state.dart';

/// Alta de un tipo de proyecto (clasificación de los proyectos).
class AdminTipoProyectoPage extends StatefulWidget {
  const AdminTipoProyectoPage({super.key});

  @override
  State<AdminTipoProyectoPage> createState() => _AdminTipoProyectoPageState();
}

class _AdminTipoProyectoPageState extends State<AdminTipoProyectoPage> {
  late AdminTipoProyectoPageState _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminTipoProyectoPageState());

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
      titulo: textos.getText('atproy_titulo'),
      ayuda: textos.getText('atproy_ayuda'),
      mensajeExito: textos.getText('atproy_guardado'),
      hayCambios: _hayCambios,
      onGuardar: () => _model.insertTipoProyecto(),
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
