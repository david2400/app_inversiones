import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/motivo_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/motivo_interface.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:inversiones/page/motivos/page/admin_motivos_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

/// Orquesta el alta y la edición de un motivo.
class AdminMotivosPageState extends FlutterFlowModel<AdminMotivosPage> {
  final IMotivo _motivoHandler = MotivoHandler();

  final nombreFocus = FocusNode();
  final nombreController = TextEditingController();
  final descripcionFocus = FocusNode();
  final descripcionController = TextEditingController();

  /// `I`, `E` o nula (ambos).
  String? naturaleza;

  /// Motivo que se está editando (`null` al crear).
  MotivosDto? motivoEditado;

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
      final motivo = await _motivoHandler.obtenerMotivo(id);
      motivoEditado = motivo;
      nombreController.text = motivo.nombre;
      descripcionController.text = motivo.descripcion;
      naturaleza = motivo.naturaleza;
    } catch (e) {
      rethrow;
    }
  }

  bool hayCambios() {
    final original = motivoEditado;
    if (original == null) {
      return nombreController.text.trim().isNotEmpty ||
          descripcionController.text.trim().isNotEmpty ||
          naturaleza != null;
    }
    return nombreController.text.trim() != original.nombre ||
        descripcionController.text.trim() != original.descripcion ||
        naturaleza != original.naturaleza;
  }

  Future<int> guardar() async {
    try {
      final editado = motivoEditado;
      return await _motivoHandler.guardarMotivo(MotivosDto(
        idMotivo: editado?.idMotivo,
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        naturaleza: naturaleza,
        activo: editado?.activo ?? true,
      ));
    } catch (e) {
      rethrow;
    }
  }
}
