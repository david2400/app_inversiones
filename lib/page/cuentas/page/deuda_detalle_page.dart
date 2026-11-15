import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/cuentas/dto/deuda_dto.dart';
import 'package:inversiones/page/cuentas/page/tipo_cuenta_ui.dart';
import 'package:inversiones/page/cuentas/states/deuda_detalle_page_state.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

/// Detalle de una tarjeta de crédito o un préstamo: cuánto se debe, cupo,
/// intereses, próximas fechas, compras a cuotas y tabla de amortización.
class DeudaDetallePage extends StatefulWidget {
  final int idCuenta;

  const DeudaDetallePage({super.key, required this.idCuenta});

  @override
  State<DeudaDetallePage> createState() => _DeudaDetallePageState();
}

class _DeudaDetallePageState extends State<DeudaDetallePage> {
  late DeudaDetallePageState _model;
  late Future<DetalleDeuda> _detalle;
  DetalleDeuda? _actual;

  static final _formatoFecha = DateFormat('dd/MM/yyyy');
  static const _filasAmortizacion = 12;
  static const _cifras = [FontFeature.tabularFigures()];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeudaDetallePageState());
    _detalle = _cargar();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  Future<DetalleDeuda> _cargar() async {
    final detalle = await _model.cargar(widget.idCuenta);
    // El título y las acciones dependen del tipo de deuda.
    if (mounted) {
      setState(() {
        _actual = detalle;
      });
    }
    return detalle;
  }

  Future<void> _recargar() async {
    final consulta = _cargar();
    if (!mounted) return;
    setState(() {
      _detalle = consulta;
    });
    try {
      await consulta;
    } catch (_) {}
  }

  /// Ejecuta [accion], muestra [mensajeExito] y recarga.
  Future<void> _ejecutar(Future<void> Function() accion, String mensajeExito) async {
    try {
      await accion();
      if (!mounted) return;
      mostrarMensaje(context, _t(mensajeExito));
      await _recargar();
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
  }

  Future<_DatosDeuda?> _pedir({
    required String titulo,
    required String ayuda,
    int? valorInicial,
    bool conValor = true,
    bool conCuenta = false,
    bool conCuotas = false,
  }) =>
      showDialog<_DatosDeuda>(
        context: context,
        builder: (_) => _DialogoDeuda(
          titulo: titulo,
          ayuda: ayuda,
          valorInicial: valorInicial,
          conValor: conValor,
          cuentas: conCuenta ? _actual?.cuentasParaPagar ?? const [] : null,
          conCuotas: conCuotas,
        ),
      );

  Future<void> _comprar() async {
    final datos = await _pedir(
        titulo: _t('deu_comprar'), ayuda: _t('deu_comprar_ayuda'), conCuotas: true);
    if (datos == null) return;
    await _ejecutar(
        () => _model.registrarCompra(widget.idCuenta, datos.valor!,
            cuotas: datos.cuotas, descripcion: datos.descripcion),
        'deu_compra_hecha');
  }

  Future<void> _pagar() async {
    final datos = await _pedir(
      titulo: _t('deu_pagar'),
      ayuda: _t('deu_pagar_ayuda'),
      valorInicial: _actual?.resumen.deuda,
      conCuenta: true,
    );
    if (datos == null) return;
    await _ejecutar(
        () => _model.pagar(widget.idCuenta, datos.idCuenta!, datos.valor!),
        'deu_pago_hecho');
  }

  Future<void> _intereses() async {
    final datos = await _pedir(
      titulo: _t('deu_intereses'),
      ayuda: _t('deu_intereses_ayuda'),
      valorInicial: _actual?.resumen.interesEstimado,
    );
    if (datos == null) return;
    await _ejecutar(() => _model.registrarIntereses(widget.idCuenta, datos.valor!),
        'deu_intereses_hecho');
  }

  Future<void> _pagarCuota() async {
    final cuota = _actual?.resumen.cuotaFija ?? 0;
    final datos = await _pedir(
      titulo: _t('deu_pagar_cuota'),
      ayuda: '${_t('deu_pagar_cuota_ayuda')} ${FormatoMoneda.cop(cuota)}',
      conValor: false,
      conCuenta: true,
    );
    if (datos == null) return;
    await _ejecutar(() => _model.pagarCuota(widget.idCuenta, datos.idCuenta!),
        'deu_pago_hecho');
  }

  Future<void> _verMovimientos() async {
    final principal = _actual?.idPortafolioPrincipal;
    if (principal == null) return;
    await context.pushNamed('transactions', queryParameters: {
      'idPortafolio': serializeParam(principal, ParamType.int),
    }.withoutNulls);
    await _recargar();
  }

  Future<void> _editar() async {
    final guardada = await context.pushNamed('admin_tarjeta', queryParameters: {
      'idCuenta': serializeParam(widget.idCuenta, ParamType.int),
    }.withoutNulls);
    if (guardada == true) await _recargar();
  }

  Future<void> _eliminar() async {
    final confirmado = await confirmarAccion(
      context,
      titulo: _t('deu_eliminar'),
      mensaje: _t('deu_eliminar_mensaje'),
      textoConfirmar: _t('deu_eliminar'),
      textoCancelar: _t('cta_cancelar'),
      destructiva: true,
    );
    if (!confirmado || !mounted) return;
    try {
      await _model.eliminar(widget.idCuenta);
      if (!mounted) return;
      mostrarMensaje(context, _t('deu_eliminada'));
      context.pop(true);
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esTarjeta =
        _actual?.resumen.tipoCuenta == TipoCuenta.tarjetaCredito;
    return PantallaBase(
      titulo: _actual?.resumen.nombre ?? _t('deu_titulo'),
      conMenu: false,
      acciones: [
        IconButton(
          tooltip: _t('cta_ver_movimientos'),
          icon: const Icon(Icons.receipt_long_rounded),
          onPressed: _verMovimientos,
        ),
        if (esTarjeta)
          IconButton(
            tooltip: _t('cta_editar'),
            icon: const Icon(Icons.edit_rounded),
            onPressed: _editar,
          ),
        IconButton(
          tooltip: _t('deu_eliminar'),
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: _eliminar,
        ),
      ],
      cuerpo: ContenidoAsincrono<DetalleDeuda>(
        future: _detalle,
        mensajeError: _t('cta_error'),
        textoReintentar: _t('cta_reintentar'),
        onReintentar: _recargar,
        builder: (context, detalle) => RefreshIndicator(
          onRefresh: _recargar,
          child: _contenido(detalle.resumen),
        ),
      ),
    );
  }

  Widget _contenido(ResumenDeudaDto r) {
    final tema = FlutterFlowTheme.of(context);
    final esTarjeta = r.tipoCuenta == TipoCuenta.tarjetaCredito;
    final c = r.condiciones;
    final cupo = c.cupo ?? 0;

    Widget dato(String etiqueta, String valor) => Padding(
          padding: const EdgeInsets.symmetric(vertical: Espacio.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(etiqueta,
                    style: tema.bodyMedium.copyWith(color: tema.secondaryText)),
              ),
              Text(valor,
                  style: tema.bodyMedium.copyWith(fontFeatures: _cifras)),
            ],
          ),
        );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: Espacio.pantalla,
      children: [
        Tarjeta(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(TipoCuentaUi.icono(r.tipoCuenta), color: tema.error),
                const SizedBox(width: Espacio.s),
                Text(TipoCuentaUi.nombre(context, r.tipoCuenta),
                    style: tema.labelMedium.copyWith(color: tema.secondaryText)),
              ]),
              const SizedBox(height: Espacio.m),
              Text(_t('deu_debes'),
                  style: tema.labelMedium.copyWith(color: tema.secondaryText)),
              Text(
                FormatoMoneda.cop(r.deuda),
                style: tema.displaySmall.copyWith(
                    color: r.deuda > 0 ? tema.error : tema.primaryText,
                    fontFeatures: _cifras),
              ),
              if (r.saldoAFavor > 0)
                Text('${_t('deu_saldo_favor')} ${FormatoMoneda.cop(r.saldoAFavor)}',
                    style: tema.bodySmall),
              if (esTarjeta && cupo > 0) ...[
                const SizedBox(height: Espacio.m),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Radios.s),
                  child: LinearProgressIndicator(
                    value: (r.deuda / cupo).clamp(0, 1).toDouble(),
                    minHeight: 8,
                    color: tema.error,
                    backgroundColor: tema.alternate,
                  ),
                ),
                const SizedBox(height: Espacio.xs),
                Text(
                  '${_t('deu_disponible')} ${FormatoMoneda.cop(r.disponible ?? 0)} '
                  '${_t('deu_de')} ${FormatoMoneda.cop(cupo)}',
                  style: tema.bodySmall.copyWith(color: tema.secondaryText),
                ),
              ],
              const SizedBox(height: Espacio.m),
              if (c.tasaMensual > 0)
                dato(_t('deu_tasa'),
                    '${c.tasaPorcentaje.toStringAsFixed(2).replaceAll('.', ',')} % E.M.'),
              if (r.interesEstimado > 0)
                dato(_t('deu_interes_estimado'), FormatoMoneda.cop(r.interesEstimado)),
              if (esTarjeta && (c.cuotaManejo ?? 0) > 0)
                dato(_t('deu_cuota_manejo'), FormatoMoneda.cop(c.cuotaManejo!)),
              if (esTarjeta && r.cuotasDelMes > 0)
                dato(_t('deu_cuotas_mes'), FormatoMoneda.cop(r.cuotasDelMes)),
              if (!esTarjeta && r.cuotaFija != null)
                dato(_t('deu_cuota_fija'), FormatoMoneda.cop(r.cuotaFija!)),
              if (!esTarjeta)
                dato(_t('deu_cuotas_restantes'), '${r.amortizacion.length}'),
              if (r.proximoCorte != null)
                dato(_t('deu_proximo_corte'), _formatoFecha.format(r.proximoCorte!)),
              if (r.proximoPago != null)
                dato(_t('deu_proximo_pago'), _formatoFecha.format(r.proximoPago!)),
            ],
          ),
        ),
        const SizedBox(height: Espacio.l),
        Wrap(
          spacing: Espacio.s,
          runSpacing: Espacio.s,
          children: [
            if (esTarjeta) ...[
              FilledButton.icon(
                onPressed: _comprar,
                icon: const Icon(Icons.shopping_cart_rounded),
                label: Text(_t('deu_comprar')),
              ),
              FilledButton.tonalIcon(
                onPressed: _pagar,
                icon: const Icon(Icons.payments_rounded),
                label: Text(_t('deu_pagar')),
              ),
              OutlinedButton.icon(
                onPressed: _intereses,
                icon: const Icon(Icons.percent_rounded),
                label: Text(_t('deu_intereses')),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: r.deuda > 0 ? _pagarCuota : null,
                icon: const Icon(Icons.event_available_rounded),
                label: Text(_t('deu_pagar_cuota')),
              ),
              OutlinedButton.icon(
                onPressed: r.deuda > 0 ? _pagar : null,
                icon: const Icon(Icons.savings_rounded),
                label: Text(_t('deu_abonar')),
              ),
            ],
          ],
        ),
        if (esTarjeta && r.comprasACuotas.isNotEmpty) ...[
          const SizedBox(height: Espacio.xl),
          EncabezadoSeccion(titulo: _t('deu_compras_cuotas')),
          const SizedBox(height: Espacio.s),
          Tarjeta(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (final compra in r.comprasACuotas)
                ListTile(
                  title: Text(
                      compra.descripcion.isEmpty
                          ? FormatoMoneda.cop(compra.valor)
                          : compra.descripcion,
                      style: tema.bodyLarge),
                  subtitle: Text(
                    '${_t('deu_cuota')} ${compra.cuotasPagadas} ${_t('deu_de')} '
                    '${compra.numeroCuotas} · ${FormatoMoneda.cop(compra.cuotaMensual)}',
                    style: tema.bodySmall.copyWith(color: tema.secondaryText),
                  ),
                  trailing: Text(FormatoMoneda.cop(compra.saldoPendiente),
                      style: tema.titleSmall.copyWith(fontFeatures: _cifras)),
                ),
            ]),
          ),
        ],
        if (!esTarjeta && r.amortizacion.isNotEmpty) ...[
          const SizedBox(height: Espacio.xl),
          EncabezadoSeccion(
            titulo: _t('deu_amortizacion'),
            subtitulo: _t('deu_amortizacion_ayuda'),
          ),
          const SizedBox(height: Espacio.s),
          Tarjeta(
            child: Column(children: [
              _FilaTabla(
                celdas: [
                  '#',
                  _t('deu_cuota'),
                  _t('deu_capital'),
                  _t('deu_interes'),
                  _t('deu_saldo'),
                ],
                encabezado: true,
              ),
              for (final fila in r.amortizacion.take(_filasAmortizacion))
                _FilaTabla(celdas: [
                  '${fila.numero}',
                  FormatoMoneda.compacto(fila.cuota),
                  FormatoMoneda.compacto(fila.capital),
                  FormatoMoneda.compacto(fila.interes),
                  FormatoMoneda.compacto(fila.saldo),
                ]),
            ]),
          ),
        ],
      ],
    );
  }
}

