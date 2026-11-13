import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

export 'package:inversiones/page/frecuenciaPago/states/admin_frecuencia_pago_page_state.dart';
import 'package:inversiones/page/frecuenciaPago/states/admin_frecuencia_pago_page_state.dart';

/// Alta de una frecuencia de pago: cada cuánto se repite un pago
/// (cantidad + unidad, por ejemplo "15 días" o "1 mes").
class AdminFrecuenciaPagoPage extends StatefulWidget {
  const AdminFrecuenciaPagoPage({super.key});

  @override
  State<AdminFrecuenciaPagoPage> createState() =>
      _AdminFrecuenciaPagoPageState();
}

class _AdminFrecuenciaPagoPageState extends State<AdminFrecuenciaPagoPage> {
  /// Cantidades permitidas (mismas que antes del rediseño).
  static const _cantidades = <int>[1, 2, 3, 4, 5, 6, 7, 15, 30, 60];

  /// Códigos de `formato`: D días, M meses, Y años.
  static const _formatoDias = 'D';
  static const _formatoMeses = 'M';
  static const _formatoAnios = 'Y';

  late AdminFrecuenciaPagoPageState _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminFrecuenciaPagoPageState());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool _hayCambios() => _model.tiempo != null || _model.formato != null;

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    final mensajeSeleccion = textos.getText('form_seleccion_requerida');
    return FormularioCatalogo(
      titulo: textos.getText('afrec_titulo'),
      ayuda: textos.getText('afrec_ayuda'),
      mensajeExito: textos.getText('afrec_guardado'),
      hayCambios: _hayCambios,
      onGuardar: () => _model.insertFrecuenciaPago(),
      campos: [
        CampoSeleccion<int>(
          etiqueta: textos.getText('afrec_cantidad'),
          opciones: [
            for (final cantidad in _cantidades)
              OpcionSeleccion(cantidad, cantidad.toString()),
          ],
          onChanged: (valor) => _model.tiempo = valor,
          validator: validarSeleccionObligatoria<int>(mensajeSeleccion),
        ),
        CampoSeleccion<String>(
          etiqueta: textos.getText('afrec_unidad'),
          opciones: [
            OpcionSeleccion(_formatoDias, textos.getText('afrec_dias')),
            OpcionSeleccion(_formatoMeses, textos.getText('afrec_meses')),
            OpcionSeleccion(_formatoAnios, textos.getText('afrec_anios')),
          ],
          onChanged: (valor) => _model.formato = valor,
          validator: validarSeleccionObligatoria<String>(mensajeSeleccion),
        ),
      ],
    );
  }
}
