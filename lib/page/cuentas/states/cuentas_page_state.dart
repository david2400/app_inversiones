import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/cuentas/page/cuentas_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class CuentasPageState extends FlutterFlowModel<CuentasPage> {
  final ICuenta _cuentaHandler = CuentaHandler();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<List<CuentaDto>> listar() async {
    try {
      return await _cuentaHandler.listarCuentas();
    } catch (e) {
      rethrow;
    }
  }
}
