import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/interfaces/exportacion_interface.dart';
import 'package:inversiones/page/configuracion/respaldo/states/respaldo_page_state.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/drawer_widget.dart';

class RespaldoPage extends StatefulWidget {
  const RespaldoPage({super.key});

  @override
  State<RespaldoPage> createState() => _RespaldoPageState();
}

class _RespaldoPageState extends State<RespaldoPage> {
  late RespaldoPageState _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RespaldoPageState());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  Future<void> _ejecutar(Future<void> Function() accion) async {
    setState(() => _model.procesando = true);
    try {
      await accion();
    } catch (e) {
      _mensaje(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _model.procesando = false);
    }
  }

  void _mensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto), duration: const Duration(seconds: 6)));
  }

  Future<void> _exportar() => _ejecutar(() async {
        final ruta = await _model.exportar(_t('resp_elegir_carpeta'));
        if (ruta != null) _mensaje('${_t('resp_exportado')}\n$ruta');
      });

  Future<void> _exportarCsv() => _ejecutar(() async {
        final ruta = await _model.exportarCsv(_t('resp_elegir_carpeta'));
        if (ruta != null) _mensaje('${_t('exp_exportado')}\n$ruta');
      });

  Future<void> _restaurar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t('resp_restaurar_titulo')),
        content: Text(_t('resp_restaurar_mensaje')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(_t('mov_cancelar')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(_t('resp_restaurar')),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    await _ejecutar(() async {
      final restaurado = await _model.restaurar(_t('resp_elegir_archivo'));
      if (!restaurado || !mounted) return;
      _mensaje(_t('resp_restaurado'));
      context.goNamed('home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('resp_titulo')),
        backgroundColor: tema.primaryBackground,
      ),
      drawer: const DrawerWidget(),
      backgroundColor: tema.primaryBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(_t('resp_intro'),
                style: tema.bodyMedium.copyWith(color: tema.secondaryText)),
            const SizedBox(height: 16),
            _Tarjeta(
              icono: Icons.download_rounded,
              titulo: _t('resp_exportar'),
              descripcion: _t('resp_exportar_desc'),
              accion: _t('resp_exportar'),
              onAccion: _model.procesando ? null : _exportar,
            ),
            const SizedBox(height: 12),
            _Tarjeta(
              icono: Icons.table_view_rounded,
              titulo: _t('exp_titulo'),
              descripcion: _t('exp_desc'),
              accion: _t('exp_accion'),
              onAccion: _model.procesando ? null : _exportarCsv,
              extra: SegmentedButton<PeriodoExportacion>(
                segments: [
                  ButtonSegment(
                      value: PeriodoExportacion.mesActual,
                      label: Text(_t('exp_mes'))),
                  ButtonSegment(
                      value: PeriodoExportacion.anioActual,
                      label: Text(_t('exp_anio'))),
                  ButtonSegment(
                      value: PeriodoExportacion.todo,
                      label: Text(_t('exp_todo'))),
                ],
                selected: {_model.periodoCsv},
                showSelectedIcon: false,
                onSelectionChanged: (seleccion) =>
                    setState(() => _model.periodoCsv = seleccion.first),
              ),
            ),
            const SizedBox(height: 12),
            _Tarjeta(
              icono: Icons.restore_rounded,
              titulo: _t('resp_restaurar'),
              descripcion: _t('resp_restaurar_desc'),
              accion: _t('resp_restaurar'),
              onAccion: _model.procesando ? null : _restaurar,
            ),
            if (_model.procesando)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final String accion;
  final VoidCallback? onAccion;
  final Widget? extra;

  const _Tarjeta({
    this.extra,
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.accion,
    required this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tema.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tema.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icono, color: tema.primary),
            const SizedBox(width: 8),
            Text(titulo, style: tema.titleMedium),
          ]),
          const SizedBox(height: 8),
          Text(descripcion,
              style: tema.bodySmall.copyWith(color: tema.secondaryText)),
          if (extra != null) ...[
            const SizedBox(height: 12),
            extra!,
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(onPressed: onAccion, child: Text(accion)),
          ),
        ],
      ),
    );
  }
}
