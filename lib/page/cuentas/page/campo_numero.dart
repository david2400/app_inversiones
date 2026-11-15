import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';

/// Campo numérico con etiqueta (pesos, porcentajes, días). Con [decimal]
/// acepta coma o punto para tasas como 1,85.
class CampoNumero extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;
  final String? ayuda;
  final String? prefijo;
  final String? sufijo;
  final bool decimal;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  const CampoNumero({
    super.key,
    required this.controller,
    required this.etiqueta,
    this.ayuda,
    this.prefijo,
    this.sufijo,
    this.decimal = false,
    this.validator,
    this.onChanged,
  });

  /// Entero escrito en [texto] (nulo si está vacío o no es válido).
  static int? entero(String texto) => int.tryParse(texto.trim());

  /// Decimal escrito en [texto], aceptando coma decimal.
  static double? numero(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        decimal
            ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
            : FilteringTextInputFormatter.digitsOnly,
      ],
      textInputAction: TextInputAction.next,
      style: FlutterFlowTheme.of(context).bodyMedium,
      decoration: InputDecoration(
        labelText: etiqueta,
        helperText: ayuda,
        helperMaxLines: 2,
        prefixText: prefijo,
        suffixText: sufijo,
      ),
    );
  }
}
