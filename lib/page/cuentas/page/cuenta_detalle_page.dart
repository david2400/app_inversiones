import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/page/cuentas/page/tipo_cuenta_ui.dart';
import 'package:inversiones/page/cuentas/states/cuenta_detalle_page_state.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

/// Detalle de una cuenta: saldo, datos y sus portafolios (principal,
/// cajitas, bolsillos, CDTs).
class CuentaDetallePage extends StatefulWidget {
  final int idCuenta;

  const CuentaDetallePage({super.key, required this.idCuenta});

  @override
  State<CuentaDetallePage> createState() => _CuentaDetallePageState();
}

class _CuentaDetallePageState extends State<CuentaDetallePage> {
  late CuentaDetallePageState _model;
  late Future<DetalleCuenta> _detalle;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CuentaDetallePageState());
    _detalle = _model.cargar(widget.idCuenta);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  bool get _esEfectivo => widget.idCuenta == CuentaSchema.idEfectivo;

  Future<void> _recargar() async {
    final consulta = _model.cargar(widget.idCuenta);
    if (!mounted) return;
    setState(() {
      _detalle = consulta;
    });
    try {
      await consulta;
    } catch (_) {}
  }

  Future<void> _editar() async {
    final guardada = await context.pushNamed(
      'admin_cuenta',
      queryParameters: {
        'idCuenta': serializeParam(widget.idCuenta, ParamType.int),
      }.withoutNulls,
    );
    if (guardada == true) await _recargar();
  }

  Future<void> _eliminar() async {
    final confirmado = await confirmarAccion(
      context,
      titulo: _t('cta_eliminar'),
      mensaje: _t('cta_eliminar_mensaje'),
      textoConfirmar: _t('cta_eliminar'),
      textoCancelar: _t('cta_cancelar'),
      destructiva: true,
    );
    if (!confirmado || !mounted) return;
    try {
      await _model.eliminar(widget.idCuenta);
      if (!mounted) return;
      mostrarMensaje(context, _t('cta_eliminada'));
      context.pop(true);
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
  }

  Future<void> _nuevaCajita() async {
    final creada = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoCajita(
        onCrear: (nombre, saldo) =>
            _model.crearCajita(widget.idCuenta, nombre, saldo),
      ),
    );
    if (creada == true) {
      if (mounted) mostrarMensaje(context, _t('cta_cajita_creada'));
      await _recargar();
    }
  }

  Future<void> _verMovimientos(PortafolioDto portafolio) async {
    await context.pushNamed(
      'transactions',
      queryParameters: {
        'idPortafolio':
            serializeParam(portafolio.idPortafolio, ParamType.int),
      }.withoutNulls,
    );
    await _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: _t('cta_titulo'),
      conMenu: false,
      acciones: [
        IconButton(
          tooltip: _t('cta_editar'),
          icon: const Icon(Icons.edit_rounded),
          onPressed: _editar,
        ),
        if (!_esEfectivo)
          IconButton(
            tooltip: _t('cta_eliminar'),
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _eliminar,
          ),
      ],
      botonFlotante: FloatingActionButton.extended(
        onPressed: _nuevaCajita,
        icon: const Icon(Icons.add_rounded),
        label: Text(_t('cta_nueva_cajita')),
      ),
      cuerpo: ContenidoAsincrono<DetalleCuenta>(
        future: _detalle,
        mensajeError: _t('cta_error'),
        textoReintentar: _t('cta_reintentar'),
        onReintentar: _recargar,
        builder: (context, detalle) => RefreshIndicator(
          onRefresh: _recargar,
          child: _ContenidoDetalle(
            detalle: detalle,
            esEfectivo: _esEfectivo,
            onAbrirPortafolio: _verMovimientos,
          ),
        ),
      ),
    );
  }
}

class _ContenidoDetalle extends StatelessWidget {
  final DetalleCuenta detalle;
  final bool esEfectivo;
  final ValueChanged<PortafolioDto> onAbrirPortafolio;

