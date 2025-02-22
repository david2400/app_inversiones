import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/frecuencia_pago_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/frecuencia_pago_interface.dart';
import 'package:inversiones/page/frecuenciaPago/dto/frecuencia_pago_dto.dart';
import 'package:inversiones/page/frecuenciaPago/page/frecuencia_pago_page.dart';
import 'package:inversiones/ui/utils/flutter_fluw_datatable.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';


class FrecuenciaPagoPageState extends FlutterFlowModel<FrecuenciaPagoPage> {
  final unfocusNode = FocusNode();

  final paginatedDataTableController =
  FlutterFlowDataTableController<dynamic>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<FrecuenciaPagoDto>> listarFrecuenciaPago() async {
    try {
      IFrecuenciaPago frecuenciaPagoHandler = FrecuenciaPagoHandler();

      List<FrecuenciaPagoDto> result =
      await frecuenciaPagoHandler.listarFrecuenciaPago();

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
