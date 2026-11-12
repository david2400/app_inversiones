import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

/// Reglas comunes de auditoría y borrado lógico para todas las tablas.
///
/// Centraliza el manejo de `created_at`, `updated_at` y `deleted_at` para que
/// los schemas no repitan esta lógica (DRY).
class Auditoria {
  static const columnaCreatedAt = 'created_at';
  static const columnaUpdatedAt = 'updated_at';
  static const columnaDeletedAt = 'deleted_at';

  /// Condición SQL para obtener solo registros no eliminados.
  static const filtroActivo = '$columnaDeletedAt IS NULL';

  static const formatoFecha = 'yyyy-MM-dd HH:mm:ss';

  Auditoria._();

  static String ahora() => DateFormat(formatoFecha).format(DateTime.now());

  /// Prepara los datos de un INSERT: asigna `created_at` si no viene y
  /// garantiza que el registro nazca activo.
  static Map<String, dynamic> datosCreacion(Map<String, dynamic> datos) {
    final resultado = Map<String, dynamic>.from(datos);
    resultado[columnaCreatedAt] ??= ahora();
    resultado[columnaDeletedAt] = null;
    return resultado;
  }

  /// Prepara los datos de un UPDATE: nunca sobrescribe `created_at` ni
  /// `deleted_at` y actualiza `updated_at`.
  static Map<String, dynamic> datosActualizacion(Map<String, dynamic> datos) {
    final resultado = Map<String, dynamic>.from(datos)
      ..remove(columnaCreatedAt)
      ..remove(columnaDeletedAt);
    resultado[columnaUpdatedAt] = ahora();
    return resultado;
  }

  /// Borrado lógico: marca `deleted_at` en lugar de eliminar la fila.
  static Future<int> borradoLogico(
      DatabaseExecutor db, String tabla, String columnaId, int id) {
    final fecha = ahora();
    return db.update(
      tabla,
      {columnaDeletedAt: fecha, columnaUpdatedAt: fecha},
      where: '$columnaId = ? AND $filtroActivo',
      whereArgs: [id],
    );
  }
}
