import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/tipo_proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_proyecto_interface.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/page/tipo_transaccion.dart';
import 'package:inversiones/ui/utils/flutter_fluw_datatable.dart';

import 'package:inversiones/ui/utils/flutter_flow_util.dart';



class TipoProyectoPageState extends FlutterFlowModel<TipoTransaccionPage> {
  final paginatedDataTableController =
      FlutterFlowDataTableController<dynamic>();

  @override
  void initState(BuildContext context) async {
  }



  @override
  void dispose() {
    paginatedDataTableController.dispose();
  }

  Future<List<TipoProyectoDto>> listarTipoProyectos() async {
    try {
      ITipoProyecto tipoProyectoHandler = TipoProyectoHandler();

      List<TipoProyectoDto> result =
          await tipoProyectoHandler.listarTipoProyecto();
      return result.isEmpty ? [] : result;
    } catch (e) {
      rethrow;
    }
  }


}