class _FilaTabla extends StatelessWidget {
  final List<String> celdas;
  final bool encabezado;

  const _FilaTabla({required this.celdas, this.encabezado = false});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final estilo = encabezado
        ? tema.labelSmall.copyWith(color: tema.secondaryText)
        : tema.bodySmall.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Espacio.xs),
      child: Row(children: [
        SizedBox(width: 28, child: Text(celdas.first, style: estilo)),
        for (final celda in celdas.skip(1))
          Expanded(child: Text(celda, style: estilo, textAlign: TextAlign.end)),
      ]),
    );
  }
}

/// Resultado de [_DialogoDeuda].
class _DatosDeuda {
  final int? valor;
  final int? idCuenta;
  final int cuotas;
  final String? descripcion;

  const _DatosDeuda(this.valor, this.idCuenta, this.cuotas, this.descripcion);
}

/// Diálogo de compra, pago, intereses o cuota. Es dueño de sus
/// controladores.
class _DialogoDeuda extends StatefulWidget {
  final String titulo;
  final String ayuda;
  final int? valorInicial;
  final bool conValor;
  final List<CuentaDto>? cuentas;
  final bool conCuotas;

  const _DialogoDeuda({
    required this.titulo,
    required this.ayuda,
    this.valorInicial,
    this.conValor = true,
    this.cuentas,
    this.conCuotas = false,
  });

