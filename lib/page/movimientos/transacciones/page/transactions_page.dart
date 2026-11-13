import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inversiones/domain/consultas/transaccion_portafolio_dto.dart';
import 'package:inversiones/domain/models/filtro_movimientos.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/page/cuentas/page/tipo_cuenta_ui.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

export 'package:inversiones/page/movimientos/transacciones/states/transactions_page_state.dart';
import 'package:inversiones/page/movimientos/transacciones/states/transactions_page_state.dart';

/// Movimientos de una cuenta (portafolio): saldo protagonista, ingresos y
/// salidas, y la lista de movimientos con su recorrido y monto con signo.
class TransactionsPage extends StatefulWidget {
  /// Proyecto del portafolio; nulo si el portafolio es de una cuenta.
  final int? idProyecto;
  final int idPortafolio;

  const TransactionsPage(
      {super.key, this.idProyecto, required this.idPortafolio});

  @override
  State<TransactionsPage> createState() => _TransactionsWidgetState();
}

/// Lista de movimientos y totales de la cuenta, cargados juntos.
class _DatosCuenta {
  final List<TransaccionPortafolioDto> movimientos;
  final TotalesDto totales;

  const _DatosCuenta({required this.movimientos, required this.totales});
}

class _TransactionsWidgetState extends State<TransactionsPage> {
  late TransactionsPageState _model;
  late Future<_DatosCuenta> _datos;

  /// Datos del portafolio (para saber qué acciones ofrecer).
  PortafolioDto? _portafolio;

  static final _formatoFecha = DateFormat('dd/MM/yyyy');
  static const _cifrasTabulares = [FontFeature.tabularFigures()];
  static const _transicionFormulario = TransitionInfo(
    hasTransition: true,
    transitionType: PageTransitionType.bottomToTop,
    duration: Duration(milliseconds: 220),
  );

