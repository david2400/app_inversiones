import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_icon_button.dart';
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
          UserAccountsDrawerHeader(
            accountName: Text("AppMaking.co"),
            accountEmail: Text("sundar@appmaking.co"),
            currentAccountPicture: CircleAvatar(
              // backgroundImage: NetworkImage(
              //     "https://appmaking.co/wp-content/uploads/2021/08/appmaking-logo-colored.png"),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://appmaking.co/wp-content/uploads/2021/08/android-drawer-bg.jpeg",
                ),
                fit: BoxFit.fill,
              ),
            ),
            otherAccountsPictures: [
              FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30,
                buttonSize: 48,
                icon: Icon(
                  Icons.exit_to_app,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 25,
                ),
                onPressed: () async {
                  // context.pop();
                },
              ),
            ],
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
          )
        ],
      ),
    );
  }
}
