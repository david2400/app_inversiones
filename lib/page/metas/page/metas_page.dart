import 'package:flutter/material.dart';
import 'package:inversiones/page/cuentas/page/campo_numero.dart';
import 'package:inversiones/page/metas/dto/meta_dto.dart';
import 'package:inversiones/page/metas/page/metas_widgets.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

export 'package:inversiones/page/metas/states/metas_page_state.dart';
import 'package:inversiones/page/metas/states/metas_page_state.dart';

/// Metas de ahorro con su avance. Tocar una meta abre su detalle con las
/// acciones (editar, programar aporte, pausar, eliminar).
class MetasPage extends StatefulWidget {
  const MetasPage({super.key});

  @override
  State<MetasPage> createState() => _MetasPageState();
}

class _MetasPageState extends State<MetasPage> {
  static const _rutaFormulario = 'admin_meta';

  late MetasPageState _model;
  late Future<List<AvanceMetaDto>> _metas;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MetasPageState());
    _metas = _model.listar();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _metas = _model.listar();
    });
  }

  Future<void> _abrirFormulario([int? idMeta]) async {
    final guardado = await context.pushNamed<bool>(
      _rutaFormulario,
      queryParameters: {
        'idMeta': serializeParam(idMeta, ParamType.int, isList: false),
      }.withoutNulls,
    );
    if (guardado == true) _recargar();
  }

  Future<void> _ejecutar(Future<void> Function() accion, String exito) async {
    try {
      await accion();
      if (mounted) mostrarMensaje(context, _t(exito));
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
    _recargar();
  }

  Future<void> _eliminar(AvanceMetaDto meta) async {
    final confirmado = await confirmarAccion(
      context,
      titulo: _t('meta_eliminar_titulo'),
      mensaje: '${meta.nombre}\n\n${_t('meta_eliminar_ayuda')}',
      textoConfirmar: _t('ter_eliminar'),
      textoCancelar: _t('mov_cancelar'),
      destructiva: true,
    );
    if (confirmado) {
      await _ejecutar(() => _model.eliminar(meta.idMeta), 'meta_eliminada');
    }
  }

  Future<void> _programarAporte(AvanceMetaDto meta) async {
    final programado = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoAporteMeta(meta: meta, model: _model),
    );
    if (programado == true) {
      if (mounted) mostrarMensaje(context, _t('meta_aporte_programado'));
      _recargar();
    }
  }

  Future<void> _verDetalle(AvanceMetaDto meta) async {
    final accion = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      builder: (_) => _DetalleMeta(meta: meta),
    );
    if (!mounted || accion == null) return;
    switch (accion) {
      case 'editar':
        await _abrirFormulario(meta.idMeta);
      case 'aporte':
        await _programarAporte(meta);
      case 'pausar':
        await _ejecutar(() => _model.cambiarActivo(meta),
            meta.activo ? 'meta_pausada' : 'meta_reactivada');
      case 'eliminar':
        await _eliminar(meta);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: _t('meta_titulo'),
      botonFlotante: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add_rounded),
        label: Text(_t('meta_agregar')),
      ),
      cuerpo: ContenidoAsincrono<List<AvanceMetaDto>>(
        future: _metas,
        mensajeError: _t('meta_error'),
        textoReintentar: _t('tproy_reintentar'),
        onReintentar: _recargar,
        esVacio: (metas) => metas.isEmpty,
        vacio: EstadoVacio(
          icono: Icons.flag_outlined,
          mensaje: _t('meta_vacio'),
          textoAccion: _t('meta_agregar'),
          onAccion: () => _abrirFormulario(),
        ),
        builder: (context, metas) {
          final activas = metas.where((m) => m.activo).toList();
          final pausadas = metas.where((m) => !m.activo).toList();
          return RefreshIndicator(
            onRefresh: () async => _recargar(),
            child: ListView(
              padding: Espacio.pantalla.copyWith(bottom: 96),
              children: [
                for (final meta in activas) ...[
                  TarjetaMeta(meta: meta, onTap: () => _verDetalle(meta)),
                  const SizedBox(height: Espacio.m),
                ],
                if (pausadas.isNotEmpty) ...[
                  EncabezadoSeccion(titulo: _t('meta_pausadas')),
                  for (final meta in pausadas) ...[
                    TarjetaMeta(meta: meta, onTap: () => _verDetalle(meta)),
                    const SizedBox(height: Espacio.m),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Detalle de una meta: cifras, portafolios y acciones. Devuelve la acción
/// elegida ('editar', 'aporte', 'pausar', 'eliminar').
class _DetalleMeta extends StatelessWidget {
  final AvanceMetaDto meta;

  const _DetalleMeta({required this.meta});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    String t(String c) => textos.getText(c);
    String cop(int v) => FormatoMoneda.cop(v);
    final tasa = meta.tasaEa.toStringAsFixed(1).replaceAll('.', ',');

    Widget dato(String etiqueta, String valor) => Padding(
          padding: const EdgeInsets.symmetric(vertical: Espacio.xs),
          child: Row(children: [
            Expanded(
                child: Text(etiqueta,
                    style: tema.bodyMedium.copyWith(color: tema.secondaryText))),
            Text(valor, style: tema.bodyMedium),
          ]),
        );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            Espacio.l, 0, Espacio.l, Espacio.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(child: Text(meta.nombre, style: tema.titleLarge)),
              EtiquetaEstadoMeta(estado: meta.estado),
            ]),
            if (meta.descripcion != null) ...[
              const SizedBox(height: Espacio.xs),
              Text(meta.descripcion!,
                  style: tema.bodySmall.copyWith(color: tema.secondaryText)),
            ],
            const SizedBox(height: Espacio.l),
            BarraAvanceMeta(
                porcentaje: meta.porcentaje,
                color: estiloEstadoMeta(meta.estado, tema).color),
            const SizedBox(height: Espacio.m),
            dato(t('meta_ahorrado'), cop(meta.ahorrado)),
            dato(t('meta_objetivo'), cop(meta.montoObjetivo)),
            dato(t('meta_falta'), cop(meta.falta)),
            if (meta.fechaObjetivo != null) ...[
              dato(t('meta_fecha'), textoFechaMeta(context, meta.fechaObjetivo!)),
              dato(t('meta_meses_restantes'), '${meta.mesesRestantes}'),
              dato(t('meta_cuota_sugerida'),
                  '${cop(meta.cuotaSugerida ?? 0)} ${t('meta_al_mes')}'),
              dato(t('meta_aporte_actual'),
                  '${cop(meta.aporteProgramadoMensual)} ${t('meta_al_mes')}'),
              if (meta.proyeccion != null)
                dato(t('meta_proyeccion'), cop(meta.proyeccion!)),
            ],
            dato(t('meta_tasa'), '$tasa % E.A.'),
            EncabezadoSeccion(titulo: t('meta_portafolios')),
            for (final p in meta.portafolios) dato(p.nombre, cop(p.saldo)),
            const SizedBox(height: Espacio.l),
            if (meta.activo &&
                !meta.completada &&
                meta.receptoresDeAporte.isNotEmpty)
              BotonPrincipal(
                texto: t('meta_programar_aporte'),
                icono: Icons.event_repeat_rounded,
                onPressed: () => Navigator.of(context).pop('aporte'),
              ),
            const SizedBox(height: Espacio.s),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: Espacio.s,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop('editar'),
                  icon: const Icon(Icons.edit_rounded),
                  label: Text(t('meta_editar')),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop('pausar'),
                  icon: Icon(meta.activo
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded),
                  label: Text(t(meta.activo ? 'meta_pausar' : 'meta_reactivar')),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: tema.error),
                  onPressed: () => Navigator.of(context).pop('eliminar'),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(t('ter_eliminar')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo para crear el aporte programado mensual desde la meta, con la
/// cuota sugerida ya escrita.
class _DialogoAporteMeta extends StatefulWidget {
  final AvanceMetaDto meta;
  final MetasPageState model;

  const _DialogoAporteMeta({required this.meta, required this.model});

  @override
  State<_DialogoAporteMeta> createState() => _DialogoAporteMetaState();
}

class _DialogoAporteMetaState extends State<_DialogoAporteMeta> {
  late final TextEditingController _valor;
  final _dia = TextEditingController(text: '1');
  late int _portafolio;
  bool _automatico = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _portafolio = widget.meta.receptoresDeAporte.first.idPortafolio;
    _valor = TextEditingController(text: _sugerida(_portafolio));
  }

  /// Cuota sugerida menos lo que ya aportan los demás portafolios (el
  /// aporte del elegido se reemplaza).
  String _sugerida(int idPortafolio) {
    final propio = widget.meta.portafolios
        .firstWhere((p) => p.idPortafolio == idPortafolio)
        .aporteMensual;
    final valor = (widget.meta.cuotaSugerida ?? 0) -
        (widget.meta.aporteProgramadoMensual - propio);
    return valor > 0 ? '$valor' : '';
  }

  @override
  void dispose() {
    _valor.dispose();
    _dia.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      await widget.model.programarAporte(widget.meta.idMeta,
          idPortafolio: _portafolio,
          valor: CampoNumero.entero(_valor.text),
          diaMes: CampoNumero.entero(_dia.text) ?? 0,
          automatico: _automatico);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      mostrarMensaje(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    String t(String c) => textos.getText(c);
    return AlertDialog(
      title: Text(t('meta_programar_aporte')),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(t('meta_aporte_ayuda'),
              style: FlutterFlowTheme.of(context).bodySmall),
          const SizedBox(height: Espacio.l),
          CampoSeleccion<int>(
            etiqueta: t('meta_aporte_destino'),
            valorInicial: _portafolio,
            opciones: [
              for (final p in widget.meta.receptoresDeAporte)
                OpcionSeleccion(p.idPortafolio, p.nombre),
            ],
            onChanged: (v) => setState(() {
              _portafolio = v ?? _portafolio;
              _valor.text = _sugerida(_portafolio);
            }),
          ),
          const SizedBox(height: Espacio.m),
          CampoNumero(
              controller: _valor,
              etiqueta: t('meta_aporte_valor'),
              prefijo: '\$ ',
              ayuda: t('meta_aporte_valor_ayuda')),
          const SizedBox(height: Espacio.m),
          CampoNumero(controller: _dia, etiqueta: t('meta_aporte_dia')),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _automatico,
            onChanged: (v) => setState(() => _automatico = v),
            title: Text(t('meta_aporte_automatico')),
          ),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: Text(t('mov_cancelar')),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: Text(t('form_guardar')),
        ),
      ],
    );
  }
}
