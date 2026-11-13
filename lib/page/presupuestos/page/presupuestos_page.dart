import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inversiones/page/presupuestos/dto/presupuesto_dto.dart';
import 'package:inversiones/page/presupuestos/states/presupuestos_page_state.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/drawer_widget.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

/// Presupuestos mensuales por motivo y su avance en el mes actual.
class PresupuestosPage extends StatefulWidget {
  const PresupuestosPage({super.key});

  @override
  State<PresupuestosPage> createState() => _PresupuestosPageState();
}

class _PresupuestosPageState extends State<PresupuestosPage> {
  late PresupuestosPageState _model;
  late Future<List<EjecucionPresupuestoDto>> _presupuestos;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PresupuestosPageState());
    _presupuestos = _model.cargar();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  void _recargar() => setState(() {
        _presupuestos = _model.cargar();
      });

  void _mensaje(Object texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(texto.toString().replaceFirst('Exception: ', ''))));
  }

  /// Alta (sin [actual]) o cambio de monto de un presupuesto.
  Future<void> _editar([EjecucionPresupuestoDto? actual]) async {
    int? motivoId = actual?.motivoId;
    int? cuentaId = actual?.cuentaId;
    final monto = TextEditingController(
        text: actual == null ? '' : '${actual.montoMensual}');
    final guardado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(_t(actual == null ? 'pre_nuevo' : 'pre_editar')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actual == null)
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  decoration: InputDecoration(labelText: _t('frm_motivo')),
                  items: [
                    for (final m in _model.motivos)
                      DropdownMenuItem(value: m.idMotivo, child: Text(m.nombre)),
                  ],
                  onChanged: (v) => setDialogState(() => motivoId = v),
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      actual.cuenta == null
                          ? actual.motivo
                          : '${actual.motivo} · ${actual.cuenta}',
                      style: FlutterFlowTheme.of(context).titleMedium),
                ),
              if (actual == null) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  isExpanded: true,
                  initialValue: null,
                  decoration: InputDecoration(
                    labelText: _t('pre_cuenta'),
                    helperText: _t('pre_cuenta_ayuda'),
                    helperMaxLines: 2,
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                        value: null, child: Text(_t('pre_todas_cuentas'))),
                    for (final c in _model.cuentas)
                      DropdownMenuItem<int?>(
                          value: c.idCuenta, child: Text(c.nombre)),
                  ],
                  onChanged: (v) => setDialogState(() {
                    cuentaId = v;
                  }),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: monto,
                autofocus: actual != null,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: _t('pre_monto'),
                  prefixText: '\$ ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_t('mov_cancelar')),
            ),
            FilledButton(
              onPressed: () async {
                if (motivoId == null) {
                  _mensaje(_t('pre_error_motivo'));
                  return;
                }
                try {
                  await _model.guardar(
                      motivoId!, int.tryParse(monto.text) ?? 0,
                      cuentaId: cuentaId);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(true);
                  }
                } catch (e) {
                  _mensaje(e);
                }
              },
              child: Text(_t('ter_guardar')),
            ),
          ],
        ),
      ),
    );
    // Los controladores del diálogo no se liberan aquí: el diálogo sigue
    // pintándose durante su animación de cierre y fallaría al usarlos.
    if (guardado == true) _recargar();
  }

  Future<void> _eliminar(EjecucionPresupuestoDto p) async {
    try {
      await _model.eliminar(p.idPresupuesto);
      _recargar();
    } catch (e) {
      _mensaje(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('pre_titulo')),
        backgroundColor: tema.primaryBackground,
      ),
      drawer: const DrawerWidget(),
      backgroundColor: tema.primaryBackground,
      floatingActionButton: FloatingActionButton(
        tooltip: _t('pre_nuevo'),
        onPressed: () => _editar(),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: FutureBuilder<List<EjecucionPresupuestoDto>>(
          future: _presupuestos,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(_t('dash_error')));
            }
            final presupuestos = snapshot.data ?? [];
            if (presupuestos.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_t('pre_vacio'),
                      textAlign: TextAlign.center, style: tema.bodyMedium),
                ),
              );
            }
            final limite =
                presupuestos.fold<int>(0, (s, p) => s + p.montoMensual);
            final gastado = presupuestos.fold<int>(0, (s, p) => s + p.gastado);
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              children: [
                Text(
                  '${_t('pre_total_mes')}: ${FormatoMoneda.cop(gastado)} / ${FormatoMoneda.cop(limite)}',
                  style: tema.titleSmall,
                ),
                const SizedBox(height: 8),
                for (final p in presupuestos)
                  FilaPresupuesto(
                    presupuesto: p,
                    textoDisponible: _t('pre_disponible'),
                    textoExcedido: _t('pre_excedido'),
                    onTap: () => _editar(p),
                    accion: IconButton(
                      tooltip: _t('ter_eliminar'),
                      icon: Icon(Icons.delete_outline_rounded,
                          color: tema.secondaryText),
                      onPressed: () => _eliminar(p),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