  /// Espacio inferior para que el botón flotante no tape la última fila.
  static const _espacioBotonFlotante = 88.0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TransactionsPageState());
    _datos = _cargar();
    _cargarPortafolio();
  }

  Future<void> _cargarPortafolio() async {
    try {
      final portafolio = await _model.obtenerPortafolio(widget.idPortafolio);
      if (!mounted) return;
      setState(() {
        _portafolio = portafolio;
      });
    } catch (_) {
      // Sin estos datos solo se ocultan las acciones extra.
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  /// Movimientos y totales del portafolio (los totales los calcula el
  /// handler e incluyen GMF y transferencias entrantes/salientes).
  Future<_DatosCuenta> _cargar() async {
    final resultados = await Future.wait<Object>([
      _model.listaTransaccionByPortafolioId(widget.idPortafolio),
      _model.resumenPortafolio(widget.idPortafolio),
    ]);
    return _DatosCuenta(
      movimientos: resultados[0] as List<TransaccionPortafolioDto>,
      totales: resultados[1] as TotalesDto,
    );
  }

  /// Recarga mostrando el indicador de carga (desde el estado de error).
  void _recargar() => setState(() {
        _datos = _cargar();
      });

  /// Recarga en segundo plano: conserva los datos en pantalla hasta que
  /// llegan los nuevos (al volver del formulario, del detalle o del ajuste).
  Future<void> _recargarSilencioso() async {
    final nuevos = _cargar();
    try {
      await nuevos;
    } catch (_) {
      if (!mounted) return;
      mostrarMensaje(context, _t('trx_error'));
      return;
    }
    if (!mounted) return;
    setState(() {
      _datos = nuevos;
    });
  }

  // ---------------------------------------------------------------------------
  // Navegación
  // ---------------------------------------------------------------------------

  Future<void> _nuevoMovimiento() async {
    await context.pushNamed(
      'admin_transactions',
      queryParameters: {
        'idPortafolio':
            serializeParam(widget.idPortafolio, ParamType.int, isList: false),
      }.withoutNulls,
      extra: <String, dynamic>{kTransitionInfoKey: _transicionFormulario},
    );
    // Recarga movimientos y totales al volver del formulario.
    if (mounted) _recargarSilencioso();
  }

  Future<void> _abrirDetalle(TransaccionPortafolioDto transaccion) async {
    await context.pushNamed(
      'transactions_details',
      queryParameters: {
        'idTransaccion': serializeParam(
            transaccion.idTransferencia, ParamType.int,
            isList: false),
      }.withoutNulls,
      extra: <String, dynamic>{kTransitionInfoKey: _transicionFormulario},
    );
    // Si el movimiento se anuló, recarga lista y totales.
    if (mounted) _recargarSilencioso();
  }

  void _volverACuentas() {
    if (widget.idProyecto == null) {
      // Portafolio de una cuenta: se vuelve a donde se abrió.
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed('cuentas');
      }
      return;
    }
    context.goNamed(
      'portafolio',
      queryParameters: {
        'idProyecto':
            serializeParam(widget.idProyecto, ParamType.int, isList: false),
      }.withoutNulls,
    );
  }

  // ---------------------------------------------------------------------------
  // Ajuste de saldo
  // ---------------------------------------------------------------------------

  /// Cuadra el saldo de la app con el saldo real de la cuenta.
  Future<void> _ajustarSaldo() async {
    // El saldo de referencia es el que está en pantalla.
    final datos = await _datos.then<_DatosCuenta?>((d) => d,
        onError: (Object _) => null);
    if (!mounted) return;
    if (datos == null) {
      mostrarMensaje(context, _t('trx_error'));
      return;
    }
    final saldoApp = datos.totales.saldo;

    final t = FFLocalizations.of(context);
    final tema = FlutterFlowTheme.of(context);
    final controller = TextEditingController();
    final saldoReal = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final real = int.tryParse(controller.text);
          final diferencia = real == null ? null : real - saldoApp;
          return AlertDialog(
            title: Text(t.getText('aju_titulo')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.getText('aju_saldo_app'),
                    style: tema.bodySmall.copyWith(color: tema.secondaryText)),
                Text(FormatoMoneda.cop(saldoApp),
                    style: tema.titleMedium
                        .copyWith(fontFeatures: _cifrasTabulares)),
                const SizedBox(height: Espacio.l),
                TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: t.getText('aju_saldo_real'),
                    prefixText: '\$ ',
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                if (diferencia != null && diferencia != 0) ...[
                  const SizedBox(height: Espacio.m),
                  Row(children: [
                    Icon(
                      diferencia > 0
                          ? Icons.south_west_rounded
                          : Icons.north_east_rounded,
                      size: 18,
                      color: diferencia > 0
                          ? ColoresFinanzas.ingresos
                          : ColoresFinanzas.egresos,
                    ),
                    const SizedBox(width: Espacio.s),
                    Expanded(
                      child: Text(
                        '${t.getText(diferencia > 0 ? 'aju_ingreso' : 'aju_egreso')} ${FormatoMoneda.cop(diferencia.abs())}',
                        style: tema.bodyMedium,
                      ),
                    ),
                  ]),
                ],
                const SizedBox(height: Espacio.s),
                Text(t.getText('aju_ayuda'),
                    style: tema.bodySmall.copyWith(color: tema.secondaryText)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(t.getText('mov_cancelar')),
              ),
              FilledButton(
                onPressed: real == null
                    ? null
                    : () => Navigator.of(dialogContext).pop(real),
                child: Text(t.getText('aju_confirmar')),
              ),
            ],
          );
        },
      ),
    );
    // Los controladores del diálogo no se liberan aquí: el diálogo sigue
    // pintándose durante su animación de cierre y fallaría al usarlos.
    if (saldoReal == null || !mounted) return;
    try {
      await _model.ajustarSaldo(widget.idPortafolio, saldoReal);
      if (!mounted) return;
      mostrarMensaje(context, t.getText('aju_hecho'));
      _recargarSilencioso();
    } catch (e) {
      if (!mounted) return;
      mostrarMensaje(context, e);
    }
  }

  // ---------------------------------------------------------------------------
  // Aportes, rendimientos y conversión en cuenta
  // ---------------------------------------------------------------------------

  Future<void> _aportar() async {
    final resultado = await showDialog<_ValorIngresado>(
      context: context,
      builder: (_) => _DialogoValor(
        titulo: _t('trx_aportar'),
        ayuda: _t('trx_aportar_ayuda'),
      ),
    );
    if (resultado == null || !mounted) return;
    try {
      await _model.registrarAporte(widget.idPortafolio, resultado.valor);
      if (!mounted) return;
      mostrarMensaje(context, _t('trx_aporte_hecho'));
      _recargarSilencioso();
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
  }

  Future<void> _registrarRendimiento() async {
    final resultado = await showDialog<_ValorIngresado>(
      context: context,
      builder: (_) => _DialogoValor(
        titulo: _t('trx_rendimiento'),
        ayuda: _t('trx_rendimiento_ayuda'),
        conReinvertir: !(_portafolio?.esPrincipal ?? false),
      ),
    );
    if (resultado == null || !mounted) return;
    try {
      await _model.registrarRendimiento(widget.idPortafolio, resultado.valor,
          reinvertir: resultado.reinvertir);
      if (!mounted) return;
      mostrarMensaje(context, _t('trx_rendimiento_hecho'));
      _recargarSilencioso();
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
  }

  Future<void> _convertirEnCuenta() async {
    final datos = await showDialog<_DatosConversion>(
      context: context,
      builder: (_) => const _DialogoConvertir(),
    );
    if (datos == null || !mounted) return;
    try {
      final idCuenta = await _model.convertirEnCuenta(widget.idPortafolio,
          tipoCuenta: datos.tipoCuenta, entidad: datos.entidad);
      if (!mounted) return;
      mostrarMensaje(context, _t('trx_convertido'));
      context.goNamed(
        'cuenta_detalle',
        queryParameters: {
          'idCuenta': serializeParam(idCuenta, ParamType.int),
        }.withoutNulls,
      );
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
  }

  Widget? _menuAcciones() {
    final portafolio = _portafolio;
    if (portafolio == null) return null;
    final esDeProyecto = portafolio.proyectoId != null;
    return PopupMenuButton<VoidCallback>(
      tooltip: _t('trx_mas'),
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (accion) => accion(),
      itemBuilder: (context) => [
        if (!portafolio.esPrincipal)
          PopupMenuItem(
            value: _aportar,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.input_rounded),
              title: Text(_t('trx_aportar')),
            ),
          ),
        PopupMenuItem(
          value: _registrarRendimiento,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.trending_up_rounded),
            title: Text(_t('trx_rendimiento')),
          ),
        ),
        if (esDeProyecto)
          PopupMenuItem(
            value: _convertirEnCuenta,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance_rounded),
              title: Text(_t('trx_convertir')),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Construcción
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: _t('trx_titulo'),
      acciones: [
        if (_menuAcciones() case final menu?) menu,
        IconButton(
          tooltip: _t('aju_titulo'),
          icon: const Icon(Icons.tune_rounded),
          onPressed: _ajustarSaldo,
        ),
        IconButton(
          tooltip: _t('trx_volver_cuentas'),
          icon: const Icon(Icons.close_rounded),
          onPressed: _volverACuentas,
        ),
      ],
      botonFlotante: FloatingActionButton.extended(
        onPressed: _nuevoMovimiento,
        icon: const Icon(Icons.add_rounded),
        label: Text(_t('trx_nuevo')),
      ),
      cuerpo: ContenidoAsincrono<_DatosCuenta>(
        future: _datos,
        mensajeError: _t('trx_error'),
        textoReintentar: _t('trx_reintentar'),
        onReintentar: _recargar,
        builder: (context, datos) => _contenido(datos),
      ),
    );
  }

  Widget _contenido(_DatosCuenta datos) {
    final movimientos = datos.movimientos;
    final hayMas =
        movimientos.length >= FiltroMovimientos.limiteListaPortafolio;
    // Índice 0: resumen. Luego un movimiento por fila (o el estado vacío) y,
    // si se alcanzó el límite, una fila final que lleva al historial.
    final filas = movimientos.isEmpty ? 1 : movimientos.length;
    final itemCount = 1 + filas + (hayMas ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          Espacio.l, Espacio.s, Espacio.l, _espacioBotonFlotante),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0) return _resumen(datos);
        if (movimientos.isEmpty) {
          return EstadoVacio(
            icono: Icons.receipt_long_rounded,
            mensaje: _t('trx_vacio'),
            textoAccion: _t('trx_registrar'),
            onAccion: _nuevoMovimiento,
          );
        }
        final i = index - 1;
        if (i == movimientos.length) return _verHistorial();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (i > 0) const Divider(height: 1),
            _FilaMovimiento(
              transaccion: movimientos[i],
              idPortafolio: widget.idPortafolio,
              fecha: _fecha(movimientos[i].createdAt),
              onTap: () => _abrirDetalle(movimientos[i]),
            ),
          ],
        );
      },
    );
  }

  String _fecha(String? valor) {
    if (valor == null || valor.isEmpty) return '';
    final fecha = DateTime.tryParse(valor);
    return fecha == null ? valor : _formatoFecha.format(fecha);
  }

  // ---------------------------------------------------------------------------
  // Resumen: saldo protagonista + ingresos y salidas
  // ---------------------------------------------------------------------------

  Widget _resumen(_DatosCuenta datos) {
    final tema = FlutterFlowTheme.of(context);
    final totales = datos.totales;
    final cantidad = datos.movimientos.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Tarjeta(
          padding: const EdgeInsets.all(Espacio.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.account_balance_wallet_rounded,
                    size: 20, color: tema.secondaryText),
                const SizedBox(width: Espacio.s),
                Text(_t('trx_saldo'),
                    style: tema.labelLarge.copyWith(color: tema.secondaryText)),
              ]),
              const SizedBox(height: Espacio.s),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  FormatoMoneda.cop(totales.saldo),
                  style: tema.displaySmall.copyWith(
                    color: totales.saldo < 0 ? tema.error : tema.primaryText,
                    fontFeatures: _cifrasTabulares,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Espacio.m),
        Row(
          children: [
            Expanded(
              child: IndicadorKpi(
                titulo: _t('trx_ingresos'),
                valor: FormatoMoneda.cop(totales.ingresos),
                icono: Icons.south_west_rounded,
                colorIcono: ColoresFinanzas.ingresos,
              ),
            ),
            const SizedBox(width: Espacio.m),
            Expanded(
              child: IndicadorKpi(
                titulo: _t('trx_salidas'),
                valor: FormatoMoneda.cop(totales.totalSalidas),
                icono: Icons.north_east_rounded,
                colorIcono: ColoresFinanzas.egresos,
              ),
            ),
          ],
        ),
        if (totales.impuestos > 0)
          Padding(
            padding: const EdgeInsets.only(top: Espacio.s),
            child: Text(
              '${_t('trx_incluye_gmf')} ${FormatoMoneda.cop(totales.impuestos)}',
              style: tema.bodySmall.copyWith(color: tema.secondaryText),
            ),
          ),
        EncabezadoSeccion(
          titulo: _t('trx_movimientos'),
          subtitulo:
              cantidad == 0 ? null : '$cantidad ${_t('trx_registros')}',
        ),
      ],
    );
  }

  Widget _verHistorial() {
    return Padding(
      padding: const EdgeInsets.only(top: Espacio.s),
      child: TextButton.icon(
        style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(altoMinimoTactil)),
        onPressed: () => context.pushNamed('movimientos'),
        icon: const Icon(Icons.history_rounded),
        label: Text(_t('his_ver_completo'), textAlign: TextAlign.center),
      ),
    );
  }
}

