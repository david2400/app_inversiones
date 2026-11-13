import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: FlutterFlowTheme.of(context).secondary,
      child: ListView(
        children: [
          // Encabezado local: la app es 100 % offline, sin imágenes remotas.
          DrawerHeader(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  child: Icon(Icons.account_balance_wallet_rounded,
                      color: FlutterFlowTheme.of(context).primaryText),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    FFLocalizations.of(context).getText('menu_app'),
                    style: FlutterFlowTheme.of(context).titleLarge,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_rounded),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text(FFLocalizations.of(context).getText('menu_inicio')),
            onTap: () => context.goNamed('home'),
          ),
          ListTile(
            leading: Icon(Icons.home),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text("Proyecto"),
            onTap: () async {
              context.goNamed(
                'proyects',
                // extra: <String, dynamic>{
                //   kTransitionInfoKey: TransitionInfo(
                //     hasTransition: true,
                //     transitionType: PageTransitionType
                //         .leftToRight,
                //     duration:
                //     Duration(milliseconds: 220),
                //   ),
                // },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.account_box),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text("frecuencia pago"),
            onTap: () async {
              context.goNamed(
                'frecuencia_pago',
                // extra: <String, dynamic>{
                //   kTransitionInfoKey: TransitionInfo(
                //     hasTransition: true,
                //     transitionType: PageTransitionType
                //         .leftToRight,
                //     duration:
                //     Duration(milliseconds: 220),
                //   ),
                // },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet_sharp),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text(FFLocalizations.of(context).getText(
              'ig2y6wx6' /* Tipo de proyecto */,
            )),
            onTap: () async {
              context.goNamed(
                'tipo_proyecto',
                extra: <String, dynamic>{
                  kTransitionInfoKey: TransitionInfo(
                    hasTransition: true,
                    transitionType: PageTransitionType.leftToRight,
                    duration: Duration(milliseconds: 220),
                  ),
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_mail),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text(FFLocalizations.of(context).getText(
              '147fye16' /* Tipo de transferencia */,
            )),
            onTap: () async {
              context.goNamed(
                'tipo_transaccion',
                // extra: <String, dynamic>{
                //   kTransitionInfoKey: TransitionInfo(
                //     hasTransition: true,
                //     transitionType: PageTransitionType
                //         .leftToRight,
                //     duration:
                //     Duration(milliseconds: 220),
                //   ),
                // },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.grid_3x3_outlined),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text(FFLocalizations.of(context).getText(
              'tcckgjcg' /* Motivo */,
            )),
            onTap: () async {
              context.goNamed(
                'motivos',
                // extra: <String, dynamic>{
                //   kTransitionInfoKey: TransitionInfo(
                //     hasTransition: true,
                //     transitionType: PageTransitionType
                //         .leftToRight,
                //     duration:
                //     Duration(milliseconds: 220),
                //   ),
                // },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance_rounded),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text(FFLocalizations.of(context).getText('menu_cuentas')),
            onTap: () => context.goNamed('cuentas'),
          ),
          ListTile(
            leading: Icon(Icons.receipt_long_rounded),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text(FFLocalizations.of(context).getText('menu_movimientos')),
            onTap: () => context.goNamed('movimientos'),
          ),
          ListTile(
            leading: Icon(Icons.event_repeat_rounded),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text(FFLocalizations.of(context).getText('menu_fijos')),
            onTap: () => context.goNamed('recurrentes'),
          ),
          ListTile(
            leading: Icon(Icons.savings_rounded),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text(FFLocalizations.of(context).getText('menu_presupuestos')),
            onTap: () => context.goNamed('presupuestos'),
          ),
          ListTile(
            leading: Icon(Icons.people_alt_rounded),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text(FFLocalizations.of(context).getText('menu_terceros')),
            onTap: () => context.goNamed('terceros'),
          ),
          ListTile(
            leading: Icon(Icons.bar_chart_rounded),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text(FFLocalizations.of(context).getText('menu_reportes')),
            onTap: () => context.goNamed('reportes'),
          ),
          ListTile(
            leading: Icon(Icons.backup_rounded),
            iconColor: FlutterFlowTheme.of(context).primaryText,
            textColor: FlutterFlowTheme.of(context).primaryText,
            title: Text(FFLocalizations.of(context).getText('menu_respaldo')),
            onTap: () => context.goNamed('respaldo'),
          ),
        ],
      ),
    );
  }
}