  const _ContenidoDetalle({
    required this.detalle,
    required this.esEfectivo,
    required this.onAbrirPortafolio,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final cuenta = detalle.cuenta;
    final datos = [
      TipoCuentaUi.nombre(context, cuenta.tipoCuenta),
      if (cuenta.entidad != null) cuenta.entidad!,
      if (cuenta.nroCuenta != null) cuenta.nroCuenta!,
    ].join(' · ');
    final paga = cuenta.exentaImpuesto != 'S' && !esEfectivo;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          Espacio.l, Espacio.s, Espacio.l, Espacio.xxl * 3),
      children: [
        Tarjeta(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(TipoCuentaUi.icono(cuenta.tipoCuenta),
                      color: tema.primary),
                  const SizedBox(width: Espacio.s),
                  Expanded(
                    child: Text(cuenta.nombre, style: tema.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: Espacio.m),
              Text(
                FormatoMoneda.cop(cuenta.saldo),
                style: tema.displaySmall.copyWith(
                    color: cuenta.saldo < 0 ? tema.error : tema.primaryText),
              ),
              const SizedBox(height: Espacio.s),
              Text(datos,
                  style: tema.bodyMedium.copyWith(color: tema.secondaryText)),
              const SizedBox(height: Espacio.s),
              Row(
                children: [
                  Icon(
                    paga
                        ? Icons.receipt_long_rounded
                        : Icons.verified_rounded,
                    size: 16,
                    color: tema.secondaryText,
                  ),
                  const SizedBox(width: Espacio.xs),
                  Text(
                    textos.getText(paga ? 'cta_paga_gmf' : 'cta_exenta_gmf'),
                    style: tema.bodySmall.copyWith(color: tema.secondaryText),
                  ),
                ],
              ),
              if (esEfectivo) ...[
                const SizedBox(height: Espacio.s),
                Text(textos.getText('cta_efectivo_info'),
                    style: tema.bodySmall.copyWith(color: tema.secondaryText)),
              ],
            ],
          ),
        ),
        const SizedBox(height: Espacio.xl),
        EncabezadoSeccion(
          titulo: textos.getText('cta_portafolios'),
          subtitulo: textos.getText('cta_portafolios_ayuda'),
        ),
        const SizedBox(height: Espacio.s),
        Tarjeta(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < detalle.portafolios.length; i++) ...[
                if (i > 0) Divider(height: 1, color: tema.alternate),
                _FilaPortafolio(
                  portafolio: detalle.portafolios[i],
                  saldo: detalle.saldos[detalle.portafolios[i].idPortafolio] ??
                      0,
                  onTap: () => onAbrirPortafolio(detalle.portafolios[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FilaPortafolio extends StatelessWidget {
  final PortafolioDto portafolio;
  final int saldo;
  final VoidCallback onTap;

  const _FilaPortafolio(
      {required this.portafolio, required this.saldo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    return ListTile(
      onTap: onTap,
      minVerticalPadding: Espacio.m,
      leading: Icon(
        portafolio.esPrincipal
            ? Icons.account_balance_wallet_rounded
            : Icons.savings_outlined,
        color: tema.secondaryText,
      ),
      title: Text(portafolio.nombre, style: tema.bodyLarge),
      subtitle: Text(
        portafolio.esPrincipal
            ? textos.getText('cta_principal')
            : textos.getText('cta_ver_movimientos'),
        style: tema.bodySmall.copyWith(color: tema.secondaryText),
      ),
      trailing: Text(
        FormatoMoneda.cop(saldo),
        style: tema.titleSmall.copyWith(
          color: saldo < 0 ? tema.error : tema.primaryText,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Diálogo para crear una cajita, bolsillo o CDT en la cuenta. Es dueño de
/// sus controladores y los libera al cerrarse.
class _DialogoCajita extends StatefulWidget {
  final Future<void> Function(String nombre, int saldoInicial) onCrear;

  const _DialogoCajita({required this.onCrear});

  @override
  State<_DialogoCajita> createState() => _DialogoCajitaState();
}

class _DialogoCajitaState extends State<_DialogoCajita> {
  final _nombre = TextEditingController();
  final _saldo = TextEditingController();
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _saldo.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  Future<void> _crear() async {
    if (_guardando) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      final saldo = _saldo.text.trim();
      await widget.onCrear(_nombre.text, saldo.isEmpty ? 0 : int.parse(saldo));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return AlertDialog(
      title: Text(_t('cta_nueva_cajita')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_t('cta_cajita_ayuda'),
              style: tema.bodySmall.copyWith(color: tema.secondaryText)),
          const SizedBox(height: Espacio.m),
          TextField(
            controller: _nombre,
            autofocus: true,
            enabled: !_guardando,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: _t('form_nombre'),
              errorText: _error,
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: Espacio.m),
          TextField(
            controller: _saldo,
            enabled: !_guardando,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _crear(),
            decoration: InputDecoration(
              labelText: _t('cta_saldo_inicial'),
              helperText: _t('form_opcional'),
              prefixText: '\$ ',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: Text(_t('cta_cancelar')),
        ),
        FilledButton(
          onPressed: _guardando ? null : _crear,
          child: _guardando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_t('cta_crear')),
        ),
      ],
    );
  }
}
