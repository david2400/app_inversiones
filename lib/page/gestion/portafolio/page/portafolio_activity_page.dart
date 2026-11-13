import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

export 'package:inversiones/page/gestion/portafolio/states/portafolio_activiy_page_state.dart';
import 'package:inversiones/page/gestion/portafolio/states/portafolio_activiy_page_state.dart';

/// Actividad del portafolio: monto mensual, total gastado, tendencia y
/// movimientos.
///
/// Pendiente: [PortafolioActiviyPageState] aún no consulta datos; los montos
/// son los valores fijos que ya mostraba la plantilla y la gráfica y la lista
/// no tienen origen de datos, por eso se muestran como estado vacío.
class PortafolioActivityPage extends StatefulWidget {
  final int idProyecto;

  const PortafolioActivityPage({super.key, required this.idProyecto});

  @override
  State<PortafolioActivityPage> createState() => _PortafolioActiviyPageState();
}

class _PortafolioActiviyPageState extends State<PortafolioActivityPage> {
  late PortafolioActiviyPageState _model;

  // Pendiente: reemplazar por los datos del State cuando existan.
  static const _montoMensual = 456456;
  static const _totalGastado = 123;

  static const _cifrasTabulares = [FontFeature.tabularFigures()];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PortafolioActiviyPageState());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: _t('pact_titulo'),
      conMenu: false,
      acciones: [
        // La eliminación aún no está implementada (antes el botón no hacía
        // nada); se muestra deshabilitado para no sugerir una acción falsa.
        IconButton(
          tooltip: _t('pact_eliminar_no_disponible'),
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: null,
        ),
      ],
      cuerpo: ListView(
        padding: Espacio.pantalla,
        children: [
          _resumen(),
          EncabezadoSeccion(
            titulo: _t('pact_tendencia'),
            subtitulo: _t('pact_tendencia_ayuda'),
          ),
          Tarjeta(
            child: EstadoVacio(
              icono: Icons.show_chart_rounded,
              mensaje: _t('pact_grafico_vacio'),
            ),
          ),
          EncabezadoSeccion(titulo: _t('ifi6fmsa' /* Transactions */)),
          Tarjeta(
            child: EstadoVacio(
              icono: Icons.receipt_long_rounded,
              mensaje: _t('pact_movimientos_vacio'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumen() {
    final tema = FlutterFlowTheme.of(context);
    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('pact_monto_mensual'),
            style: tema.bodySmall.copyWith(color: tema.secondaryText),
          ),
          const SizedBox(height: Espacio.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    FormatoMoneda.cop(_montoMensual),
                    style: tema.displaySmall.copyWith(
                      color: tema.primaryText,
                      fontFeatures: _cifrasTabulares,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Espacio.s),
              Text(
                _t('p0gf1lfy' /* Per Month */),
                style: tema.bodyMedium.copyWith(color: tema.secondaryText),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Espacio.m),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Icon(Icons.trending_down_rounded,
                  size: 20, color: tema.secondaryText),
              const SizedBox(width: Espacio.s),
              Expanded(
                child: Text(
                  _t('ti7ipegi' /* Total Spent */),
                  style: tema.bodyMedium.copyWith(color: tema.secondaryText),
                ),
              ),
              Text(
                FormatoMoneda.cop(_totalGastado),
                textAlign: TextAlign.end,
                style: tema.titleMedium.copyWith(
                  color: tema.primaryText,
                  fontFeatures: _cifrasTabulares,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
