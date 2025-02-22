import 'package:flutter/material.dart';
import 'package:inversiones/page/auth/login/states/change_password_state.dart';
import '../../../../auth/firebase_auth/auth_util.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/flutter_flow_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late ChangePasswordstate _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChangePasswordstate());

    _model.emailAddressFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondary,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondary,
        automaticallyImplyLeading: false,
        leading: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            context.pop();
          },
          child: Icon(
            Icons.chevron_left_rounded,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 32,
          ),
        ),
        title: Text(
          FFLocalizations.of(context).getText(
            'l5iggwaz' /* Change Password */,
          ),
          style: FlutterFlowTheme.of(context).headlineSmall.override(
            fontFamily: 'Outfit',
            letterSpacing: 0,
          ),
        ),
        actions: [],
        centerTitle: false,
        elevation: 0,
      ),
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height * 1,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fitWidth,
            image: Image.asset(
              'assets/images/login_bg@2x.png',
            ).image,
          ),
        ),
        // child: StreamBuilder<UsersRecord>(
        //   stream: null,//UsersRecord.getDocument(currentUserReference!),
        //   builder: (context, snapshot) {
        //     // Customize what your widget looks like when it's loading.
        //     if (!snapshot.hasData) {
        //       return Center(
        //         child: SizedBox(
        //           width: 50,
        //           height: 50,
        //           child: CircularProgressIndicator(
        //             valueColor: AlwaysStoppedAnimation<Color>(
        //               FlutterFlowTheme.of(context).primary,
        //             ),
        //           ),
        //         ),
        //       );
        //     }
        //     final columnUsersRecord = snapshot.data!;
        //     return Column(
        //       mainAxisSize: MainAxisSize.max,
        //       children: [
        //         Padding(
        //           padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
        //           child: Row(
        //             mainAxisSize: MainAxisSize.max,
        //             children: [
        //               Expanded(
        //                 child: Text(
        //                   FFLocalizations.of(context).getText(
        //                     '2b97u8y5' /* Enter the email associated wit... */,
        //                   ),
        //                   style:
        //                   FlutterFlowTheme.of(context).bodySmall.override(
        //                     fontFamily: 'Plus Jakarta Sans',
        //                     letterSpacing: 0,
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //         Padding(
        //           padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
        //           child: TextFormField(
        //             controller: _model.emailAddressTextController ??=
        //                 TextEditingController(
        //                   text: columnUsersRecord.email,
        //                 ),
        //             focusNode: _model.emailAddressFocusNode,
        //             obscureText: false,
        //             decoration: InputDecoration(
        //               labelText: FFLocalizations.of(context).getText(
        //                 'ajy1c3r9' /* Email Address */,
        //               ),
        //               labelStyle:
        //               FlutterFlowTheme.of(context).bodySmall.override(
        //                 fontFamily: 'Plus Jakarta Sans',
        //                 letterSpacing: 0,
        //               ),
        //               hintText: FFLocalizations.of(context).getText(
        //                 'hsqfoxya' /* Enter your email... */,
        //               ),
        //               hintStyle:
        //               FlutterFlowTheme.of(context).bodySmall.override(
        //                 fontFamily: 'Plus Jakarta Sans',
        //                 letterSpacing: 0,
        //               ),
        //               enabledBorder: OutlineInputBorder(
        //                 borderSide: BorderSide(
        //                   color: FlutterFlowTheme.of(context).alternate,
        //                   width: 2,
        //                 ),
        //                 borderRadius: BorderRadius.circular(8),
        //               ),
        //               focusedBorder: OutlineInputBorder(
        //                 borderSide: BorderSide(
        //                   color: Color(0x00000000),
        //                   width: 2,
        //                 ),
        //                 borderRadius: BorderRadius.circular(8),
        //               ),
        //               errorBorder: OutlineInputBorder(
        //                 borderSide: BorderSide(
        //                   color: Color(0x00000000),
        //                   width: 2,
        //                 ),
        //                 borderRadius: BorderRadius.circular(8),
        //               ),
        //               focusedErrorBorder: OutlineInputBorder(
        //                 borderSide: BorderSide(
        //                   color: Color(0x00000000),
        //                   width: 2,
        //                 ),
        //                 borderRadius: BorderRadius.circular(8),
        //               ),
        //               filled: true,
        //               fillColor:
        //               FlutterFlowTheme.of(context).secondary,
        //               contentPadding:
        //               EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
        //             ),
        //             style: FlutterFlowTheme.of(context).bodyMedium.override(
        //               fontFamily: 'Plus Jakarta Sans',
        //               letterSpacing: 0,
        //             ),
        //             validator: _model.emailAddressTextControllerValidator
        //                 .asValidator(context),
        //           ),
        //         ),
        //         Padding(
        //           padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
        //           child: FFButtonWidget(
        //             onPressed: () async {
        //               if (_model.emailAddressTextController.text.isEmpty) {
        //                 ScaffoldMessenger.of(context).showSnackBar(
        //                   SnackBar(
        //                     content: Text(
        //                       'Email required!',
        //                     ),
        //                   ),
        //                 );
        //                 return;
        //               }
        //               // await authManager.resetPassword(
        //               //   email: _model.emailAddressTextController.text,
        //               //   context: context,
        //               // );
        //             },
        //             text: FFLocalizations.of(context).getText(
        //               'if4pz6lm' /* Send Reset Link */,
        //             ),
        //             options: FFButtonOptions(
        //               width: 190,
        //               height: 50,
        //               padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        //               iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        //               color: FlutterFlowTheme.of(context).primary,
        //               textStyle:
        //               FlutterFlowTheme.of(context).titleSmall.override(
        //                 fontFamily: 'Plus Jakarta Sans',
        //                 color: FlutterFlowTheme.of(context).primaryText,
        //                 letterSpacing: 0,
        //               ),
        //               elevation: 3,
        //               borderSide: BorderSide(
        //                 color: Colors.transparent,
        //                 width: 1,
        //               ),
        //               borderRadius: BorderRadius.circular(30),
        //             ),
        //           ),
        //         ),
        //       ],
        //     );
        //   },
        // ),
      ),
    );
  }
}
