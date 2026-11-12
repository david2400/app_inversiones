import 'package:sqflite/sqflite.dart';

/// Migraciones versionadas y NO destructivas de la base de datos.
///
/// Reglas:
/// - Cada versión nueva agrega su lista de sentencias en [_pasos].
/// - Una migración publicada nunca se modifica; los cambios van en una
///   versión nueva.
/// - El DDL de cada paso se escribe "congelado" (no se reutiliza el
///   `createTableQuery` actual), porque el schema seguirá evolucionando.
/// - Para cambios que SQLite no soporta con ALTER TABLE (renombrar o cambiar
///   tipos de columnas) se usa: crear tabla nueva → copiar → borrar → renombrar.
class Migraciones {
  /// Versión actual del esquema.
  static const versionActual = 17;

  /// Versiones anteriores a esta no tienen migración: se recrean
  /// (comportamiento heredado de las versiones previas de la app).
  static const versionMinimaMigrable = 16;

  Migraciones._();

  /// Índices del esquema actual. Se crean en instalaciones nuevas y en la
  /// migración a v17.
  static const indices = [
    'CREATE INDEX IF NOT EXISTS idx_transferencias_portafolio ON transferencias(portafolio_id)',
    'CREATE INDEX IF NOT EXISTS idx_transferencias_destino ON transferencias(destino_cuenta)',
    'CREATE INDEX IF NOT EXISTS idx_transferencias_tipo ON transferencias(tipo_transferencia_id)',
    'CREATE INDEX IF NOT EXISTS idx_transferencias_motivo ON transferencias(motivo_id)',
    'CREATE INDEX IF NOT EXISTS idx_transferencias_fecha ON transferencias(created_at)',
    'CREATE INDEX IF NOT EXISTS idx_portafolios_proyecto ON portafolios(proyecto_id)',
  ];

  static final Map<int, List<String>> _pasos = {
    17: [
      // usuarios: las columnas fecha_nacimiento, email y password se habían
      // creado con nombres equivocados (motivo, destino_alternativo,
      // descripcion). Se reconstruye la tabla preservando los datos.
      'CREATE TABLE usuarios_v17 ('
          'id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,'
          'nombre TEXT NULL,'
          'apellido TEXT NULL,'
          'fecha_nacimiento TEXT NULL,'
          'email TEXT NOT NULL,'
          'password TEXT NOT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL'
          ')',
      'INSERT INTO usuarios_v17 (id_usuario, nombre, apellido, fecha_nacimiento, '
          'email, password, created_at, updated_at, deleted_at) '
          'SELECT id_usuario, nombre, apellido, motivo, destino_alternativo, '
          'descripcion, created_at, updated_at, deleted_at FROM usuarios',
      'DROP TABLE usuarios',
      'ALTER TABLE usuarios_v17 RENAME TO usuarios',
      ...indices,
    ],
  };

  /// Ejecuta en orden todos los pasos entre [desde] (exclusivo) y
  /// [hasta] (inclusivo). sqflite ya ejecuta `onUpgrade` dentro de una
  /// transacción, por lo que un fallo revierte la migración completa.
  static Future<void> migrar(DatabaseExecutor db, int desde, int hasta) async {
    for (var version = desde + 1; version <= hasta; version++) {
      final pasos = _pasos[version];
      if (pasos == null) {
        throw StateError('No existe migración definida para la versión $version');
      }
      for (final sentencia in pasos) {
        await db.execute(sentencia);
      }
    }
  }
}
