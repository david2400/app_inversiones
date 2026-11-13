import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/cuentas/page/admin_cuenta_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class AdminCuentaPageState extends FlutterFlowModel<AdminCuentaPage> {
  final ICuenta _cuentaHandler = CuentaHandler();

  final nombreController = TextEditingController();
  final entidadController = TextEditingController();
  final nroCuentaController = TextEditingController();
  final saldoInicialController = TextEditingController();
  final descripcionController = TextEditingController();

  String? tipoCuenta;
  bool exenta = false;

  /// Cuenta que se edita (nula al crear).
  CuentaDto? cuenta;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nombreController.dispose();
    entidadController.dispose();
    nroCuentaController.dispose();
    saldoInicialController.dispose();
    descripcionController.dispose();
  }

  /// Carga la cuenta [idCuenta] en el formulario.
  Future<void> cargar(int idCuenta) async {
    try {
      final dto = await _cuentaHandler.obtenerCuenta(idCuenta);
      cuenta = dto;
      nombreController.text = dto.nombre;
      entidadController.text = dto.entidad ?? '';
      nroCuentaController.text = dto.nroCuenta ?? '';
      descripcionController.text = dto.descripcion ?? '';
      tipoCuenta = dto.tipoCuenta;
      exenta = dto.exentaImpuesto == 'S';
    } catch (e) {
      rethrow;
    }
  }

  bool get hayCambios =>
      cuenta == null &&
      (nombreController.text.trim().isNotEmpty ||
          entidadController.text.trim().isNotEmpty ||
          nroCuentaController.text.trim().isNotEmpty ||
          saldoInicialController.text.trim().isNotEmpty);

  Future<int> guardar() async {
    try {
      final saldoTexto = saldoInicialController.text.trim();
      return await _cuentaHandler.guardarCuenta(
        CuentaDto(
          idCuenta: cuenta?.idCuenta,
          nombre: nombreController.text,
          tipoCuenta: tipoCuenta ?? '',
          entidad: entidadController.text,
          nroCuenta: nroCuentaController.text,
          exentaImpuesto: exenta ? 'S' : 'N',
          descripcion: descripcionController.text,
          createdAt: cuenta?.createdAt,
        ),
        saldoInicial: saldoTexto.isEmpty ? 0 : int.parse(saldoTexto),
      );
    } catch (e) {
      rethrow;
    }
  }
}
