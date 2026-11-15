import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inversiones/domain/models/periodicidad.dart';
import 'package:inversiones/page/recurrentes/dto/recurrente_dto.dart';
import 'package:inversiones/page/recurrentes/states/recurrentes_page_state.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/drawer_widget.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

/// Movimientos fijos mensuales: estado del mes, registrar, editar y pausar.
class RecurrentesPage extends StatefulWidget {
  const RecurrentesPage({super.key});

  @override
  State<RecurrentesPage> createState() => _RecurrentesPageState();
}

class _RecurrentesPageState extends State<RecurrentesPage> {
  late RecurrentesPageState _model;
  late Future<List<RecurrenteDto>> _fijos;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RecurrentesPageState());
    _fijos = _model.listar();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  void _recargar() => setState(() {
        _fijos = _model.listar();
      });

  void _mensaje(Object texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(texto.toString().replaceFirst('Exception: ', ''))));
  }

  Future<void> _ejecutar(Future<void> Function() accion, [String? exito]) async {
    try {
      await accion();
      if (exito != null) _mensaje(_t(exito));
      _recargar();
    } catch (e) {
      _mensaje(e);
    }
  }

  Future<void> _editar(RecurrenteDto fijo) async {
    final cambios = await showDialog<_CambiosFijo>(
      context: context,
      builder: (_) => _DialogoEditarFijo(fijo: fijo),
    );
    if (cambios == null) return;
    await _ejecutar(() => _model.actualizar(fijo.idRecurrente,
        nombre: cambios.nombre,
        valor: cambios.valor,
        diaMes: cambios.diaMes,
        periodoMeses: cambios.periodoMeses));
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('fij_titulo')),
        backgroundColor: tema.primaryBackground,
      ),
      drawer: const DrawerWidget(),
      backgroundColor: tema.primaryBackground,
      body: SafeArea(
        child: FutureBuilder<List<RecurrenteDto>>(
          future: _fijos,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(_t('dash_error')));
            }
            final fijos = snapshot.data ?? [];
            if (fijos.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_t('fij_vacio'),
                      textAlign: TextAlign.center, style: tema.bodyMedium),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: fijos.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: tema.alternate),
              itemBuilder: (context, i) => FilaRecurrente(
                fijo: fijos[i],
                textoRegistrado: _t('fij_registrado'),
                textoPendiente: _t('fij_pendiente'),
                textoPausado: _t('fij_pausado'),
                textoRegistrar: _t('fij_registrar'),
                textoProximo: _t('fij_proximo'),
                textoPeriodo: fijos[i].periodoMeses > Periodicidad.mensual
                    ? _t(Periodicidad.clave(fijos[i].periodoMeses))
                    : null,
                onRegistrar: () => _ejecutar(
                    () => _model.registrar(fijos[i].idRecurrente),
                    'frm_guardado'),
                onTap: () => _editar(fijos[i]),
                menu: PopupMenuButton<String>(
                  onSelected: (opcion) => switch (opcion) {
                    'pausar' => _ejecutar(() => _model.actualizar(
                        fijos[i].idRecurrente,
                        activo: !fijos[i].activo)),
                    _ => _ejecutar(
                        () => _model.eliminar(fijos[i].idRecurrente)),
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'pausar',
                        child: Text(_t(fijos[i].activo
                            ? 'fij_pausar'
                            : 'fij_reactivar'))),
                    PopupMenuItem(
                        value: 'eliminar', child: Text(_t('ter_eliminar'))),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Resultado de [_DialogoEditarFijo].
class _CambiosFijo {
  final String? nombre;
  final int? valor;
  final int? diaMes;
  final int periodoMeses;

  const _CambiosFijo(this.nombre, this.valor, this.diaMes, this.periodoMeses);
}

/// Edita nombre, valor, día y periodo de un fijo. Es dueño de sus
/// controladores. El nombre de un aporte programado lo define su
/// portafolio, por eso no se edita aquí.
class _DialogoEditarFijo extends StatefulWidget {
  final RecurrenteDto fijo;

  const _DialogoEditarFijo({required this.fijo});

  @override
  State<_DialogoEditarFijo> createState() => _DialogoEditarFijoState();
}

class _DialogoEditarFijoState extends State<_DialogoEditarFijo> {
  late final _nombre = TextEditingController(text: widget.fijo.nombre);
  late final _valor = TextEditingController(text: '${widget.fijo.valor}');
  late final _dia = TextEditingController(text: '${widget.fijo.diaMes}');
  late int _periodo = Periodicidad.esRepetible(widget.fijo.periodoMeses)
      ? widget.fijo.periodoMeses
      : Periodicidad.mensual;

  @override
  void dispose() {
    _nombre.dispose();
    _valor.dispose();
    _dia.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  @override
  Widget build(BuildContext context) {
    final esAporte = widget.fijo.esAporte;
    return AlertDialog(
      title: Text(_t('fij_editar')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombre,
              enabled: !esAporte,
              decoration: InputDecoration(
                labelText: _t('frm_nombre_fijo'),
                helperText: esAporte ? _t('fij_nombre_aporte') : null,
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valor,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                  labelText: _t('frm_valor'), prefixText: '\$ '),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _periodo,
              isExpanded: true,
              decoration: InputDecoration(labelText: _t('aport_cada')),
              items: [
                for (final meses in Periodicidad.repetibles)
                  DropdownMenuItem(
                      value: meses, child: Text(_t(Periodicidad.clave(meses)))),
              ],
              onChanged: (valor) => setState(() {
                _periodo = valor ?? Periodicidad.mensual;
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dia,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: _t('fij_dia')),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_t('mov_cancelar')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_CambiosFijo(
            esAporte ? null : _nombre.text,
            int.tryParse(_valor.text),
            int.tryParse(_dia.text),
            _periodo,
          )),
          child: Text(_t('ter_guardar')),
        ),
      ],
    );
  }
}
