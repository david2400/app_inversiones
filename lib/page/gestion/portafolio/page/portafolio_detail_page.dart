import 'package:flutter/material.dart';

import 'package:inversiones/ui/utils/flutter_flow_drop_down.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/form_field_controller.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

export 'package:inversiones/page/gestion/portafolio/states/portafolio_detail_page_state.dart';
import 'package:inversiones/page/gestion/portafolio/states/portafolio_detail_page_state.dart';

/// Detalle del portafolio: saludo, filtros, accesos rápidos (transferir y
/// actividad) y últimos movimientos.
///
/// Pendiente: los filtros no tienen opciones y los movimientos son textos de
/// la plantilla; el State aún no expone datos reales del portafolio.
class PortafolioDetailPage extends StatefulWidget {
  const PortafolioDetailPage({super.key});

  @override
  State<PortafolioDetailPage> createState() => _PortafolioDetailPageState();
}

/// Fila de movimiento (claves de traducción existentes de la plantilla).
class _FilaMovimiento {
  final String claveTitulo;
  final String claveSubtitulo;
  final String claveMonto;
  final String claveNota;
  final bool conTransicion;

  const _FilaMovimiento(
    this.claveTitulo,
    this.claveSubtitulo,
    this.claveMonto,
    this.claveNota, {
    this.conTransicion = false,
  });
}

class _PortafolioDetailPageState extends State<PortafolioDetailPage> {
  late PortafolioDetailPageModel _model;

  static const _rutaTransferir = 'addTransfer';
  static const _rutaActividad = 'portafolio_activity';
  static const _rutaDetallePago = 'paymentDetailsPage';

  static const _altoCampo = 56.0;
  static const _tamanoAvatar = 56.0;
  static const _tamanoIconoAccion = 28.0;
  static const _cifrasTabulares = [FontFeature.tabularFigures()];

  static const _transicionInferior = TransitionInfo(
    hasTransition: true,
    transitionType: PageTransitionType.bottomToTop,
    duration: Duration(milliseconds: 220),
  );

