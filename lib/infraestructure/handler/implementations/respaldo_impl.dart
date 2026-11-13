import 'dart:io';

import 'package:intl/intl.dart';
import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/config/migraciones.dart';
import 'package:inversiones/config/registro.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/respaldo_interface.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RespaldoHandler implements IRespaldo {
  static const prefijoArchivo = 'inversiones_respaldo_';
  static const extensionArchivo = '.db';
  static const sufijoSeguridad = '.antes_de_restaurar';
  static const extensionSeguridad = '.bak';
  static const formatoMarca = 'yyyyMMdd_HHmmss';

  /// Tablas que debe tener un archivo para considerarse respaldo válido.
  static const tablasRequeridas = [
    TransferenciaShema.table,
    PortafolioSchema.table,
    TipoTransaccionSchema.table,
  ];

  final DatabaseHelper _databaseHelper;

  RespaldoHandler({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  @override
  Future<String> exportar(String directorio) async {
    try {
      final origen = File(await _databaseHelper.rutaArchivo());
      if (!await origen.exists()) {
        throw Exception('Aún no hay datos para respaldar');
      }
      // Se cierra la conexión para que el archivo quede completo en disco.
      await _databaseHelper.cerrar();

      final destino = join(directorio, '$prefijoArchivo${_marca()}$extensionArchivo');
      await origen.copy(destino);
      Registro.info('Respaldo creado en $destino');
      return destino;
    } catch (e, pila) {
      Registro.error('RespaldoHandler: error al exportar', e, pila);
      rethrow;
    } finally {
      await _databaseHelper.database;
    }
  }

  @override
  Future<void> restaurar(String archivo) async {
    try {
      await _validar(archivo);

      final ruta = await _databaseHelper.rutaArchivo();
      await _databaseHelper.cerrar();

      final actual = File(ruta);
      if (await actual.exists()) {
        await actual.copy('$ruta$sufijoSeguridad.${_marca()}$extensionSeguridad');
      }
      await File(archivo).copy(ruta);
      Registro.info('Base de datos restaurada desde $archivo');
    } catch (e, pila) {
      Registro.error('RespaldoHandler: error al restaurar', e, pila);
      rethrow;
    } finally {
      // Reabre; si el respaldo es de una versión anterior, se migra.
      await _databaseHelper.database;
    }
  }

  Future<void> _validar(String archivo) async {
    if (!await File(archivo).exists()) {
      throw Exception('El archivo seleccionado no existe');
    }
    Database? db;
    int version;
    Set<Object?> tablas;
    try {
      db = await openDatabase(archivo, readOnly: true, singleInstance: false);
      version = await db.getVersion();
      tablas = (await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type = 'table'"))
          .map((fila) => fila['name'])
          .toSet();
    } on DatabaseException {
      throw Exception('El archivo no es una base de datos válida');
    } finally {
      await db?.close();
    }

    if (!tablasRequeridas.every(tablas.contains)) {
      throw Exception('El archivo no es un respaldo de Inversiones');
    }
    if (version > Migraciones.versionActual) {
      throw Exception(
          'El respaldo es de una versión más nueva de la app; actualízala primero');
    }
    if (version < Migraciones.versionMinimaMigrable) {
      throw Exception('El respaldo es de una versión de la app no compatible');
    }
  }

  static String _marca() => DateFormat(formatoMarca).format(DateTime.now());
}
