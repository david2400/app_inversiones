import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';
import '../../../../auth/firebase_auth/auth_util.dart';
import 'package:inversiones/page/auth/login/page/change_password_page.dart';


class ChangePasswordstate extends FlutterFlowModel<ChangePasswordPage> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
  }
}
