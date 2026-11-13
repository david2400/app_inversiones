import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

export 'package:inversiones/page/movimientos/tipoTransaccion/states/admin_transaccion_page_state.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/states/admin_transaccion_page_state.dart';

/// Alta de un tipo de transacción (ingreso, egreso o transferencia).
class AdminTipoTransaccionPage extends StatefulWidget {
  const AdminTipoTransaccionPage({super.key});

  @override
  State<AdminTipoTransaccionPage> createState() =>
      _AdminTipoTransaccionPageState();
}

class _AdminTipoTransaccionPageState extends State<AdminTipoTransaccionPage> {
  /// Códigos de `tipo_fuente` (ver `TipoFuente`): I ingreso, E egreso,
  /// M transferencia entre cuentas.
  static const _fuenteIngreso = 'I';
  static const _fuenteEgreso = 'E';
  static const _fuenteTransferencia = 'M';

  late AdminTipoTransaccionPageState _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminTipoTransaccionPageState());

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
      _model.descripcionController.text.trim().isNotEmpty ||
      _model.tipoFuente != null;

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    return FormularioCatalogo(
      titulo: textos.getText('atrx_titulo'),
      ayuda: textos.getText('atrx_ayuda'),
      mensajeExito: textos.getText('atrx_guardado'),
      hayCambios: _hayCambios,
      onGuardar: () => _model.insertTipoTransaccion(),
      campos: [
        CampoTexto(
          controller: _model.nombreController,
          focusNode: _model.nombreFocus,
          etiqueta: textos.getText('form_nombre'),
          validator:
              validarTextoObligatorio(textos.getText('form_nombre_requerido')),
        ),
        CampoSeleccion<String>(
          etiqueta: textos.getText('atrx_tipo_fuente'),
          ayuda: textos.getText('atrx_tipo_fuente_ayuda'),
          opciones: [
            OpcionSeleccion(
                _fuenteIngreso, textos.getText('atrx_fuente_ingreso')),
            OpcionSeleccion(_fuenteEgreso, textos.getText('atrx_fuente_egreso')),
            OpcionSeleccion(_fuenteTransferencia,
                textos.getText('atrx_fuente_transferencia')),
          ],
          onChanged: (valor) => _model.tipoFuente = valor,
          validator: validarSeleccionObligatoria<String>(
              textos.getText('form_seleccion_requerida')),
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
