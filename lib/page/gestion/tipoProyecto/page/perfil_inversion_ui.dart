import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/perfil_inversion.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

/// Color que representa un nivel de riesgo.
Color colorRiesgo(FlutterFlowTheme tema, String? riesgo) => switch (riesgo) {
      NivelRiesgo.bajo => tema.success,
      NivelRiesgo.medio => tema.warning,
      NivelRiesgo.alto => tema.error,
      _ => tema.secondaryText,
    };

/// Etiqueta compacta con el nivel de riesgo; no muestra nada si no está
/// definido.
class EtiquetasPerfil extends StatelessWidget {
  final String? riesgo;

  const EtiquetasPerfil({super.key, this.riesgo});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final r = riesgo;
    if (r == null) return const SizedBox.shrink();
    return _Etiqueta(
      texto: textos.getText(NivelRiesgo.clave(r)),
      color: colorRiesgo(tema, r),
      icono: Icons.speed_rounded,
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData icono;

  const _Etiqueta(
      {required this.texto, required this.color, required this.icono});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Espacio.s, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radios.s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 12, color: color),
          const SizedBox(width: 4),
          Text(texto, style: tema.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