  @override
  State<_DialogoDeuda> createState() => _DialogoDeudaState();
}

class _DialogoDeudaState extends State<_DialogoDeuda> {
  late final _valor = TextEditingController(
      text: (widget.valorInicial ?? 0) > 0 ? '${widget.valorInicial}' : '');
  final _cuotas = TextEditingController(text: '1');
  final _descripcion = TextEditingController();
  int? _idCuenta;
  String? _error;

  @override
  void dispose() {
    _valor.dispose();
    _cuotas.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  void _aceptar() {
    final valor = int.tryParse(_valor.text.trim());
    if (widget.conValor && (valor == null || valor <= 0)) {
      setState(() {
        _error = _t('deu_valor_requerido');
      });
      return;
    }
    if (widget.cuentas != null && _idCuenta == null) {
      setState(() {
        _error = _t('deu_cuenta_requerida');
      });
      return;
    }
    final cuotas = int.tryParse(_cuotas.text.trim()) ?? 1;
    Navigator.of(context).pop(_DatosDeuda(
        valor, _idCuenta, cuotas < 1 ? 1 : cuotas, _descripcion.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return AlertDialog(
      title: Text(widget.titulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.ayuda,
                style: tema.bodySmall.copyWith(color: tema.secondaryText)),
            if (widget.cuentas != null) ...[
              const SizedBox(height: Espacio.m),
              DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: InputDecoration(labelText: _t('deu_desde_cuenta')),
                items: [
                  for (final c in widget.cuentas!)
                    DropdownMenuItem(
                      value: c.idCuenta,
                      child: Text('${c.nombre} · ${FormatoMoneda.cop(c.saldo)}'),
                    ),
                ],
                onChanged: (v) => setState(() {
                  _idCuenta = v;
                }),
              ),
            ],
            if (widget.conValor) ...[
              const SizedBox(height: Espacio.m),
              TextField(
                controller: _valor,
                autofocus: widget.cuentas == null,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    labelText: _t('trx_valor'), prefixText: '\$ '),
              ),
            ],
            if (widget.conCuotas) ...[
              const SizedBox(height: Espacio.m),
              TextField(
                controller: _cuotas,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: _t('deu_numero_cuotas')),
              ),
              const SizedBox(height: Espacio.m),
              TextField(
                controller: _descripcion,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                    labelText: _t('form_descripcion'),
                    helperText: _t('form_opcional')),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: Espacio.s),
              Text(_error!, style: tema.bodySmall.copyWith(color: tema.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_t('cta_cancelar')),
        ),
        FilledButton(onPressed: _aceptar, child: Text(_t('trx_registrar_btn'))),
      ],
    );
  }
}
