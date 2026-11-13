import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/page/admin_transaccion_page.dart';

import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/form_field_controller.dart';

class AdminTransaccionPageState extends FlutterFlowModel<AdminTransaccionPage> {
  FocusNode? valorFocus;
  TextEditingController? valorController;
  int? Function(BuildContext, int?)? valorValidator;

  int? tipoTransferenciaId;
  FormFieldController<int>? tipoTransferenciaController;

  int? motivoId;
  FormFieldController<int>? motivoController;

  int? portafolioId;
  FormFieldController<int>? portafolioController;

  FocusNode? nroCuentaDestinoFocus;
  int? nroCuentaDestinoId;
  FormFieldController<int>? nroCuentaDestinoController;
// String? Function(BuildContext, String?)? valorValidator;

  FocusNode? nroCuentaDestinoAlternativa;
  TextEditingController? nroCuentaDestinoAlternativaController;
  // String? Function(BuildContext, String?)? textController3Validator;

  FocusNode? descripcionFocus;
  TextEditingController? descripcionController;

  bool? cuentaExterma = false;

  TransaccionDto _initDataTransaccion() {
    final valor = int.tryParse(valorController?.text.trim() ?? '');
    if (valor == null || valor <= 0) {
      throw Exception('Ingrese un valor numérico mayor a cero');
    }
    if (tipoTransferenciaId == null || tipoTransferenciaId == 0) {
      throw Exception('Seleccione el tipo de transacción');
    }
    if (portafolioId == null || portafolioId == 0) {
      throw Exception('Seleccione el portafolio');
    }
    String formattedDateTime = Auditoria.ahora();
    return TransaccionDto(
        valor: valor,
        tipoTransferenciaId: tipoTransferenciaId!,
        // El dropdown usa 0 como "sin selección".
        motivoId: (motivoId ?? 0) > 0 ? motivoId : null,
        portafolioId: portafolioId!,
        destinoCuenta: nroCuentaDestinoId,
        destinoAlternativo: nroCuentaDestinoAlternativaController?.text,
        descripcion: descripcionController?.text,
        createdAt: formattedDateTime);
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    valorFocus?.dispose();
    valorController?.dispose();

    nroCuentaDestinoFocus?.dispose();
    nroCuentaDestinoController?.dispose();

    nroCuentaDestinoAlternativa?.dispose();
    nroCuentaDestinoAlternativaController?.dispose();

    descripcionFocus?.dispose();
    descripcionController?.dispose();
  }

  Future<int> insertTransaccion() async {
    try {
      TransaccionDto transaccion = _initDataTransaccion();
      ITransaccion tipoTransaccionHandler = TransaccionHandler();
      int result = await tipoTransaccionHandler.createTransaccion(transaccion);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PortafolioDto>> listarPortafolios() async {
    try {
      IPortafolio portafolioHandler = PortafolioHandler();

      List<PortafolioDto> result = await portafolioHandler.listarPortafolios();

      return result.isEmpty ? [] : result;
    } catch (e) {
      rethrow;
    }
  }
}
