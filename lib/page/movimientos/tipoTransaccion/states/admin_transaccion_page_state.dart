import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/tipo_transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_transaccion_interface.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/page/admin_tipo_transaccion.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

/// Orquesta el alta y la edición de un tipo de transacción.
class AdminTipoTransaccionPageState
    extends FlutterFlowModel<AdminTipoTransaccionPage> {
  final ITipoTransaccion _tipoHandler = TipoTransaccionHandler();

  final nombreFocus = FocusNode();
  final nombreController = TextEditingController();
  final descripcionFocus = FocusNode();
  final descripcionController = TextEditingController();

  /// Naturaleza elegida (ver `TipoFuente`).
  String? tipoFuente;

  /// Tipo que se está editando (`null` al crear).
  TipoTransaccionDto? tipoEditado;

  bool get editando => tipoEditado != null;

  /// La naturaleza no se cambia en los tipos del sistema ni en los que ya
  /// tienen movimientos (cambiaría los saldos).
  bool get naturalezaBloqueada {
    final tipo = tipoEditado;
    return tipo != null && (tipo.esSistema || tipo.cantidadMovimientos > 0);
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nombreFocus.dispose();
    nombreController.dispose();
    descripcionFocus.dispose();
    descripcionController.dispose();
  }

  Future<void> cargar(int id) async {
    try {
      final tipo = await _tipoHandler.obtenerTipoTransaccion(id);
      tipoEditado = tipo;
      nombreController.text = tipo.nombre;
      descripcionController.text = tipo.descripcion;
      tipoFuente = tipo.tipoFuente;
    } catch (e) {
      rethrow;
    }
  }

  bool hayCambios() {
    final original = tipoEditado;
    if (original == null) {
      return nombreController.text.trim().isNotEmpty ||
          descripcionController.text.trim().isNotEmpty ||
          tipoFuente != null;
    }
    return nombreController.text.trim() != original.nombre ||
        descripcionController.text.trim() != original.descripcion ||
        tipoFuente != original.tipoFuente;
  }

  Future<int> guardar() async {
    try {
      final editado = tipoEditado;
      return await _tipoHandler.guardarTipoTransaccion(TipoTransaccionDto(
        idTipoTransaccion: editado?.idTipoTransaccion,
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        tipoFuente: tipoFuente ?? '',
        activo: editado?.activo ?? true,
      ));
    } catch (e) {
      rethrow;
    }
  }
}
