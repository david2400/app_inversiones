import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:inversiones/infraestructure/handler/implementations/exportacion_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/respaldo_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/exportacion_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/respaldo_interface.dart';
import 'package:inversiones/page/configuracion/respaldo/page/respaldo_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

class RespaldoPageState extends FlutterFlowModel<RespaldoPage> {
  final IRespaldo _respaldoHandler = RespaldoHandler();
  final IExportacion _exportacionHandler = ExportacionHandler();

  bool procesando = false;
  PeriodoExportacion periodoCsv = PeriodoExportacion.mesActual;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  /// En Android e iOS las apps no pueden escribir en cualquier carpeta:
  /// el archivo se genera en temporales y el sistema lo guarda donde el
  /// usuario elija ("Guardar como"). En escritorio se elige la carpeta.
  static bool get _esMovil =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Genera el archivo con [generar] (que recibe la carpeta destino) y lo
  /// guarda. Retorna la ruta o nombre del archivo guardado, o `null` si el
  /// usuario canceló.
  Future<String?> _guardar(String tituloDialogo,
      Future<String> Function(String directorio) generar) async {
    if (!_esMovil) {
      final directorio =
          await FilePicker.platform.getDirectoryPath(dialogTitle: tituloDialogo);
      if (directorio == null) return null;
      return generar(directorio);
    }
    final temporal = await getTemporaryDirectory();
    final archivo = File(await generar(temporal.path));
    try {
      final guardado = await FilePicker.platform.saveFile(
        dialogTitle: tituloDialogo,
        fileName: p.basename(archivo.path),
        bytes: await archivo.readAsBytes(),
      );
      // Algunos proveedores devuelven una URI en vez de una ruta.
      return guardado == null ? null : p.basename(archivo.path);
    } finally {
      if (await archivo.exists()) await archivo.delete();
    }
  }

  /// Guarda una copia completa de la base de datos. Retorna dónde quedó o
  /// `null` si el usuario canceló.
  Future<String?> exportar(String tituloDialogo) async {
    try {
      return await _guardar(tituloDialogo, _respaldoHandler.exportar);
    } catch (e) {
      rethrow;
    }
  }

  /// Guarda el CSV del periodo elegido.
  Future<String?> exportarCsv(String tituloDialogo) async {
    try {
      return await _guardar(
          tituloDialogo,
          (directorio) => _exportacionHandler.exportarMovimientosCsv(
              directorio: directorio, periodo: periodoCsv));
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