/// Fila de un movimiento: naturaleza (ícono), recorrido, fecha y tipo, y el
/// monto con signo según si el dinero entra o sale de esta cuenta.
class _FilaMovimiento extends StatelessWidget {
  final TransaccionPortafolioDto transaccion;
  final int idPortafolio;
  final String fecha;
  final VoidCallback onTap;

  const _FilaMovimiento({
    required this.transaccion,
    required this.idPortafolio,
    required this.fecha,
    required this.onTap,
  });

  static const _cifrasTabulares = [FontFeature.tabularFigures()];
  static const _ladoIcono = 40.0;

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final t = FFLocalizations.of(context);
    final tx = transaccion;

    final esIngreso = tx.tipoFuente == TipoFuente.ingreso;
    final esTransferencia = tx.tipoFuente == TipoFuente.transferencia;
    // Una transferencia que llega a esta cuenta suma; la que sale, resta.
    final entra =
        esIngreso || (esTransferencia && tx.destinoCuentaId == idPortafolio);

    final IconData icono;
    final Color colorIcono;
    final String claveNaturaleza;
    if (esTransferencia) {
      icono = Icons.swap_horiz_rounded;
      colorIcono = tema.secondaryText;
      claveNaturaleza = 'frm_transferencia';
    } else if (esIngreso) {
      icono = Icons.south_west_rounded;
      colorIcono = ColoresFinanzas.ingresos;
      claveNaturaleza = 'frm_ingreso';
    } else {
      icono = Icons.north_east_rounded;
      colorIcono = ColoresFinanzas.egresos;
      claveNaturaleza = 'frm_egreso';
    }

