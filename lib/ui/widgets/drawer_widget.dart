import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

/// Opción del menú lateral: clave i18n, icono y ruta de go_router.
class _OpcionMenu {
  final String clave;
  final IconData icono;
  final String ruta;

  const _OpcionMenu(this.clave, this.icono, this.ruta);
}

/// Grupo de opciones con su título.
class _GrupoMenu {
  final String clave;
  final List<_OpcionMenu> opciones;

  const _GrupoMenu(this.clave, this.opciones);
}

/// Menú lateral agrupado por áreas. Para añadir una página basta con
/// agregar una [_OpcionMenu] al grupo que corresponda.
class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  static const _inicio = _OpcionMenu('menu_inicio', Icons.dashboard_rounded, 'home');

  static const _grupos = [
    _GrupoMenu('menu_grupo_operacion', [
      _OpcionMenu('menu_movimientos', Icons.receipt_long_rounded, 'movimientos'),
      _OpcionMenu('menu_agenda', Icons.calendar_month_rounded, 'agenda'),
      _OpcionMenu('menu_fijos', Icons.event_repeat_rounded, 'recurrentes'),
      _OpcionMenu('menu_presupuestos', Icons.savings_rounded, 'presupuestos'),
    ]),
    _GrupoMenu('menu_grupo_patrimonio', [
      _OpcionMenu('menu_patrimonio', Icons.account_balance_rounded, 'patrimonio'),
      _OpcionMenu('menu_metas', Icons.flag_rounded, 'metas'),
      _OpcionMenu('menu_cuentas', Icons.credit_card_rounded, 'cuentas'),
      _OpcionMenu('menu_proyectos', Icons.work_rounded, 'proyects'),
      _OpcionMenu('menu_reportes', Icons.bar_chart_rounded, 'reportes'),
    ]),
    _GrupoMenu('menu_grupo_catalogos', [
      _OpcionMenu('menu_tipos_proyecto', Icons.category_rounded, 'tipo_proyecto'),
      _OpcionMenu('menu_tipos_transaccion', Icons.swap_horiz_rounded, 'tipo_transaccion'),
      _OpcionMenu('menu_motivos', Icons.label_rounded, 'motivos'),
      _OpcionMenu('menu_terceros', Icons.people_alt_rounded, 'terceros'),
    ]),
    _GrupoMenu('menu_grupo_configuracion', [
      _OpcionMenu('menu_respaldo', Icons.backup_rounded, 'respaldo'),
    ]),
  ];

  /// Nombre de la ruta abierta; null si el menú se usa fuera del router.
  static String? _rutaActual(BuildContext context) {
    try {
      return GoRouterState.of(context).name;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final rutaActual = _rutaActual(context);

    Widget opcion(_OpcionMenu o) {
      final activa = o.ruta == rutaActual;
      return ListTile(
        dense: true,
        selected: activa,
        selectedTileColor: tema.primary.withValues(alpha: 0.15),
        leading: Icon(o.icono),
        iconColor: tema.primaryText,
        textColor: tema.primaryText,
        selectedColor: tema.primary,
        title: Text(textos.getText(o.clave)),
        onTap: () {
          Navigator.of(context).pop();
          if (!activa) context.goNamed(o.ruta);
        },
      );
    }

    return Drawer(
      backgroundColor: tema.secondary,
      child: ListView(
        children: [
          // Encabezado local: la app es 100 % offline, sin imágenes remotas.
          DrawerHeader(
            decoration: BoxDecoration(color: tema.primaryBackground),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: tema.primary,
                  child: Icon(Icons.account_balance_wallet_rounded,
                      color: tema.primaryText),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(textos.getText('menu_app'),
                      style: tema.titleLarge),
                ),
              ],
            ),
          ),
          opcion(_inicio),
          for (final grupo in _grupos) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                textos.getText(grupo.clave).toUpperCase(),
                style: tema.labelSmall.override(
                  fontFamily: tema.labelSmallFamily,
                  color: tema.secondaryText,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            for (final o in grupo.opciones) opcion(o),
          ],
        ],
      ),
    );
  }
}
