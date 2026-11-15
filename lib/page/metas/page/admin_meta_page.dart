import 'package:flutter/material.dart';
import 'package:inversiones/page/cuentas/page/campo_numero.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

export 'package:inversiones/page/metas/states/admin_meta_page_state.dart';
import 'package:inversiones/page/metas/states/admin_meta_page_state.dart';

/// Alta o edición de una meta de ahorro: nombre, monto, fecha opcional y
/// los portafolios donde se guarda el dinero. Con [idMeta] edita esa meta.
class AdminMetaPage extends StatefulWidget {
  final int? idMeta;

  const AdminMetaPage({super.key, this.idMeta});

  @override
  State<AdminMetaPage> createState() => _AdminMetaPageState();
}

class _AdminMetaPageState extends State<AdminMetaPage> {
  late AdminMetaPageState _model;
  bool _cargando = true;

  static final _formatoFecha = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminMetaPageState());
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      await _model.cargar(widget.idMeta);
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
    if (mounted) setState(() => _cargando = false);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _model.fechaObjetivo ?? DateTime(hoy.year + 1, hoy.month, hoy.day),
      firstDate: DateTime(hoy.year - 5),
      lastDate: DateTime(hoy.year + 50),
    );
    if (elegida != null) setState(() => _model.fechaObjetivo = elegida);
  }

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    String t(String clave) => textos.getText(clave);
    final tema = FlutterFlowTheme.of(context);
    if (_cargando) {
      return PantallaBase(
          titulo: t('meta_nueva'), conMenu: false, cuerpo: const EstadoCargando());
    }
    return FormularioCatalogo(
      titulo: t(_model.editando ? 'meta_editar' : 'meta_nueva'),
      ayuda: t('meta_form_ayuda'),
      mensajeExito: t('meta_guardada'),
      hayCambios: _model.hayCambios,
      onGuardar: () => _model.guardar(),
      campos: [
        CampoTexto(
          controller: _model.nombreController,
          focusNode: _model.nombreFocus,
          etiqueta: t('form_nombre'),
          ayuda: t('meta_nombre_ayuda'),
          validator: validarTextoObligatorio(t('form_nombre_requerido')),
        ),
        CampoNumero(
          controller: _model.montoController,
          etiqueta: t('meta_objetivo'),
          prefijo: '\$ ',
          validator: (v) => (CampoNumero.entero(v ?? '') ?? 0) > 0
              ? null
              : t('meta_monto_requerido'),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(Radios.m),
          onTap: _elegirFecha,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: t('meta_fecha'),
              helperText: t('meta_fecha_ayuda'),
              helperMaxLines: 2,
              suffixIcon: _model.fechaObjetivo == null
                  ? const Icon(Icons.event_rounded)
                  : IconButton(
                      tooltip: t('aport_quitar_fecha'),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () =>
                          setState(() => _model.fechaObjetivo = null),
                    ),
            ),
            child: Text(
              _model.fechaObjetivo == null
                  ? t('meta_sin_fecha')
                  : _formatoFecha.format(_model.fechaObjetivo!),
              style: tema.bodyMedium,
            ),
          ),
        ),
        CampoTexto(
          controller: _model.descripcionController,
          focusNode: _model.descripcionFocus,
          etiqueta: t('form_descripcion'),
          ayuda: t('form_opcional'),
          maxLineas: 3,
        ),
        _SelectorPortafolios(model: _model, onCambio: () => setState(() {})),
      ],
    );
  }
}

/// Lista de portafolios con casillas; exige elegir al menos uno.
class _SelectorPortafolios extends StatelessWidget {
  final AdminMetaPageState model;
  final VoidCallback onCambio;

  const _SelectorPortafolios({required this.model, required this.onCambio});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    String t(String c) => textos.getText(c);
    return FormField<Set<int>>(
      validator: (_) =>
          model.portafolios.isEmpty ? t('meta_portafolios_requerido') : null,
      builder: (estado) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('meta_portafolios'), style: tema.titleSmall),
          Text(t('meta_portafolios_ayuda'),
              style: tema.bodySmall.copyWith(color: tema.secondaryText)),
          const SizedBox(height: Espacio.s),
          if (model.disponibles.isEmpty)
            Text(t('meta_sin_portafolios'),
                style: tema.bodyMedium.copyWith(color: tema.secondaryText)),
          for (final p in model.disponibles)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              value: model.portafolios.contains(p.idPortafolio),
              title: Text(p.nombre, style: tema.bodyMedium),
              subtitle: Text(
                  p.tasaEa > 0
                      ? '${FormatoMoneda.cop(p.saldo)} · ${p.tasaEa} % E.A.'
                      : FormatoMoneda.cop(p.saldo),
                  style: tema.bodySmall.copyWith(color: tema.secondaryText)),
              onChanged: (marcado) {
                if (marcado == true) {
                  model.portafolios.add(p.idPortafolio);
                } else {
                  model.portafolios.remove(p.idPortafolio);
                }
                estado.didChange(model.portafolios);
                onCambio();
              },
            ),
          if (model.portafolios.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Espacio.xs),
              child: Text(
                  '${t('meta_ahorrado')}: ${FormatoMoneda.cop(model.ahorradoSeleccion)}',
                  style: tema.labelLarge),
            ),
          if (estado.hasError)
            Padding(
              padding: const EdgeInsets.only(top: Espacio.xs),
              child: Text(estado.errorText!,
                  style: tema.bodySmall.copyWith(color: tema.error)),
            ),
        ],
      ),
    );
  }
}
