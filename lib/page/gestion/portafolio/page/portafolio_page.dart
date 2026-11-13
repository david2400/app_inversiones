import 'package:flutter/material.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/home/dto/resumen_financiero_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

export 'package:inversiones/page/gestion/portafolio/states/portafolio_page_state.dart';
import 'package:inversiones/page/gestion/portafolio/states/portafolio_page_state.dart';

/// Portafolios (cuentas) de un proyecto: saldo del proyecto, accesos rápidos
/// y listado de cuentas.
class PortafolioPage extends StatefulWidget {
  final int idProyecto;

  const PortafolioPage({super.key, required this.idProyecto});

  @override
  State<PortafolioPage> createState() => _PortafolioPageState();
}

class _PortafolioPageState extends State<PortafolioPage> {
  static const _rutaNuevoPortafolio = 'admin_portafolio';
  static const _rutaNuevoMovimiento = 'admin_transactions';
  static const _rutaActividad = 'portafolio_activity';
  static const _rutaMovimientos = 'transactions';
  static const _rutaProyectos = 'proyects';

  static const _transicion = TransitionInfo(
    hasTransition: true,
    transitionType: PageTransitionType.bottomToTop,
    duration: Duration(milliseconds: 220),
  );

  late PortafolioPageState _model;

  /// Consultas guardadas en el State: nunca se disparan desde `build`.
  late Future<TotalesDto> _balance;
  late Future<List<PortafolioDto>> _portafolios;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PortafolioPageState());
    _balance = dataBalancePortafolio();
    _portafolios = listarPortafolio();
  }

  /// Vuelve a consultar los datos (al volver de crear o editar).
  void _recargarDatos() {
    if (!mounted) return;
    setState(() {
      _balance = dataBalancePortafolio();
      _portafolios = listarPortafolio();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Los errores se propagan para que la pantalla muestre el estado de error
  /// con "Reintentar" en lugar de una lista vacía engañosa.
  Future<List<PortafolioDto>> listarPortafolio() =>
      _model.listarPortafolio(widget.idProyecto);

  Future<TotalesDto> dataBalancePortafolio() =>
      _model.resumenProyecto(widget.idProyecto);

  Future<void> _abrirNuevoPortafolio() async {
    await context.pushNamed(
      _rutaNuevoPortafolio,
      queryParameters: {
        'idProyecto':
            serializeParam(widget.idProyecto, ParamType.int, isList: false),
      }.withoutNulls,
      extra: <String, dynamic>{kTransitionInfoKey: _transicion},
    );
    _recargarDatos();
  }

  Future<void> _abrirNuevoMovimiento() async {
    await context.pushNamed(
      _rutaNuevoMovimiento,
      queryParameters: {
        'idPortafolio': serializeParam(null, ParamType.int, isList: false),
      },
      extra: <String, dynamic>{kTransitionInfoKey: _transicion},
    );
    _recargarDatos();
  }

  Future<void> _abrirActividad() async {
    await context.pushNamed(
      _rutaActividad,
      queryParameters: {
        'idProyecto':
            serializeParam(widget.idProyecto, ParamType.int, isList: false),
      }.withoutNulls,
      extra: <String, dynamic>{kTransitionInfoKey: _transicion},
    );
    _recargarDatos();
  }

  void _abrirMovimientos(PortafolioDto portafolio) {
    context.goNamed(
      _rutaMovimientos,
      queryParameters: {
        'idPortafolio': serializeParam(portafolio.idPortafolio, ParamType.int,
            isList: false),
        'idProyecto':
            serializeParam(portafolio.proyectoId, ParamType.int, isList: false),
      }.withoutNulls,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    return PantallaBase(
      titulo: textos.getText('port_titulo'),
      acciones: [
        IconButton(
          tooltip: textos.getText('port_cerrar'),
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.goNamed(_rutaProyectos),
        ),
      ],
      botonFlotante: FloatingActionButton.extended(
        onPressed: _abrirNuevoPortafolio,
        tooltip: textos.getText('port_nuevo'),
        icon: const Icon(Icons.add_rounded),
        label: Text(textos.getText('port_nuevo')),
      ),
      cuerpo: GestureDetector(
        onTap: () => _model.unfocusNode.canRequestFocus
            ? FocusScope.of(context).requestFocus(_model.unfocusNode)
            : FocusScope.of(context).unfocus(),
        child: ContenidoAsincrono<List<PortafolioDto>>(
          future: _portafolios,
          mensajeError: textos.getText('port_error'),
          textoReintentar: textos.getText('port_reintentar'),
          onReintentar: _recargarDatos,
          builder: (context, portafolios) => _ListaPortafolios(
            portafolios: portafolios,
            resumen: _ResumenProyecto(
              balance: _balance,
              onReintentar: _recargarDatos,
            ),
            accesos: _AccesosRapidos(
              onNuevoMovimiento: _abrirNuevoMovimiento,
              onActividad: _abrirActividad,
            ),
            onAbrir: _abrirMovimientos,
            onNuevo: _abrirNuevoPortafolio,
          ),
        ),
      ),
    );
  }
}

/// Lista perezosa: resumen, accesos, encabezado y una fila por portafolio.
class _ListaPortafolios extends StatelessWidget {
  final List<PortafolioDto> portafolios;
  final Widget resumen;
  final Widget accesos;
  final ValueChanged<PortafolioDto> onAbrir;
  final VoidCallback onNuevo;

  const _ListaPortafolios({
    required this.portafolios,
    required this.resumen,
    required this.accesos,
    required this.onAbrir,
    required this.onNuevo,
  });

  /// Filas fijas antes del listado: resumen, accesos y encabezado.
  static const _filasCabecera = 3;

  /// Deja libre el final de la lista para que el botón flotante no tape la
  /// última fila.
  static const _espacioBotonFlotante = 88.0;

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final vacio = portafolios.isEmpty;
    final filasDatos = vacio ? 1 : portafolios.length;

    return ListView.separated(
      padding: Espacio.pantalla.copyWith(bottom: _espacioBotonFlotante),
      itemCount: _filasCabecera + filasDatos,
      separatorBuilder: (context, indice) {
        if (indice == 0) return const SizedBox(height: Espacio.m);
        if (indice < _filasCabecera) return const SizedBox.shrink();
        return Divider(height: 1, color: tema.alternate);
      },
      itemBuilder: (context, indice) {
        if (indice == 0) return resumen;
        if (indice == 1) return accesos;
        if (indice == 2) {
          return EncabezadoSeccion(
            titulo: vacio
                ? textos.getText('port_cuentas')
                : '${portafolios.length} ${textos.getText('port_cuentas')}',
            subtitulo: vacio ? null : textos.getText('port_cuentas_ayuda'),
          );
        }
        if (vacio) {
          return EstadoVacio(
            icono: Icons.account_balance_wallet_outlined,
            mensaje: textos.getText('port_vacio'),
            textoAccion: textos.getText('port_nuevo'),
            onAccion: onNuevo,
          );
        }
        final portafolio = portafolios[indice - _filasCabecera];
        return _FilaPortafolio(
          portafolio: portafolio,
          onTap: () => onAbrir(portafolio),
        );
      },
    );
  }
}

/// Saldo del proyecto como cifra protagonista, con ingresos y salidas.
class _ResumenProyecto extends StatelessWidget {
  final Future<TotalesDto> balance;
  final VoidCallback onReintentar;

  const _ResumenProyecto({required this.balance, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    return ContenidoAsincrono<TotalesDto>(
      future: balance,
      mensajeError: textos.getText('port_error_saldo'),
      textoReintentar: textos.getText('port_reintentar'),
      onReintentar: onReintentar,
      builder: (context, totales) {
        final saldo = totales.saldo;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Tarjeta(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    textos.getText('port_saldo_total'),
                    style: tema.bodySmall.copyWith(color: tema.secondaryText),
                  ),
                  const SizedBox(height: Espacio.s),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      FormatoMoneda.cop(saldo),
                      style: tema.displaySmall.copyWith(
                        color: saldo < 0 ? tema.error : tema.primaryText,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(height: Espacio.xs),
                  Text(
                    textos.getText('port_saldo_ayuda'),
                    style: tema.bodySmall.copyWith(color: tema.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Espacio.m),
            Row(
              children: [
                Expanded(
                  child: IndicadorKpi(
                    titulo: textos.getText('port_ingresos'),
                    valor: FormatoMoneda.cop(totales.ingresos),
                    icono: Icons.south_west_rounded,
                    colorIcono: ColoresFinanzas.ingresos,
                  ),
                ),
                const SizedBox(width: Espacio.m),
                Expanded(
                  child: IndicadorKpi(
                    titulo: textos.getText('port_salidas'),
                    valor: FormatoMoneda.cop(totales.totalSalidas),
                    icono: Icons.north_east_rounded,
                    colorIcono: ColoresFinanzas.egresos,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Accesos a registrar un movimiento y a la actividad del proyecto.
class _AccesosRapidos extends StatelessWidget {
  final VoidCallback onNuevoMovimiento;
  final VoidCallback onActividad;

  const _AccesosRapidos({
    required this.onNuevoMovimiento,
    required this.onActividad,
  });

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _Acceso(
            icono: Icons.add_card_rounded,
            texto: textos.getText('port_nuevo_movimiento'),
            onTap: onNuevoMovimiento,
          ),
        ),
        const SizedBox(width: Espacio.m),
        Expanded(
          child: _Acceso(
            icono: Icons.stacked_line_chart_rounded,
            texto: textos.getText('port_actividad'),
            onTap: onActividad,
          ),
        ),
      ],
    );
  }
}

class _Acceso extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback onTap;

  const _Acceso({required this.icono, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Semantics(
      button: true,
      child: Tarjeta(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
            horizontal: Espacio.m, vertical: Espacio.m),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              minHeight: altoMinimoTactil - 2 * Espacio.m),
          child: Row(
            children: [
              Icon(icono, size: 20, color: tema.primary),
              const SizedBox(width: Espacio.s),
              Expanded(
                child: Text(
                  texto,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tema.labelLarge.copyWith(color: tema.primaryText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila de un portafolio: nombre, cuenta e interés; fecha de creación y
/// marca de exención del 4x1000 a la derecha.
class _FilaPortafolio extends StatelessWidget {
  final PortafolioDto portafolio;
  final VoidCallback onTap;

  const _FilaPortafolio({required this.portafolio, required this.onTap});

  static const _exenta = 'S';
  static final _formatoFecha = DateFormat('yyyy-MM-dd');

  String _detalle(FFLocalizations textos) {
    final partes = <String>[];
    final cuenta = portafolio.nroCuenta?.trim() ?? '';
    if (cuenta.isNotEmpty) {
      partes.add('${textos.getText('port_cuenta')} $cuenta');
    }
    final interes = portafolio.interes;
    if (interes != null) {
      partes.add('$interes ${textos.getText('port_interes_ea')}');
    }
    return partes.isEmpty
        ? textos.getText('port_sin_detalle')
        : partes.join(' · ');
  }

  String _fecha() {
    final texto = portafolio.createdAt;
    if (texto == null) return '';
    final fecha = DateTime.tryParse(texto);
    return fecha == null ? texto : _formatoFecha.format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final exenta = portafolio.exentaImpuesto == _exenta;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: Espacio.m,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tema.accent1,
          borderRadius: BorderRadius.circular(Radios.s),
        ),
        child: Icon(Icons.account_balance_wallet_rounded,
            size: 20, color: tema.primary),
      ),
      title: Text(
        portafolio.nombre,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tema.titleSmall,
      ),
      subtitle: Text(
        _detalle(textos),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tema.bodySmall.copyWith(color: tema.secondaryText),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fecha(),
                style: tema.bodySmall.copyWith(
                  color: tema.secondaryText,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (exenta) ...[
                const SizedBox(height: Espacio.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: 14, color: tema.success),
                    const SizedBox(width: Espacio.xs),
                    Text(
                      textos.getText('port_exenta'),
                      style: tema.labelSmall.copyWith(color: tema.success),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(width: Espacio.xs),
          Icon(Icons.chevron_right_rounded, color: tema.secondaryText),
        ],
      ),
    );
  }
}