    final impuesto = tx.impuesto ?? 0;
    final detalle = [
      fecha,
      tx.tipoTransferencia,
      tx.motivo,
    ].where((v) => v != null && v.isNotEmpty).join('  ·  ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radios.s),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: altoMinimoTactil),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Espacio.m),
          child: Row(
            children: [
              Container(
                width: _ladoIcono,
                height: _ladoIcono,
                decoration: BoxDecoration(
                  color: tema.accent4,
                  borderRadius: BorderRadius.circular(Radios.s),
                ),
                child: Icon(icono,
                    size: 20,
                    color: colorIcono,
                    semanticLabel: t.getText(claveNaturaleza)),
              ),
              const SizedBox(width: Espacio.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.flujo,
                        style: tema.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: Espacio.xs),
                    Text(detalle,
                        style:
                            tema.bodySmall.copyWith(color: tema.secondaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: Espacio.m),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entra ? '+' : '−'} ${FormatoMoneda.cop(tx.valor)}',
                    textAlign: TextAlign.end,
                    style: tema.titleSmall.copyWith(
                      color: entra ? ColoresFinanzas.ingresos : tema.primaryText,
                      fontFeatures: _cifrasTabulares,
                    ),
                  ),
                  // El GMF solo lo paga la cuenta de la que sale el dinero.
                  if (!entra && impuesto > 0)
                    Text(
                      '${t.getText('trx_gmf')} ${FormatoMoneda.cop(impuesto)}',
                      style: tema.bodySmall.copyWith(
                        color: tema.secondaryText,
                        fontFeatures: _cifrasTabulares,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: Espacio.xs),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: tema.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resultado de [_DialogoValor].
class _ValorIngresado {
  final int valor;
  final bool reinvertir;

  const _ValorIngresado(this.valor, this.reinvertir);
}

/// Pide un valor (aporte o rendimiento). Es dueño de sus controladores.
class _DialogoValor extends StatefulWidget {
  final String titulo;
  final String ayuda;
  final bool conReinvertir;

  const _DialogoValor(
      {required this.titulo, required this.ayuda, this.conReinvertir = false});

  @override
  State<_DialogoValor> createState() => _DialogoValorState();
}

class _DialogoValorState extends State<_DialogoValor> {
  final _valor = TextEditingController();
  bool _reinvertir = false;
  String? _error;

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  void _aceptar() {
    final t = FFLocalizations.of(context);
    final valor = int.tryParse(_valor.text.trim()) ?? 0;
    if (valor <= 0) {
      setState(() {
        _error = t.getText('trx_valor_requerido');
      });
      return;
    }
    Navigator.of(context).pop(_ValorIngresado(valor, _reinvertir));
  }

  @override
  Widget build(BuildContext context) {
    final t = FFLocalizations.of(context);
    final tema = FlutterFlowTheme.of(context);
    return AlertDialog(
      title: Text(widget.titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.ayuda,
              style: tema.bodySmall.copyWith(color: tema.secondaryText)),
          const SizedBox(height: Espacio.m),
          TextField(
            controller: _valor,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _aceptar(),
            decoration: InputDecoration(
              labelText: t.getText('trx_valor'),
              prefixText: '\$ ',
              errorText: _error,
            ),
          ),
          if (widget.conReinvertir)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.getText('trx_reinvertir'), style: tema.bodyMedium),
              value: _reinvertir,
              onChanged: (valor) => setState(() {
                _reinvertir = valor;
              }),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.getText('mov_cancelar')),
        ),
        FilledButton(
          onPressed: _aceptar,
          child: Text(t.getText('trx_registrar_btn')),
        ),
      ],
    );
  }
}

