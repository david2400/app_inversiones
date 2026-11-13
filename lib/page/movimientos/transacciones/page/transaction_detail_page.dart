import 'package:flutter/material.dart';
import 'package:inversiones/domain/consultas/transacciones_details_dto.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';

import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

export 'package:inversiones/page/movimientos/transacciones/states/transaction_detail_page_state.dart';
import 'package:inversiones/page/movimientos/transacciones/states/transaction_detail_page_state.dart';

/// Detalle de un movimiento: monto protagonista, recorrido del dinero
/// (desde → hacia), datos de clasificación y la acción de anular.
class TransactionDetailPage extends StatefulWidget {
  final int idTransaccion;

  const TransactionDetailPage({
    super.key,
    required this.idTransaccion,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late TransactionDetailPageState _model;
  late Future<TransaccionDetailsDto> _transaccion;
  bool _anulando = false;

  static const _sinDato = '—';
  static final _formatoFecha = DateFormat('dd/MM/yyyy  HH:mm');
  static const _cifrasTabulares = [FontFeature.tabularFigures()];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TransactionDetailPageState());
    _transaccion = _cargar();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<TransaccionDetailsDto> _cargar() =>
      _model.findTransaccionDetails(widget.idTransaccion);

  void _recargar() => setState(() {
        _transaccion = _cargar();
      });

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  String _fecha(String? valor) {
    if (valor == null || valor.isEmpty) return _sinDato;
    final fecha = DateTime.tryParse(valor);
    return fecha == null ? valor : _formatoFecha.format(fecha);
  }

  Future<void> _anular() async {
    final t = FFLocalizations.of(context);
    final confirmado = await confirmarAccion(
      context,
      titulo: t.getText('mov_anular_titulo'),
      mensaje: t.getText('mov_anular_mensaje'),
      textoConfirmar: t.getText('mov_anular'),
      textoCancelar: t.getText('mov_cancelar'),
      destructiva: true,
    );
    if (!confirmado || !mounted) return;

    setState(() => _anulando = true);
    try {
      await _model.anularTransaccion(widget.idTransaccion);
      if (!mounted) return;
      mostrarMensaje(context, t.getText('mov_anulado'));
      // `true` le indica a la lista que debe recargar saldos y movimientos.
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _anulando = false);
      mostrarMensaje(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: _t('jjj3ydb1' /* Detalle de transaccion */),
      conMenu: false,
      cuerpo: ContenidoAsincrono<TransaccionDetailsDto>(
        future: _transaccion,
        mensajeError: _t('det_error'),
        textoReintentar: _t('det_reintentar'),
        onReintentar: _recargar,
        builder: (context, transaccion) => _contenido(transaccion),
      ),
    );
  }

  Widget _contenido(TransaccionDetailsDto tx) {
    return ListView(
      padding: Espacio.pantalla,
      children: [
        _resumen(tx),
        EncabezadoSeccion(titulo: _t('det_recorrido')),
        Tarjeta(child: _recorrido(tx)),
        EncabezadoSeccion(titulo: _t('det_detalles')),
        Tarjeta(
          padding: const EdgeInsets.symmetric(horizontal: Espacio.l),
          child: Column(children: _filasDetalle(tx)),
        ),
        const SizedBox(height: Espacio.xxl),
        _zonaAnular(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Monto protagonista
  // ---------------------------------------------------------------------------

  Widget _resumen(TransaccionDetailsDto tx) {
    final tema = FlutterFlowTheme.of(context);
    final estilo = _EstiloNaturaleza.de(tx.naturaleza, tema);
    final etiqueta = estilo.claveEtiqueta == null
        ? tx.tipoTransferencia
        : _t(estilo.claveEtiqueta!);
    final monto = estilo.signo.isEmpty
        ? FormatoMoneda.cop(tx.valor)
        : '${estilo.signo} ${FormatoMoneda.cop(tx.valor)}';

    return Tarjeta(
      padding: const EdgeInsets.all(Espacio.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Naturaleza con ícono + texto (nunca solo color).
          Row(children: [
            Icon(estilo.icono, size: 20, color: estilo.colorIcono),
            const SizedBox(width: Espacio.s),
            Text(etiqueta,
                style: tema.labelLarge.copyWith(color: estilo.colorIcono)),
          ]),
          const SizedBox(height: Espacio.l),
          Text(_t('det_valor'),
              style: tema.bodySmall.copyWith(color: tema.secondaryText)),
          const SizedBox(height: Espacio.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              monto,
              style: tema.displaySmall.copyWith(
                color: estilo.colorMonto,
                fontFeatures: _cifrasTabulares,
              ),
            ),
          ),
          const SizedBox(height: Espacio.s),
          Text(
            '${tx.tipoTransferencia}  ·  ${_fecha(tx.createdAt)}',
            style: tema.bodyMedium.copyWith(color: tema.secondaryText),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // De dónde → a dónde
  // ---------------------------------------------------------------------------

  Widget _recorrido(TransaccionDetailsDto tx) {
    final tema = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PuntoRecorrido(
          icono: _iconoDesde(tx),
          etiqueta: _t('det_desde'),
          valor: tx.desde ?? _sinDato,
        ),
        Padding(
          // Centra la flecha bajo los íconos de 40 px.
          padding: const EdgeInsetsDirectional.only(
              start: Espacio.s, top: Espacio.xs, bottom: Espacio.xs),
          child: Icon(Icons.arrow_downward_rounded,
              size: 24, color: tema.secondaryText),
        ),
        _PuntoRecorrido(
          icono: _iconoHacia(tx),
          etiqueta: _t('det_hacia'),
          valor: tx.hacia ?? _sinDato,
        ),
      ],
    );
  }

  static const _iconoCuenta = Icons.account_balance_wallet_rounded;
  static const _iconoTercero = Icons.person_rounded;
  static const _iconoExterna = Icons.account_balance_rounded;
  static const _iconoMotivo = Icons.label_rounded;

  IconData _iconoDesde(TransaccionDetailsDto tx) {
    if (!tx.esIngreso) return _iconoCuenta;
    return tx.tercero != null ? _iconoTercero : _iconoMotivo;
  }

  IconData _iconoHacia(TransaccionDetailsDto tx) {
    if (tx.esIngreso || tx.destinoCuenta != null) return _iconoCuenta;
    if (tx.tercero != null) return _iconoTercero;
    if (tx.destinoAlternativo != null) return _iconoExterna;
    return _iconoMotivo;
  }

  // ---------------------------------------------------------------------------
  // Detalles
  // ---------------------------------------------------------------------------

  List<Widget> _filasDetalle(TransaccionDetailsDto tx) {
    bool conTexto(String? v) => v != null && v.trim().isNotEmpty;
    final impuesto = tx.impuesto ?? 0;

    final filas = <Widget>[
      _FilaDato(etiqueta: _t('det_tipo'), valor: tx.tipoTransferencia),
      if (conTexto(tx.motivo))
        _FilaDato(etiqueta: _t('det_motivo'), valor: tx.motivo!),
      _FilaDato(etiqueta: _t('det_fecha'), valor: _fecha(tx.createdAt)),
      if (conTexto(tx.tercero))
        _FilaDato(etiqueta: _t('det_tercero'), valor: tx.tercero!),
      // La cuenta externa solo se repite aquí si no es ya el "hacia".
      if (conTexto(tx.destinoAlternativo) && tx.hacia != tx.destinoAlternativo)
        _FilaDato(
            etiqueta: _t('det_cuenta_externa'), valor: tx.destinoAlternativo!),
      if (conTexto(tx.descripcion))
        _FilaDato(etiqueta: _t('det_descripcion'), valor: tx.descripcion!),
      if (impuesto > 0) ...[
        _FilaDato(
            etiqueta: _t('det_valor'),
            valor: FormatoMoneda.cop(tx.valor),
            esMonto: true),
        _FilaDato(
            etiqueta: _t('det_gmf'),
            valor: FormatoMoneda.cop(impuesto),
            esMonto: true),
        _FilaDato(
            etiqueta: _t('det_total_debitado'),
            valor: FormatoMoneda.cop(tx.valor + impuesto),
            esMonto: true,
            destacado: true),
      ],
    ];

    return [
      for (var i = 0; i < filas.length; i++) ...[
        if (i > 0) const Divider(height: 1),
        filas[i],
      ],
    ];
  }

  // ---------------------------------------------------------------------------
  // Anular
  // ---------------------------------------------------------------------------

  Widget _zonaAnular() {
    final tema = FlutterFlowTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _anulando ? null : _anular,
          style: OutlinedButton.styleFrom(
            foregroundColor: tema.error,
            side: BorderSide(color: tema.error),
            minimumSize: const Size.fromHeight(altoMinimoTactil),
          ),
          icon: _anulando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.delete_outline_rounded),
          label: Text(_t('det_anular_movimiento')),
        ),
        const SizedBox(height: Espacio.s),
        Text(
          _t('det_anular_ayuda'),
          textAlign: TextAlign.center,
          style: tema.bodySmall.copyWith(color: tema.secondaryText),
        ),
      ],
    );
  }
}

/// Ícono, signo y colores según la naturaleza del movimiento.
class _EstiloNaturaleza {
  final IconData icono;
  final Color colorIcono;
  final Color colorMonto;
  final String signo;
  final String? claveEtiqueta;

  const _EstiloNaturaleza({
    required this.icono,
    required this.colorIcono,
    required this.colorMonto,
    required this.signo,
    this.claveEtiqueta,
  });

  factory _EstiloNaturaleza.de(String? naturaleza, FlutterFlowTheme tema) {
    switch (naturaleza) {
      case TipoFuente.ingreso:
        return const _EstiloNaturaleza(
          icono: Icons.south_west_rounded,
          colorIcono: ColoresFinanzas.ingresos,
          colorMonto: ColoresFinanzas.ingresos,
          signo: '+',
          claveEtiqueta: 'frm_ingreso',
        );
      case TipoFuente.egreso:
        return const _EstiloNaturaleza(
          icono: Icons.north_east_rounded,
          colorIcono: ColoresFinanzas.egresos,
          colorMonto: ColoresFinanzas.egresos,
          signo: '−',
          claveEtiqueta: 'frm_egreso',
        );
      case TipoFuente.transferencia:
        return _EstiloNaturaleza(
          icono: Icons.swap_horiz_rounded,
          colorIcono: tema.secondaryText,
          colorMonto: tema.primaryText,
          signo: '',
          claveEtiqueta: 'frm_transferencia',
        );
      default:
        // Naturaleza desconocida: se muestra el nombre del tipo, sin signo.
        return _EstiloNaturaleza(
          icono: Icons.receipt_long_rounded,
          colorIcono: tema.secondaryText,
          colorMonto: tema.primaryText,
          signo: '',
        );
    }
  }
}

/// Un extremo del recorrido: ícono, etiqueta ("Desde"/"Hacia") y nombre.
class _PuntoRecorrido extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _PuntoRecorrido({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tema.accent4,
            borderRadius: BorderRadius.circular(Radios.s),
          ),
          child: Icon(icono, size: 20, color: tema.primaryText),
        ),
        const SizedBox(width: Espacio.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta,
                  style: tema.bodySmall.copyWith(color: tema.secondaryText)),
              Text(valor, style: tema.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fila etiqueta / valor de la tarjeta de detalles (mínimo 48 px de alto).
class _FilaDato extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool esMonto;
  final bool destacado;

  const _FilaDato({
    required this.etiqueta,
    required this.valor,
    this.esMonto = false,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final base = destacado ? tema.titleSmall : tema.bodyMedium;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: altoMinimoTactil),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Espacio.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(etiqueta,
                style: tema.bodyMedium.copyWith(color: tema.secondaryText)),
            const SizedBox(width: Espacio.l),
            Expanded(
              child: Text(
                valor,
                textAlign: TextAlign.end,
                style: esMonto
                    ? base.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()])
                    : base,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
