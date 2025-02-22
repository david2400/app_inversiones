import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
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
        createdAt: formattedDateTime);
  }

  Future<int> insertPortafolio() async {
    try {
      PortafolioDto portafolioDto = _initDataPortafolio();

      IPortafolio portafolioHandler = PortafolioHandler();
      int result = await portafolioHandler.createPortafolio(portafolioDto);

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
