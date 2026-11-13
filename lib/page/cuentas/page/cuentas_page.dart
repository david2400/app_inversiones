import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/cuentas/page/tipo_cuenta_ui.dart';
import 'package:inversiones/page/cuentas/states/cuentas_page_state.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

/// Cuentas donde vive el dinero y deudas (tarjetas y préstamos).
class CuentasPage extends StatefulWidget {
  const CuentasPage({super.key});

  @override
  State<CuentasPage> createState() => _CuentasPageState();
}

class _CuentasPageState extends State<CuentasPage> {
  late CuentasPageState _model;
  late Future<List<CuentaDto>> _cuentas;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CuentasPageState());
    _cuentas = _model.listar();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  Future<void> _recargar() async {
    final consulta = _model.listar();
    if (!mounted) return;
    setState(() {
      _cuentas = consulta;
    });
    try {
      await consulta;
    } catch (_) {
      // El error lo muestra ContenidoAsincrono.
    }
  }

  /// Elige qué crear: cuenta, tarjeta de crédito o préstamo.
  Future<void> _nueva() async {
    final ruta = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (hoja) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (ruta, icono, texto) in [
              ('admin_cuenta', Icons.account_balance_rounded, 'cta_nueva'),
              ('admin_tarjeta', Icons.credit_card_rounded, 'deu_nueva_tarjeta'),
              ('admin_prestamo', Icons.request_quote_rounded, 'deu_nuevo_prestamo'),
            ])
              ListTile(
                leading: Icon(icono),
                title: Text(_t(texto)),
                onTap: () => Navigator.of(hoja).pop(ruta),
              ),
            const SizedBox(height: Espacio.s),
          ],
        ),
      ),
    );
    if (ruta == null || !mounted) return;
    final guardada = await context.pushNamed(ruta);
    if (guardada == true) await _recargar();
  }

  Future<void> _abrir(CuentaDto cuenta) async {
    await context.pushNamed(
      TipoCuenta.esPasivo(cuenta.tipoCuenta) ? 'deuda_detalle' : 'cuenta_detalle',
      queryParameters: {
        'idCuenta': serializeParam(cuenta.idCuenta, ParamType.int),
      }.withoutNulls,
    );
    await _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: _t('cta_titulo'),
      botonFlotante: FloatingActionButton.extended(
        onPressed: _nueva,
        icon: const Icon(Icons.add_rounded),
        label: Text(_t('deu_agregar')),
      ),
      cuerpo: ContenidoAsincrono<List<CuentaDto>>(
        future: _cuentas,
        mensajeError: _t('cta_error'),
        textoReintentar: _t('cta_reintentar'),
        onReintentar: _recargar,
        builder: (context, cuentas) => RefreshIndicator(
          onRefresh: _recargar,
          child: _ListaCuentas(cuentas: cuentas, onAbrir: _abrir),
        ),
      ),
    );
  }
}

class _ListaCuentas extends StatelessWidget {
  final List<CuentaDto> cuentas;
  final ValueChanged<CuentaDto> onAbrir;

  const _ListaCuentas({required this.cuentas, required this.onAbrir});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final activos =
        cuentas.where((c) => !TipoCuenta.esPasivo(c.tipoCuenta)).toList();
    final deudas =
        cuentas.where((c) => TipoCuenta.esPasivo(c.tipoCuenta)).toList();
    final enCuentas = activos.fold<int>(0, (suma, c) => suma + c.saldo);
    final debes = deudas.fold<int>(0, (suma, c) => suma + (c.saldo < 0 ? -c.saldo : 0));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          Espacio.l, Espacio.s, Espacio.l, Espacio.xxl * 3),
      children: [
        Tarjeta(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(textos.getText('cta_total'),
                  style: tema.labelMedium.copyWith(color: tema.secondaryText)),
              const SizedBox(height: Espacio.xs),
              Text(
                FormatoMoneda.cop(enCuentas),
                style: tema.displaySmall.copyWith(
                    color: enCuentas < 0 ? tema.error : tema.primaryText),
              ),
              if (deudas.isNotEmpty) ...[
                const SizedBox(height: Espacio.m),
                Row(
                  children: [
                    Expanded(
                      child: IndicadorKpi(
                        titulo: textos.getText('deu_total_deudas'),
                        valor: FormatoMoneda.cop(debes),
                        icono: Icons.credit_card_rounded,
                        colorValor: debes > 0 ? tema.error : tema.primaryText,
                      ),
                    ),
                    const SizedBox(width: Espacio.m),
                    Expanded(
                      child: IndicadorKpi(
                        titulo: textos.getText('deu_neto'),
                        valor: FormatoMoneda.cop(enCuentas - debes),
                        icono: Icons.balance_rounded,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: Espacio.xs),
              Text(textos.getText('cta_total_ayuda'),
                  style: tema.bodySmall.copyWith(color: tema.secondaryText)),
            ],
          ),
        ),
        const SizedBox(height: Espacio.l),
        for (final cuenta in activos) _FilaCuenta(cuenta: cuenta, onAbrir: onAbrir),
        if (deudas.isNotEmpty) ...[
          const SizedBox(height: Espacio.l),
          EncabezadoSeccion(
            titulo: textos.getText('deu_titulo'),
            subtitulo: textos.getText('deu_titulo_ayuda'),
          ),
          const SizedBox(height: Espacio.s),
          for (final deuda in deudas) _FilaCuenta(cuenta: deuda, onAbrir: onAbrir),
        ],
      ],
    );
  }
}

class _FilaCuenta extends StatelessWidget {
  final CuentaDto cuenta;
  final ValueChanged<CuentaDto> onAbrir;

  const _FilaCuenta({required this.cuenta, required this.onAbrir});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final esDeuda = TipoCuenta.esPasivo(cuenta.tipoCuenta);
    final detalle = [
      TipoCuentaUi.nombre(context, cuenta.tipoCuenta),
      if (cuenta.entidad != null) cuenta.entidad!,
      if (!esDeuda && cuenta.cantidadPortafolios > 1)
        '${cuenta.cantidadPortafolios} ${textos.getText('cta_portafolios').toLowerCase()}',
    ].join(' · ');
    // En una deuda se muestra lo que se debe (positivo).
    final valor = esDeuda ? -cuenta.saldo : cuenta.saldo;
    final color = esDeuda
        ? (valor > 0 ? tema.error : tema.primaryText)
        : (valor < 0 ? tema.error : tema.primaryText);
    return Padding(
      padding: const EdgeInsets.only(bottom: Espacio.s),
      child: Tarjeta(
        padding: EdgeInsets.zero,
        onTap: () => onAbrir(cuenta),
        child: ListTile(
          minVerticalPadding: Espacio.m,
          leading: CircleAvatar(
            backgroundColor: tema.primaryBackground,
            child: Icon(TipoCuentaUi.icono(cuenta.tipoCuenta),
                color: esDeuda ? tema.error : tema.primary),
          ),
          title: Text(cuenta.nombre, style: tema.bodyLarge),
          subtitle: Text(detalle,
              style: tema.bodySmall.copyWith(color: tema.secondaryText)),
          trailing: Text(
            FormatoMoneda.cop(valor),
            style: tema.titleSmall.copyWith(
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
