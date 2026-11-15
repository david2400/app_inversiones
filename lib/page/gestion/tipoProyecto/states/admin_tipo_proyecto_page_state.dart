import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/tipo_proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_proyecto_interface.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:inversiones/page/gestion/tipoProyecto/page/admin_tipo_proyecto_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

/// Orquesta el alta y la edición de un tipo de proyecto.
class AdminTipoProyectoPageState
    extends FlutterFlowModel<AdminTipoProyectoPage> {
  final ITipoProyecto _tipoProyectoHandler = TipoProyectoHandler();

  final nombreFocus = FocusNode();
  final nombreController = TextEditingController();
  final descripcionFocus = FocusNode();
  final descripcionController = TextEditingController();

  /// Ver `NivelRiesgo` (nulo = sin definir).
  String? riesgo;

  /// Tipo que se está editando (`null` al crear).
  TipoProyectoDto? tipoEditado;

  bool get editando => tipoEditado != null;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nombreFocus.dispose();
    nombreController.dispose();
    descripcionFocus.dispose();
    descripcionController.dispose();
  }

  /// Carga el tipo [id] en el formulario.
  Future<void> cargar(int id) async {
    try {
      final tipo = await _tipoProyectoHandler.obtenerTipoProyecto(id);
      tipoEditado = tipo;
      nombreController.text = tipo.nombre;
      descripcionController.text = tipo.descripcion;
      riesgo = tipo.riesgo;
    } catch (e) {
      rethrow;
    }
  }

  /// Si el usuario cambió algo respecto a lo cargado.
  bool hayCambios() {
    final original = tipoEditado;
    if (original == null) {
      return nombreController.text.trim().isNotEmpty ||
          descripcionController.text.trim().isNotEmpty ||
          riesgo != null;
    }
    return nombreController.text.trim() != original.nombre ||
        descripcionController.text.trim() != original.descripcion ||
        riesgo != original.riesgo;
  }

  /// Crea o actualiza el tipo. Retorna su id.
  Future<int> guardar() async {
    try {
      return await _tipoProyectoHandler.guardarTipoProyecto(TipoProyectoDto(
        idTipoProyecto: tipoEditado?.idTipoProyecto,
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        riesgo: riesgo,
      ));
    } catch (e) {
      rethrow;
    }
  }
}
