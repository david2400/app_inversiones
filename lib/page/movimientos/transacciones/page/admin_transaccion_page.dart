import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

export 'package:inversiones/page/movimientos/transacciones/states/admin_transaccion_page_state.dart';
import 'package:inversiones/page/movimientos/transacciones/states/admin_transaccion_page_state.dart';

/// Registro de un movimiento. Los campos cambian según la naturaleza:
/// ingreso (¿a qué cuenta entra?, ¿quién pagó?), egreso (¿de qué cuenta
/// sale?, ¿a quién se pagó?) o transferencia (de la cuenta X → a la Y o a
/// una cuenta externa). Muestra el GMF y el saldo antes de guardar.
class AdminTransaccionPage extends StatefulWidget {
  final int? idPortafolio;

  const AdminTransaccionPage({super.key, this.idPortafolio});

  @override
  State<AdminTransaccionPage> createState() => _AdminTransaccionPageState();
}

class _AdminTransaccionPageState extends State<AdminTransaccionPage> {
  late AdminTransaccionPageState _model;
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminTransaccionPageState());
    _cargar();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      await _model.cargarCatalogos(widget.idPortafolio);
    } catch (e) {
      _mensaje(e);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  void _mensaje(Object texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(texto.toString().replaceFirst('Exception: ', ''))));
  }

  String _naturaleza(String tipoFuente) => _t(switch (tipoFuente) {
        TipoFuente.ingreso => 'frm_ingreso',
        TipoFuente.egreso => 'frm_egreso',
        _ => 'frm_transferencia',
      });

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _model.fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (elegida != null) setState(() => _model.fecha = elegida);
  }

  Future<void> _cambiarOrigen(int? id) async {
    setState(() {
      _model.portafolioId = id;
      if (_model.destinoId == id) _model.destinoId = null;
    });
    try {
      await _model.actualizarSaldo();
    } catch (e) {
      _mensaje(e);
    }
    if (mounted) setState(() {});
  }

  Future<void> _nuevoTercero() async {
    final controller = TextEditingController();
    final nombre = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t('ter_nuevo')),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: _t('ter_nombre')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(_t('mov_cancelar')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(_t('ter_guardar')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (nombre == null || nombre.trim().isEmpty) return;
    try {
      await _model.crearTercero(nombre);
      if (mounted) setState(() {});
    } catch (e) {
      _mensaje(e);
    }
  }

  Future<void> _guardar() async {
    final error = _model.validar();
    if (error != null) {
      _mensaje(_t(error));
      return;
    }
    setState(() => _guardando = true);
    try {
      await _model.guardar();
      if (!mounted) return;
      _mensaje(_t('frm_guardado'));
      context.pop(true);
    } catch (e) {
      _mensaje(e);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: tema.primaryBackground,
      appBar: AppBar(
        title: Text(_t('frm_titulo')),
        backgroundColor: tema.primaryBackground,
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: _campos(tema),
              ),
      ),
    );
  }

  List<Widget> _campos(FlutterFlowTheme tema) {
    final m = _model;
    const espacio = SizedBox(height: 16);
    return [
      _seleccion<int>(
        etiqueta: _t('frm_tipo'),
        valor: m.tipoId,
        opciones: {
          for (final t in m.tipos)
            t.idTipoTransaccion!: '${t.nombre} · ${_naturaleza(t.tipoFuente)}'
        },
        alCambiar: (id) => setState(() {
          m.tipoId = id;
          if (!m.admiteTercero) m.terceroId = null;
        }),
      ),
      espacio,
      TextField(
        controller: m.valorController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: tema.headlineSmall,
        decoration: InputDecoration(
          labelText: _t('frm_valor'),
          prefixText: '\$ ',
          helperText: m.valor > 0 ? FormatoMoneda.cop(m.valor) : null,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
      espacio,
      InkWell(
        onTap: _elegirFecha,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: _t('frm_fecha'),
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today_rounded),
          ),
          child: Text(DateFormat('dd/MM/yyyy').format(m.fecha)),
        ),
      ),
      espacio,
      _seleccion<int>(
        etiqueta: _t(m.esIngreso ? 'frm_cuenta_entra' : 'frm_cuenta_sale'),
        valor: m.portafolioId,
        opciones: {for (final p in m.portafolios) p.idPortafolio!: p.nombre},
        alCambiar: _cambiarOrigen,
      ),
      if (m.esTransferencia) ...[
        espacio,
        Text(_t('frm_hacia'), style: tema.bodyMedium),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text(_t('frm_mi_cuenta'))),
            ButtonSegment(value: true, label: Text(_t('frm_cuenta_externa'))),
          ],
          selected: {m.destinoExterno},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() {
            m.destinoExterno = s.first;
            if (!m.admiteTercero) m.terceroId = null;
          }),
        ),
        const SizedBox(height: 12),
        if (m.destinoExterno)
          TextField(
            controller: m.cuentaExternaController,
            decoration: InputDecoration(
              labelText: _t('frm_cuenta_externa_dato'),
              border: const OutlineInputBorder(),
            ),
          )
        else
          _seleccion<int>(
            etiqueta: _t('frm_cuenta_destino'),
            valor: m.destinoId,
            opciones: {
              for (final p in m.destinosPosibles) p.idPortafolio!: p.nombre
            },
            alCambiar: (id) => setState(() => m.destinoId = id),
          ),
      ],
      if (m.admiteTercero) ...[
        espacio,
        Row(
          children: [
            Expanded(
              child: _seleccion<int>(
                etiqueta: _t(m.esIngreso ? 'frm_quien_pago' : 'frm_a_quien'),
                valor: m.terceroId,
                opcional: true,
                opciones: {for (final t in m.terceros) t.idTercero!: t.nombre},
                alCambiar: (id) => setState(() => m.terceroId = id),
              ),
            ),
            IconButton(
              tooltip: _t('ter_nuevo'),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              onPressed: _nuevoTercero,
            ),
          ],
        ),
      ],
      espacio,
      _seleccion<int>(
        etiqueta: _t('frm_motivo'),
        valor: m.motivoId,
        opcional: true,
        opciones: {for (final mo in m.motivos) mo.idMotivo!: mo.nombre},
        alCambiar: (id) => setState(() => m.motivoId = id),
      ),
      espacio,
      TextField(
        controller: m.descripcionController,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: _t('frm_descripcion'),
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 24),
      if (m.naturaleza != null && m.portafolioId != null) _vistaPrevia(tema),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: _guardando ? null : _guardar,
        icon: _guardando
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.check_rounded),
        label: Text(_t('frm_guardar')),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
    ];
  }

  /// Resumen antes de guardar: valor, GMF, total y saldo antes/después.
  Widget _vistaPrevia(FlutterFlowTheme tema) {
    final m = _model;
    Widget fila(String etiqueta, String valor, {Color? color, bool fuerte = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: Text(etiqueta,
                    style: tema.bodyMedium.copyWith(color: tema.secondaryText)),
              ),
              Text(valor,
                  style: (fuerte ? tema.titleSmall : tema.bodyMedium)
                      .copyWith(color: color ?? tema.primaryText)),
            ],
          ),
        );

    final saldoDespues = m.saldoDespues;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tema.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tema.alternate),
      ),
      child: Column(
        children: [
          fila(_t('frm_valor'), FormatoMoneda.cop(m.valor)),
          if (m.debita) ...[
            fila(_t('frm_gmf'), FormatoMoneda.cop(m.gmf)),
            fila(_t('frm_total_debitado'), FormatoMoneda.cop(m.totalDebitado),
                fuerte: true, color: ColoresFinanzas.egresos),
          ],
          Divider(color: tema.alternate),
          if (m.saldoOrigen != null)
            fila(_t('frm_saldo_actual'), FormatoMoneda.cop(m.saldoOrigen!)),
          if (saldoDespues != null)
            fila(_t('frm_saldo_despues'), FormatoMoneda.cop(saldoDespues),
                fuerte: true,
                color: saldoDespues < 0 ? tema.error : tema.primaryText),
          if (saldoDespues != null && saldoDespues < 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_t('frm_saldo_insuficiente'),
                  style: tema.bodySmall.copyWith(color: tema.error)),
            ),
        ],
      ),
    );
  }

  /// Lista desplegable con etiqueta. Si es [opcional] incluye "Ninguno".
  Widget _seleccion<T>({
    required String etiqueta,
    required T? valor,
    required Map<T, String> opciones,
    required ValueChanged<T?> alCambiar,
    bool opcional = false,
  }) {
    final valorValido = opciones.containsKey(valor) ? valor : null;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: etiqueta,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: valorValido,
          isExpanded: true,
          hint: Text(opcional ? _t('frm_ninguno') : _t('frm_seleccione')),
          items: [
            if (opcional)
              DropdownMenuItem<T>(
                  value: null, child: Text(_t('frm_ninguno'))),
            for (final opcion in opciones.entries)
              DropdownMenuItem<T>(
                value: opcion.key,
                child: Text(opcion.value, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: alCambiar,
        ),
      ),
    );
  }
}
