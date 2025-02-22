
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/home/page/home_page.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_portafolio_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

import '../../../auth/firebase_auth/auth_util.dart';
// import '../../backend/schema/firebase/backend.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePageState extends FlutterFlowModel<HomePage> {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<TransaccionDto>> getAllTransaccion() async {
    try {
      ITransaccion transaccionHandler = TransaccionHandler();

      List<TransaccionDto> result = await transaccionHandler.listaTransacciones();

      return result.isEmpty ? [] : result;
    } catch (e) {
      rethrow;
    }
  }
}
