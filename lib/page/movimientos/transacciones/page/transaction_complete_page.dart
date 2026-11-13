import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

export 'package:inversiones/page/movimientos/transacciones/states/transaction_complete_page_state.dart';
import 'package:inversiones/page/movimientos/transacciones/states/transaction_complete_page_state.dart';

/// Confirmación de un movimiento registrado: ícono de éxito, mensaje y la
/// acción para continuar.
class TransferCompletePage extends StatefulWidget {
  const TransferCompletePage({super.key});

  @override
  State<TransferCompletePage> createState() => _TransferCompletePageState();
}

class _TransferCompletePageState extends State<TransferCompletePage> {
  late TransferCompletePageState _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const _ladoIcono = 96.0;
  static const _tamanoIcono = 56.0;
  static const _anchoMaximo = 420.0;
  static const _transicion = TransitionInfo(
    hasTransition: true,
    transitionType: PageTransitionType.leftToRight,
    duration: Duration(milliseconds: 200),
  );

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TransferCompletePageState());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  void _continuar() {
    context.pushNamed(
      'proyects',
      extra: <String, dynamic>{kTransitionInfoKey: _transicion},
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: tema.primaryBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Espacio.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _anchoMaximo),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Éxito con ícono + texto (nunca solo color).
                  Container(
                    width: _ladoIcono,
                    height: _ladoIcono,
                    decoration: BoxDecoration(
                      color: tema.accent2,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: _tamanoIcono,
                      color: tema.success,
                      semanticLabel: _t('trxok_titulo'),
                    ),
                  ),
                  const SizedBox(height: Espacio.xl),
                  Text(
                    _t('trxok_titulo'),
                    textAlign: TextAlign.center,
                    style: tema.headlineMedium,
                  ),
                  const SizedBox(height: Espacio.m),
                  Text(
                    _t('trxok_mensaje'),
                    textAlign: TextAlign.center,
                    style:
                        tema.bodyMedium.copyWith(color: tema.secondaryText),
                  ),
                  const SizedBox(height: Espacio.xxl),
                  BotonPrincipal(
                    texto: _t('trxok_continuar'),
                    icono: Icons.arrow_forward_rounded,
                    onPressed: _continuar,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