  static const _movimientos = [
    _FilaMovimiento('r13uhw9n', 'avy3an06', 'npym38ai', 'be6mty9b'),
    _FilaMovimiento('3uebdebf', 'tilesq3d', 'sd8zd16p', '5kqft89q'),
    _FilaMovimiento('j2auhz4g', 'bubip62r', '2keaoz3o', '02mq64si'),
    _FilaMovimiento('tbg31o3c', '0i62m9lp', 'zg4zhpde', 'ip1tbax1',
        conTransicion: true),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PortafolioDetailPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  /// Navega a [ruta]; si la ruta no está registrada avisa en vez de fallar.
  Future<void> _navegar(String ruta, {bool conTransicion = false}) async {
    final mensajeError = _t('pdet_ruta_no_disponible');
    try {
      await context.pushNamed(
        ruta,
        extra: conTransicion
            ? <String, dynamic>{kTransitionInfoKey: _transicionInferior}
            : null,
      );
    } catch (_) {
      if (!mounted) return;
      mostrarMensaje(context, mensajeError);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: _t('pdet_titulo'),
      conMenu: false,
      acciones: [
        IconButton(
          tooltip: _t('pdet_cerrar'),
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ],
      cuerpo: ListView(
        padding: Espacio.pantalla,
        children: [
          _encabezado(),
          EncabezadoSeccion(titulo: _t('pdet_filtros')),
          _filtros(),
          EncabezadoSeccion(titulo: _t('xvmk449f' /* Quick Service */)),
          _accionesRapidas(),
          EncabezadoSeccion(titulo: _t('bpkc110o' /* Transaction */)),
          _listaMovimientos(),
        ],
      ),
    );
  }

  Widget _encabezado() {
    final tema = FlutterFlowTheme.of(context);
    return Tarjeta(
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: _tamanoAvatar,
              height: _tamanoAvatar,
              child: ColoredBox(
                color: tema.accent1,
                child: Image.asset(
                  'assets/images/avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.person_rounded, color: tema.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: Espacio.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: _t('xnadgj4u' /* Welcome, */)),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: _t('pknlsgbc' /* Andrew */),
                        style: TextStyle(color: tema.primary),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tema.titleMedium,
                ),
                const SizedBox(height: Espacio.xs),
                Text(
                  _t('vmxubknb' /* Your latest updates are below. */),
                  style: tema.bodySmall.copyWith(color: tema.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtros() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _filtro(
                controller: _model.dropDownValueController1 ??=
                    FormFieldController<String>(null),
                claveAyuda: 's8j4oxuy',
                alCambiar: (val) => setState(() => _model.dropDownValue1 = val),
              ),
            ),
            const SizedBox(width: Espacio.m),
            Expanded(
              child: _filtro(
                controller: _model.dropDownValueController2 ??=
                    FormFieldController<String>(null),
                claveAyuda: 'c7fvbto8',
                alCambiar: (val) => setState(() => _model.dropDownValue2 = val),
              ),
            ),
          ],
        ),
        const SizedBox(height: Espacio.m),
        Row(
          children: [
            Expanded(
              child: _filtro(
                controller: _model.dropDownValueController3 ??=
                    FormFieldController<String>(null),
                claveAyuda: 'cw1n8hek',
                alCambiar: (val) => setState(() => _model.dropDownValue3 = val),
              ),
            ),
            const SizedBox(width: Espacio.m),
            Expanded(
              child: _filtro(
                controller: _model.dropDownValueController4 ??=
                    FormFieldController<String>(null),
                claveAyuda: 'm9x2vsy5',
                alCambiar: (val) => setState(() => _model.dropDownValue4 = val),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _filtro({
    required FormFieldController<String> controller,
    required String claveAyuda,
    required void Function(String?) alCambiar,
  }) {
    final tema = FlutterFlowTheme.of(context);
    return FlutterFlowDropDown<String>(
      controller: controller,
      // Pendiente: el State todavía no provee opciones para estos filtros.
      options: const [],
      onChanged: alCambiar,
      width: double.infinity,
      height: _altoCampo,
      textStyle: tema.bodyMedium,
      hintText: _t(claveAyuda /* Please select... */),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: tema.secondaryText),
      fillColor: tema.secondaryBackground,
      elevation: 0,
      borderColor: tema.alternate,
      borderWidth: 1,
      borderRadius: Radios.s,
      margin: const EdgeInsetsDirectional.fromSTEB(
          Espacio.m, Espacio.xs, Espacio.m, Espacio.xs),
      hidesUnderline: true,
      isOverButton: true,
      isSearchable: false,
    );
  }

  Widget _accionesRapidas() {
    return Row(
      children: [
        Expanded(
          child: _accionRapida(
            icono: Icons.swap_horiz_rounded,
            texto: _t('l9rauiui' /* Transfer */),
            onTap: () => _navegar(_rutaTransferir, conTransicion: true),
          ),
        ),
        const SizedBox(width: Espacio.m),
        Expanded(
          child: _accionRapida(
            icono: Icons.stacked_line_chart_rounded,
            texto: _t('xxdq1tzd' /* Activity */),
            onTap: () => _navegar(_rutaActividad),
          ),
        ),
      ],
    );
  }

  Widget _accionRapida({
    required IconData icono,
    required String texto,
    required VoidCallback onTap,
  }) {
    final tema = FlutterFlowTheme.of(context);
    return Semantics(
      button: true,
      label: texto,
      excludeSemantics: true,
      child: Tarjeta(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
            vertical: Espacio.l, horizontal: Espacio.m),
        child: Column(
          children: [
            Icon(icono, size: _tamanoIconoAccion, color: tema.primary),
            const SizedBox(height: Espacio.s),
            Text(
              texto,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tema.labelLarge.copyWith(color: tema.primaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaMovimientos() {
    return Tarjeta(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < _movimientos.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _filaMovimiento(_movimientos[i]),
          ],
        ],
      ),
    );
  }

  Widget _filaMovimiento(_FilaMovimiento fila) {
    final tema = FlutterFlowTheme.of(context);
    return ListTile(
      minVerticalPadding: Espacio.m,
      contentPadding: const EdgeInsets.symmetric(horizontal: Espacio.l),
      onTap: () =>
          _navegar(_rutaDetallePago, conTransicion: fila.conTransicion),
      leading: CircleAvatar(
        backgroundColor: tema.accent1,
        foregroundColor: tema.primary,
        child: const Icon(Icons.monetization_on_rounded),
      ),
      title: Text(
        _t(fila.claveTitulo),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tema.bodyLarge.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        _t(fila.claveSubtitulo),
        style: tema.bodySmall.copyWith(color: tema.secondaryText),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _t(fila.claveMonto),
            textAlign: TextAlign.end,
            style: tema.titleSmall.copyWith(
              color: tema.primaryText,
              fontFeatures: _cifrasTabulares,
            ),
          ),
          const SizedBox(height: Espacio.xs),
          Text(
            _t(fila.claveNota),
            textAlign: TextAlign.end,
            style: tema.bodySmall.copyWith(color: tema.secondaryText),
          ),
        ],
      ),
    );
  }
}
