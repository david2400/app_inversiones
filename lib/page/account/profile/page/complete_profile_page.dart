import 'package:flutter/material.dart';
import 'package:inversiones/page/account/profile/states/complete_profile_state.dart';
import 'package:inversiones/ui/utils/animation.dart';
import 'package:inversiones/ui/utils/flutter_flow_animations.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/upload_data.dart';


class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage>
    with TickerProviderStateMixin {
  late CompleteProfilestate  _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompleteProfilestate());

    _model.yourNameTextController ??= TextEditingController();
    _model.yourNameFocusNode ??= FocusNode();

    _model.yourAgeTextController ??= TextEditingController();
    _model.yourAgeFocusNode ??= FocusNode();

    _model.yourTitleTextController ??= TextEditingController();
    _model.yourTitleFocusNode ??= FocusNode();

    final animeinfo = AnimationInfo(
        // Valor por defecto
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => createAnimationEffects(
              fadeBegin: 0.0,
              fadeEnd: 1.0,
              moveBegin: Offset(0.0, 0.0),
              moveEnd: Offset(0.0, 0.0),
              scaleBegin: Offset(1.0, 1.0),
              scaleEnd: Offset(1.0, 1.0),
              delay: Duration(milliseconds: 0),
            ));

    animationsMap.addAll({
      'circleImageOnPageLoadAnimation':
          getAnimaciones('circleImageOnPageLoadAnimation') ?? animeinfo,
      'textOnPageLoadAnimation':
          getAnimaciones('textOnPageLoadAnimation') ?? animeinfo,
      'textFieldOnPageLoadAnimation3':
          getAnimaciones('textFieldOnPageLoadAnimation3') ?? animeinfo,
      'textFieldOnPageLoadAnimation1':
          getAnimaciones('textFieldOnPageLoadAnimation1') ?? animeinfo,
      'textFieldOnPageLoadAnimation2':
          getAnimaciones('textFieldOnPageLoadAnimation2') ?? animeinfo,
    });

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
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
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        automaticallyImplyLeading: false,
        title: Text(
          FFLocalizations.of(context).getText(
            'yhcaf7r2' /* Complete Profile */,
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
        child: Form(
          key: _model.formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      final selectedMedia =
                          await selectMediaWithSourceBottomSheet(
                        context: context,
                        allowPhoto: true,
                        backgroundColor: FlutterFlowTheme.of(context).tertiary,
                        textColor: FlutterFlowTheme.of(context).primaryText,
                        pickerFontFamily: 'Lexend Deca',
                      );
                      if (selectedMedia != null &&
                          selectedMedia.every((m) =>
                              validateFileFormat(m.storagePath, context))) {
                        setState(() => _model.isDataUploading = true);
                        var selectedUploadedFiles = <FFUploadedFile>[];

                        var downloadUrls = <String>[];
                        try {
                          showUploadMessage(
                            context,
                            'Uploading file...',
                            showLoading: true,
                          );
                          selectedUploadedFiles = selectedMedia
                              .map((m) => FFUploadedFile(
                                    name: m.storagePath.split('/').last,
                                    bytes: m.bytes,
                                    height: m.dimensions?.height,
                                    width: m.dimensions?.width,
                                    blurHash: m.blurHash,
                                  ))
                              .toList();

                          // downloadUrls = (await Future.wait(
                          //   selectedMedia.map(
                          //         (m) async =>
                          //     await uploadData(m.storagePath, m.bytes),
                          //   ),
                          // ))
                          //     .where((u) => u != null)
                          //     .map((u) => u!)
                          //     .toList();
                        } finally {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          _model.isDataUploading = false;
                        }
                        if (selectedUploadedFiles.length ==
                                selectedMedia.length &&
                            downloadUrls.length == selectedMedia.length) {
                          setState(() {
                            _model.uploadedLocalFile =
                                selectedUploadedFiles.first;
                            _model.uploadedFileUrl = downloadUrls.first;
                          });
                          showUploadMessage(context, 'Success!');
                        } else {
                          setState(() {});
                          showUploadMessage(context, 'Failed to upload data');
                          return;
                        }
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.network(
                        valueOrDefault<String>(
                          _model.uploadedFileUrl,
                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/finance-app-sample-kugwu4/assets/ijvuhvqbvns6/uiAvatar@2x.png',
                        ),
                      ),
                    ),
                  ).animateOnPageLoad(
                      animationsMap['circleImageOnPageLoadAnimation']!),
                ),
                Text(
                  FFLocalizations.of(context).getText(
                    'r6npjsue' /* Upload a photo for us to easil... */,
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Plus Jakarta Sans',
                        letterSpacing: 0,
                      ),
                ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation']!),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                  child: TextFormField(
                    controller: _model.yourNameTextController,
                    focusNode: _model.yourNameFocusNode,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: FFLocalizations.of(context).getText(
                        'sdptn7dd' /* Your Name */,
                      ),
                      labelStyle:
                          FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'Plus Jakarta Sans',
                                letterSpacing: 0,
                              ),
                      hintStyle:
                          FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'Plus Jakarta Sans',
                                letterSpacing: 0,
                              ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor:
                          FlutterFlowTheme.of(context).secondary,
                      contentPadding:
                          EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Plus Jakarta Sans',
                          letterSpacing: 0,
                        ),
                    validator: _model.yourNameTextControllerValidator
                        .asValidator(context),
                  ).animateOnPageLoad(
                      animationsMap['textFieldOnPageLoadAnimation1']!),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                  child: TextFormField(
                    controller: _model.yourAgeTextController,
                    focusNode: _model.yourAgeFocusNode,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: FFLocalizations.of(context).getText(
                        'n636qnrx' /* Your Age */,
                      ),
                      labelStyle:
                          FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'Plus Jakarta Sans',
                                letterSpacing: 0,
                              ),
                      hintText: FFLocalizations.of(context).getText(
                        's7yvjzbs' /* i.e. 34 */,
                      ),
                      hintStyle:
                          FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'Plus Jakarta Sans',
                                letterSpacing: 0,
                              ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor:
                          FlutterFlowTheme.of(context).secondary,
                      contentPadding:
                          EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Plus Jakarta Sans',
                          letterSpacing: 0,
                        ),
                    keyboardType: TextInputType.number,
                    validator: _model.yourAgeTextControllerValidator
                        .asValidator(context),
                  ).animateOnPageLoad(
                      animationsMap['textFieldOnPageLoadAnimation2']!),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                  child: TextFormField(
                    controller: _model.yourTitleTextController,
                    focusNode: _model.yourTitleFocusNode,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: FFLocalizations.of(context).getText(
                        '72ii0waq' /* Your Title */,
                      ),
                      labelStyle:
                          FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'Plus Jakarta Sans',
                                letterSpacing: 0,
                              ),
                      hintText: FFLocalizations.of(context).getText(
                        'pf8glhkg' /* What is your position? */,
                      ),
                      hintStyle:
                          FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'Plus Jakarta Sans',
                                letterSpacing: 0,
                              ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x00000000),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor:
                          FlutterFlowTheme.of(context).secondary,
                      contentPadding:
                          EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Plus Jakarta Sans',
                          letterSpacing: 0,
                        ),
                    validator: _model.yourTitleTextControllerValidator
                        .asValidator(context),
                  ).animateOnPageLoad(
                      animationsMap['textFieldOnPageLoadAnimation3']!),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
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
                  //     final buttonLoginUsersRecord = snapshot.data!;
                  //     return FFButtonWidget(
                  //       onPressed: () async {
                  //
                  //
                  //         context.pushNamed('onboarding');
                  //       },
                  //       text: FFLocalizations.of(context).getText(
                  //         'hbhd3bdt' /* Complete Profile */,
                  //       ),
                  //       options: FFButtonOptions(
                  //         width: 230,
                  //         height: 50,
                  //         padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  //         iconPadding:
                  //         EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  //         color: FlutterFlowTheme.of(context).primary,
                  //         textStyle: FlutterFlowTheme.of(context)
                  //             .titleSmall
                  //             .override(
                  //           fontFamily: 'Plus Jakarta Sans',
                  //           color: FlutterFlowTheme.of(context).primaryText,
                  //           letterSpacing: 0,
                  //         ),
                  //         elevation: 3,
                  //         borderSide: BorderSide(
                  //           color: Colors.transparent,
                  //           width: 1,
                  //         ),
                  //         borderRadius: BorderRadius.circular(30),
                  //       ),
                  //     ).animateOnPageLoad(
                  //         animationsMap['buttonOnPageLoadAnimation1']!);
                  //   },
                  // ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                  // child: StreamBuilder<UsersRecord>(
                  //   stream: null, //UsersRecord.getDocument(currentUserReference!),
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
                  //     final buttonLoginUsersRecord = snapshot.data!;
                  //     return FFButtonWidget(
                  //       onPressed: () async {
                  //         context.pushNamed('onboarding');
                  //       },
                  //       text: FFLocalizations.of(context).getText(
                  //         'w75dikic' /* Skip for Now */,
                  //       ),
                  //       options: FFButtonOptions(
                  //         width: 140,
                  //         height: 50,
                  //         padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  //         iconPadding:
                  //         EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  //         color:
                  //         FlutterFlowTheme.of(context).secondary,
                  //         textStyle: FlutterFlowTheme.of(context)
                  //             .titleSmall
                  //             .override(
                  //           fontFamily: 'Plus Jakarta Sans',
                  //           color: FlutterFlowTheme.of(context).primaryText,
                  //           letterSpacing: 0,
                  //         ),
                  //         elevation: 0,
                  //         borderSide: BorderSide(
                  //           color: Colors.transparent,
                  //           width: 1,
                  //         ),
                  //         borderRadius: BorderRadius.circular(30),
                  //       ),
                  //     ).animateOnPageLoad(
                  //         animationsMap['buttonOnPageLoadAnimation2']!);
                  //   },
                  // ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
