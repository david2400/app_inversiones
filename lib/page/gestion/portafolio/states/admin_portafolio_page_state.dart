import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/gestion/portafolio/page/admin_portafolio_page.dart';
import 'package:inversiones/ui/utils/form_field_controller.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

class AdminPortafolioPageState extends FlutterFlowModel<AdminPortafolioPage> {
  FocusNode? nombreFocus;
  TextEditingController? nombreController;

  // String? Function(BuildContext, String?)? nombreValidator;

  FocusNode? nroCuentaFocus;
  TextEditingController? nroCuentaController;

  // String? Function(BuildContext, String?)? descripcionValidator;

  FocusNode? descripcionFocus;
  TextEditingController? descripcionController;

  // String? Function(BuildContext, String?)? descripcionValidator;

  String? tipoTransferenciaId;
  FormFieldController<String>? tipoTransferenciaController;

  String? tipoRenta;
  FormFieldController<String>? tipoRentaController;

  int? tipoPortafolioId;
  FormFieldController<int>? tipoPortafolioController;

  FocusNode? interesFocus;
  TextEditingController? interesController;

  // String? Function(BuildContext, String?)? interesValidator;

  int? frecuenciaPagoId;
  FormFieldController<int>? frecuenciaPagoController;

  bool? exentaImpuesto = false;

  /// Cuenta de donde salen los aportes (nula = Efectivo / Sin definir).
  int? cuentaAportesId;

  /// Si los rendimientos llegan a la misma cuenta de aportes.
  bool mismaCuentaRendimientos = true;

  /// Cuenta de rendimientos cuando no es la misma de aportes.
  int? cuentaRendimientosId;

  /// Dinero que ya hay en la cuenta al crearla (opcional).
  final saldoInicialController = TextEditingController();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nombreFocus?.dispose();
    nombreController?.dispose();

    descripcionFocus?.dispose();
    descripcionController?.dispose();

    interesFocus?.dispose();
    interesController?.dispose();
    saldoInicialController.dispose();
  }

  PortafolioDto _initDataPortafolio() {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    return PortafolioDto(
        nombre: nombreController.text,
        nroCuenta: nroCuentaController.text,
        tipoRenta: tipoRenta,
        proyectoId: widget.idProyecto,
        tipoPortafolioId: tipoPortafolioId!,
        interes: int.tryParse(interesController.text),
        exentaImpuesto: exentaImpuesto! ? 'S' : 'N',
        frecuenciaPagoId: frecuenciaPagoId!,
        descripcion: descripcionController.text,
        cuentaAportesId: cuentaAportesId,
        cuentaDestinoId:
            mismaCuentaRendimientos ? null : cuentaRendimientosId,
        createdAt: formattedDateTime);
  }

  /// Cuentas para elegir de dónde salen los aportes y a dónde llegan los
  /// rendimientos.
  Future<List<CuentaDto>> listarCuentas() async {
    try {
      final ICuenta cuentaHandler = CuentaHandler();
      return await cuentaHandler.listarCuentas();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> insertPortafolio() async {
    try {
      PortafolioDto portafolioDto = _initDataPortafolio();

      IPortafolio portafolioHandler = PortafolioHandler();
      int result = await portafolioHandler.createPortafolio(portafolioDto,
          saldoInicial: int.tryParse(saldoInicialController.text) ?? 0);

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
