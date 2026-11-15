import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/tipo_proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/proyecto_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_proyecto_interface.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/page/gestion/proyecto/page/admin_proyect_page.dart';

import 'package:inversiones/ui/utils/flutter_flow_util.dart';

class AdminProyectPageState extends FlutterFlowModel<AdminProyectPage> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? nombreFocus;
  TextEditingController? nombreController;

  // String? Function(BuildContext, String?)? textController1Validator;



  // State field(s) for TextField widget.
  FocusNode? descripcionFocus;
  TextEditingController? descripcionController;

  // String? Function(BuildContext, String?)? textController1Validator;



  /// Tipo elegido (nulo = sin clasificar).
  int? tipoProyectoId;

  /// Tipos disponibles para elegir.
  List<TipoProyectoDto> tipos = [];

  Future<void> cargarTipos() async {
    try {
      final ITipoProyecto tipoProyectoHandler = TipoProyectoHandler();
      tipos = await tipoProyectoHandler.listarTipoProyecto();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nombreFocus?.dispose();
    nombreController?.dispose();

    descripcionFocus?.dispose();
    descripcionController?.dispose();

  }

  ProyectoDto _initDataProyecto() {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    return ProyectoDto(
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        createdAt: formattedDateTime,
        tipoProyectoId: tipoProyectoId,
        usuarioId: 1);
  }

  /// Proyecto que se está editando (`null` al crear).
  ProyectoDto? proyectoEditado;

  /// Carga el proyecto [id] en los campos del formulario.
  Future<void> cargarProyecto(int id) async {
    final IProyecto proyectoHandler = ProyectoHandler();
    final proyecto = await proyectoHandler.obtenerProyecto(id);
    proyectoEditado = proyecto;
    nombreController?.text = proyecto.nombre;
    descripcionController?.text = proyecto.descripcion;
    tipoProyectoId = proyecto.tipoProyectoId;
  }

  /// Crea el proyecto o guarda los cambios si se está editando.
  Future<int> guardarProyecto() async {
    final editado = proyectoEditado;
    if (editado == null) return insertProyecto();
    final IProyecto proyectoHandler = ProyectoHandler();
    return proyectoHandler.actualizarProyecto(ProyectoDto(
      idProyecto: editado.idProyecto,
      nombre: nombreController!.text,
      descripcion: descripcionController!.text,
      tipoProyectoId: tipoProyectoId,
      usuarioId: editado.usuarioId,
    ));
  }

  Future<int> insertProyecto() async {
    try {
      ProyectoDto proyecto = _initDataProyecto();

      IProyecto tipoProyectoHandler = ProyectoHandler();
      int result = await tipoProyectoHandler.createProyecto(proyecto);

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