/// Resultado de [_DialogoConvertir].
class _DatosConversion {
  final String tipoCuenta;
  final String? entidad;

  const _DatosConversion(this.tipoCuenta, this.entidad);
}

/// Pide el tipo de cuenta y el banco para convertir el portafolio.
class _DialogoConvertir extends StatefulWidget {
  const _DialogoConvertir();

  @override
  State<_DialogoConvertir> createState() => _DialogoConvertirState();
}

class _DialogoConvertirState extends State<_DialogoConvertir> {
  final _entidad = TextEditingController();
  String _tipo = TipoCuenta.ahorros;

  @override
  void dispose() {
    _entidad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = FFLocalizations.of(context);
    final tema = FlutterFlowTheme.of(context);
    return AlertDialog(
      title: Text(t.getText('trx_convertir')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.getText('trx_convertir_ayuda'),
              style: tema.bodySmall.copyWith(color: tema.secondaryText)),
          const SizedBox(height: Espacio.m),
          DropdownButtonFormField<String>(
            initialValue: _tipo,
            isExpanded: true,
            decoration: InputDecoration(labelText: t.getText('cta_tipo')),
            items: [
              for (final tipo in TipoCuenta.deActivo)
                DropdownMenuItem(
                  value: tipo,
                  child: Text(TipoCuentaUi.nombre(context, tipo)),
                ),
            ],
            onChanged: (valor) => setState(() {
              _tipo = valor ?? _tipo;
            }),
          ),
          const SizedBox(height: Espacio.m),
          TextField(
            controller: _entidad,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: t.getText('cta_entidad'),
              helperText: t.getText('form_opcional'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.getText('mov_cancelar')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context)
              .pop(_DatosConversion(_tipo, _entidad.text)),
          child: Text(t.getText('trx_convertir_btn')),
        ),
      ],
    );
  }
}
