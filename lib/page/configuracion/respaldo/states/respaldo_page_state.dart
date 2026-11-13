import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/respaldo_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/respaldo_interface.dart';
import 'package:inversiones/page/configuracion/respaldo/page/respaldo_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class RespaldoPageState extends FlutterFlowModel<RespaldoPage> {
  final IRespaldo _respaldoHandler = RespaldoHandler();

  bool procesando = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  /// Pide una carpeta y guarda allí la copia. Retorna la ruta del archivo
  /// creado o `null` si el usuario canceló.
  Future<String?> exportar(String tituloDialogo) async {
    try {
      final directorio = await FilePicker.platform
          .getDirectoryPath(dialogTitle: tituloDialogo);
      if (directorio == null) return null;
      return await _respaldoHandler.exportar(directorio);
    } catch (e) {
      rethrow;
    }
  }

  /// Pide un archivo de respaldo y lo restaura. Retorna `false` si el
  /// usuario canceló.
  Future<bool> restaurar(String tituloDialogo) async {
    try {
      final seleccion = await FilePicker.platform.pickFiles(
          dialogTitle: tituloDialogo, allowMultiple: false);
      final ruta = seleccion?.files.single.path;
      if (ruta == null) return false;
      await _respaldoHandler.restaurar(ruta);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
