import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/motivo_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/motivo_interface.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:inversiones/page/motivos/page/motivos_page.dart';
import 'package:inversiones/ui/utils/flutter_fluw_datatable.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';



class MotivosPageState extends FlutterFlowModel<MotivosPage> {
  final unfocusNode = FocusNode();

  final paginatedDataTableController =
  FlutterFlowDataTableController<dynamic>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  // String? nombreValidator(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'La descripción no puede estar vacía';
  //   }
  //   if (value.length < 3) {
  //     return 'Debe tener al menos 3 caracteres';
  //   }
  //   return null;
  // }

  Future<List<MotivosDto>> listarMotivos() async {
    try {
      IMotivo tipoTransaccionHandler = MotivoHandler();

      List<MotivosDto> result =
      await tipoTransaccionHandler.listarMotivos();

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
