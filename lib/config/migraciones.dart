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
  static const versionActual = 32;

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

  /// Índices agregados en la versión 19.
  static const indicesV19 = [
    'CREATE INDEX IF NOT EXISTS idx_transferencias_tercero ON transferencias(tercero_id)',
  ];

  /// Catálogos base para empezar a registrar sin configurar nada. Solo se
  /// insertan si la tabla está vacía, así no tocan catálogos existentes.
  static const datosIniciales = [
    'INSERT INTO tipo_transferencia (nombre, descripcion, tipo_fuente, created_at) '
        'SELECT * FROM (VALUES '
        "('Ingreso', 'Dinero que entra a una de tus cuentas', 'I', datetime('now', 'localtime')), "
        "('Egreso', 'Dinero que sale de una de tus cuentas', 'E', datetime('now', 'localtime')), "
        "('Transferencia', 'Movimiento entre tus cuentas o hacia una cuenta externa', 'M', datetime('now', 'localtime'))"
        ') WHERE NOT EXISTS (SELECT 1 FROM tipo_transferencia)',
    'INSERT INTO motivos (nombre, descripcion, created_at) '
        'SELECT * FROM (VALUES '
        "('Salario', '', datetime('now', 'localtime')), "
        "('Honorarios y servicios', '', datetime('now', 'localtime')), "
        "('Arriendos recibidos', '', datetime('now', 'localtime')), "
        "('Rendimientos e intereses', '', datetime('now', 'localtime')), "
        "('Mercado', '', datetime('now', 'localtime')), "
        "('Servicios públicos', '', datetime('now', 'localtime')), "
        "('Arriendo y vivienda', '', datetime('now', 'localtime')), "
        "('Transporte', '', datetime('now', 'localtime')), "
        "('Salud', '', datetime('now', 'localtime')), "
        "('Educación', '', datetime('now', 'localtime')), "
        "('Entretenimiento', '', datetime('now', 'localtime')), "
        "('Ahorro e inversión', '', datetime('now', 'localtime')), "
        "('Deudas y créditos', '', datetime('now', 'localtime')), "
        "('Impuestos', '', datetime('now', 'localtime')), "
        "('Otros', '', datetime('now', 'localtime'))"
        ') WHERE NOT EXISTS (SELECT 1 FROM motivos)',
  ];

  /// Todos los índices del esquema actual (instalaciones nuevas).
  /// Índices agregados en la versión 22.
  static const indicesV22 = [
    'CREATE INDEX IF NOT EXISTS idx_transferencias_recurrente ON transferencias(recurrente_id)',
  ];

  /// Índices agregados en la versión 23.
  static const indicesV23 = [
    // Lista de movimientos de una cuenta ordenada por fecha.
    'CREATE INDEX IF NOT EXISTS idx_transferencias_portafolio_fecha ON transferencias(portafolio_id, created_at)',
  ];

  /// Índices agregados en la versión 24 (cuentas).
  static const indicesV24 = [
    'CREATE INDEX IF NOT EXISTS idx_transferencias_cuenta ON transferencias(cuenta_id)',
    'CREATE INDEX IF NOT EXISTS idx_transferencias_cuenta_destino ON transferencias(cuenta_destino_id)',
    'CREATE INDEX IF NOT EXISTS idx_transferencias_cuenta_fecha ON transferencias(cuenta_id, created_at)',
    indicePortafoliosCuentaDestino,
  ];

  static const indicePortafoliosCuentaDestino =
      'CREATE INDEX IF NOT EXISTS idx_portafolios_cuenta_destino ON portafolios(cuenta_destino_id)';

  /// Datos base de la versión 24: la cuenta "Efectivo / Sin definir" debe
  /// ser la primera fila de `cuentas` (id 1, ver `CuentaSchema.idEfectivo`).
  static const datosInicialesV24 = [
    'INSERT INTO cuentas (nombre, tipo_cuenta, exenta_impuesto, descripcion, created_at) '
        "SELECT 'Efectivo / Sin definir', 'E', 'S', "
        "'Dinero en efectivo o que llegó sin una cuenta definida', "
        "datetime('now', 'localtime') "
        'WHERE NOT EXISTS (SELECT 1 FROM cuentas)',
  ];

  /// Índices agregados en la versión 25 (portafolios de cuentas).
  static const indicesV25 = [
    'CREATE INDEX IF NOT EXISTS idx_portafolios_cuenta ON portafolios(cuenta_id)',
    // Una cuenta tiene un solo portafolio principal activo.
    'CREATE UNIQUE INDEX IF NOT EXISTS idx_portafolios_principal '
        'ON portafolios(cuenta_id) WHERE es_principal = 1 AND deleted_at IS NULL',
  ];

  /// Datos base de la versión 25: cada cuenta tiene su portafolio
  /// principal, que es donde se registran sus movimientos.
  static const datosInicialesV25 = [
    'INSERT INTO portafolios (nombre, cuenta_id, es_principal, interes, '
        'exenta_impuesto, created_at) '
        'SELECT c.nombre, c.id_cuenta, 1, 0, c.exenta_impuesto, '
        "datetime('now', 'localtime') FROM cuentas c "
        'WHERE c.deleted_at IS NULL AND NOT EXISTS (SELECT 1 FROM portafolios p '
        'WHERE p.cuenta_id = c.id_cuenta AND p.es_principal = 1 '
        'AND p.deleted_at IS NULL)',
  ];

  /// Índices agregados en la versión 27 (aportes programados).
  static const indicesV27 = [
    // Un portafolio tiene a lo sumo un aporte programado activo.
    'CREATE UNIQUE INDEX IF NOT EXISTS idx_recurrentes_aporte '
        'ON recurrentes(aporte_portafolio_id) '
        'WHERE aporte_portafolio_id IS NOT NULL AND deleted_at IS NULL',
  ];

  /// Índices de metas de ahorro (versión 32).
  static const indicesV32 = [
    // Un portafolio pertenece a lo sumo a una meta: su saldo no se cuenta
    // dos veces.
    'CREATE UNIQUE INDEX IF NOT EXISTS idx_metas_portafolio_unico '
        'ON metas_portafolios(portafolio_id) WHERE deleted_at IS NULL',
    'CREATE INDEX IF NOT EXISTS idx_metas_portafolios_meta '
        'ON metas_portafolios(meta_id)',
  ];

  /// Tipos de proyecto base (versión 28). Solo si no hay ninguno activo.
  static const datosInicialesV28 = [
    'INSERT INTO tipo_proyecto (nombre, descripcion, riesgo, created_at) '
        'SELECT * FROM (VALUES '
        "('Renta fija', 'CDT, bonos, cuentas remuneradas', 'B', datetime('now', 'localtime')), "
        "('Fondos de inversión', 'Fondos colectivos y de pensiones voluntarias', 'M', datetime('now', 'localtime')), "
        "('Renta variable', 'Acciones, ETF', 'A', datetime('now', 'localtime')), "
        "('Finca raíz', 'Inmuebles, lotes, arriendos', 'M', datetime('now', 'localtime')), "
        "('Negocio propio', 'Emprendimientos y participaciones', 'A', datetime('now', 'localtime')), "
        "('Criptoactivos', 'Bitcoin, stablecoins y otros', 'A', datetime('now', 'localtime')), "
        "('Otros', '', 'M', datetime('now', 'localtime'))"
        ') WHERE NOT EXISTS (SELECT 1 FROM tipo_proyecto WHERE deleted_at IS NULL)',
  ];

  /// Versión 29: garantiza un tipo de transacción del sistema por
  /// naturaleza (Ingreso, Egreso, Transferencia). La app los usa para
  /// aportes, rendimientos, deudas y saldos iniciales.
  static const datosInicialesV29 = [
    'INSERT INTO tipo_transferencia (nombre, descripcion, tipo_fuente, created_at) '
        "SELECT 'Ingreso', 'Dinero que entra a una de tus cuentas', 'I', datetime('now', 'localtime') "
        "WHERE NOT EXISTS (SELECT 1 FROM tipo_transferencia WHERE tipo_fuente = 'I' AND deleted_at IS NULL)",
    'INSERT INTO tipo_transferencia (nombre, descripcion, tipo_fuente, created_at) '
        "SELECT 'Egreso', 'Dinero que sale de una de tus cuentas', 'E', datetime('now', 'localtime') "
        "WHERE NOT EXISTS (SELECT 1 FROM tipo_transferencia WHERE tipo_fuente = 'E' AND deleted_at IS NULL)",
    'INSERT INTO tipo_transferencia (nombre, descripcion, tipo_fuente, created_at) '
        "SELECT 'Transferencia', 'Movimiento entre tus cuentas o hacia una cuenta externa', 'M', datetime('now', 'localtime') "
        "WHERE NOT EXISTS (SELECT 1 FROM tipo_transferencia WHERE tipo_fuente = 'M' AND deleted_at IS NULL)",
    // El más antiguo de cada naturaleza es el del sistema (el que ya usaba
    // la app); queda activo.
    'UPDATE tipo_transferencia SET es_sistema = 1, activo = 1 '
        'WHERE id_tipo_transaccion IN (SELECT MIN(id_tipo_transaccion) '
        'FROM tipo_transferencia WHERE deleted_at IS NULL GROUP BY tipo_fuente) '
        'AND NOT EXISTS (SELECT 1 FROM tipo_transferencia s WHERE s.es_sistema = 1 '
        'AND s.deleted_at IS NULL AND s.tipo_fuente = tipo_transferencia.tipo_fuente)',
  ];

  /// Versión 30: naturaleza de los motivos base (I ingreso, E gasto; nula
  /// = sirve para ambos).
  static const datosInicialesV30 = [
    "UPDATE motivos SET naturaleza = 'I' WHERE naturaleza IS NULL AND lower(nombre) IN "
        "('salario', 'honorarios y servicios', 'arriendos recibidos', 'rendimientos e intereses')",
    "UPDATE motivos SET naturaleza = 'E' WHERE naturaleza IS NULL AND lower(nombre) IN "
        "('mercado', 'servicios públicos', 'arriendo y vivienda', 'transporte', 'salud', "
        "'educación', 'entretenimiento', 'deudas y créditos', 'impuestos', "
        "'cuota de manejo', 'intereses')",
  ];

  static const indicesActuales = [
    ...indices,
    ...indicesV19,
    ...indicesV22,
    ...indicesV23,
    // De la v24 solo sigue vigente el de portafolios: la v25 quitó las
    // columnas cuenta_id/cuenta_destino_id de transferencias.
    indicePortafoliosCuentaDestino,
    ...indicesV25,
    ...indicesV27,
    'CREATE INDEX IF NOT EXISTS idx_proyectos_tipo ON proyectos(tipo_proyecto_id)',
    ...indicesV32,
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
    18: [
      // transferencias: llaves foráneas reales. SQLite no permite agregarlas
      // con ALTER TABLE, así que se reconstruye la tabla.
      // 1) Referencias opcionales inválidas (p. ej. motivo 0) pasan a NULL.
      'UPDATE transferencias SET motivo_id = NULL '
          'WHERE motivo_id IS NOT NULL '
          'AND motivo_id NOT IN (SELECT id_motivo FROM motivos)',
      'UPDATE transferencias SET destino_cuenta = NULL '
          'WHERE destino_cuenta IS NOT NULL '
          'AND destino_cuenta NOT IN (SELECT id_portafolio FROM portafolios)',
      // 2) Movimientos cuyo portafolio o tipo ya no existe (borrados físicos
      //    de versiones anteriores) se conservan aparte, sin perderlos.
      'CREATE TABLE IF NOT EXISTS $tablaHuerfanas AS SELECT * FROM transferencias WHERE 0',
      'INSERT INTO $tablaHuerfanas SELECT * FROM transferencias '
          'WHERE $_condicionHuerfana',
      // 3) Tabla nueva con FKs, copia de datos válidos y reemplazo.
      'CREATE TABLE transferencias_v18 ('
          'id_transferencia INTEGER PRIMARY KEY AUTOINCREMENT,'
          'valor INTEGER NOT NULL,'
          'impuesto INTEGER NULL,'
          'tipo_transferencia_id INTEGER NOT NULL,'
          'motivo_id INTEGER NULL,'
          'portafolio_id INTEGER NOT NULL,'
          'destino_cuenta INTEGER NULL,'
          'destino_alternativo TEXT NULL,'
          'descripcion TEXT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL,'
          'FOREIGN KEY (tipo_transferencia_id) REFERENCES tipo_transferencia (id_tipo_transaccion),'
          'FOREIGN KEY (motivo_id) REFERENCES motivos (id_motivo),'
          'FOREIGN KEY (portafolio_id) REFERENCES portafolios (id_portafolio),'
          'FOREIGN KEY (destino_cuenta) REFERENCES portafolios (id_portafolio)'
          ')',
      'INSERT INTO transferencias_v18 SELECT * FROM transferencias '
          'WHERE NOT ($_condicionHuerfana)',
      'DROP TABLE transferencias',
      'ALTER TABLE transferencias_v18 RENAME TO transferencias',
      ...indices,
    ],
    19: [
      // Terceros: quién paga un ingreso o a quién se le paga un egreso.
      'CREATE TABLE terceros ('
          'id_tercero INTEGER PRIMARY KEY AUTOINCREMENT,'
          'nombre TEXT NOT NULL,'
          'descripcion TEXT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL'
          ')',
      'ALTER TABLE transferencias ADD COLUMN tercero_id INTEGER NULL '
          'REFERENCES terceros (id_tercero)',
      ...indicesV19,
    ],
    20: [
      ...datosIniciales,
    ],
    21: [
      // Presupuestos mensuales por motivo.
      'CREATE TABLE presupuestos ('
          'id_presupuesto INTEGER PRIMARY KEY AUTOINCREMENT,'
          'motivo_id INTEGER NOT NULL,'
          'monto_mensual INTEGER NOT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL,'
          'FOREIGN KEY (motivo_id) REFERENCES motivos (id_motivo)'
          ')',
    ],
    22: [
      // Movimientos fijos (recurrentes mensuales) y vínculo con los
      // movimientos registrados a partir de ellos.
      'CREATE TABLE recurrentes ('
          'id_recurrente INTEGER PRIMARY KEY AUTOINCREMENT,'
          'nombre TEXT NOT NULL,'
          'tipo_transferencia_id INTEGER NOT NULL,'
          'portafolio_id INTEGER NOT NULL,'
          'destino_cuenta INTEGER NULL,'
          'destino_alternativo TEXT NULL,'
          'motivo_id INTEGER NULL,'
          'tercero_id INTEGER NULL,'
          'valor INTEGER NOT NULL,'
          'dia_mes INTEGER NOT NULL,'
          'activo INTEGER NOT NULL DEFAULT 1,'
          'descripcion TEXT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL,'
          'FOREIGN KEY (tipo_transferencia_id) REFERENCES tipo_transferencia (id_tipo_transaccion),'
          'FOREIGN KEY (portafolio_id) REFERENCES portafolios (id_portafolio),'
          'FOREIGN KEY (destino_cuenta) REFERENCES portafolios (id_portafolio),'
          'FOREIGN KEY (motivo_id) REFERENCES motivos (id_motivo),'
          'FOREIGN KEY (tercero_id) REFERENCES terceros (id_tercero)'
          ')',
      'ALTER TABLE transferencias ADD COLUMN recurrente_id INTEGER NULL '
          'REFERENCES recurrentes (id_recurrente)',
      ...indicesV22,
    ],
    23: [
      // usuarios: se elimina la columna password (texto plano, sin uso).
      // DROP COLUMN no está en todas las versiones de SQLite de Android, así
      // que se reconstruye la tabla.
      'CREATE TABLE usuarios_v23 ('
          'id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,'
          'nombre TEXT NULL,'
          'apellido TEXT NULL,'
          'fecha_nacimiento TEXT NULL,'
          'email TEXT NOT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL'
          ')',
      'INSERT INTO usuarios_v23 (id_usuario, nombre, apellido, fecha_nacimiento, '
          'email, created_at, updated_at, deleted_at) '
          'SELECT id_usuario, nombre, apellido, fecha_nacimiento, email, '
          'created_at, updated_at, deleted_at FROM usuarios',
      'DROP TABLE usuarios',
      'ALTER TABLE usuarios_v23 RENAME TO usuarios',
      ...indicesV23,
    ],
    24: [
      // Cuentas (ahorros, corriente, digital, efectivo) separadas de las
      // inversiones (portafolios). Un movimiento sale de una cuenta o de una
      // inversión, y puede llegar a una cuenta o a una inversión.
      //
      // Se reconstruyen recurrentes y transferencias. Las llaves foráneas se
      // verifican al final de la transacción.
      'PRAGMA defer_foreign_keys = ON',
      'CREATE TABLE cuentas ('
          'id_cuenta INTEGER PRIMARY KEY AUTOINCREMENT,'
          'nombre TEXT NOT NULL,'
          "tipo_cuenta TEXT NOT NULL CHECK (tipo_cuenta IN ('A','C','D','E')),"
          'entidad TEXT NULL,'
          'nro_cuenta TEXT NULL,'
          "exenta_impuesto TEXT NOT NULL DEFAULT 'N',"
          'descripcion TEXT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL'
          ')',
      ...datosInicialesV24,
      'ALTER TABLE portafolios ADD COLUMN cuenta_destino_id INTEGER NULL '
          'REFERENCES cuentas (id_cuenta)',
      'ALTER TABLE proyectos ADD COLUMN tipo_proyecto_id INTEGER NULL '
          'REFERENCES tipo_proyecto (id_tipo_proyecto)',
      'ALTER TABLE presupuestos ADD COLUMN cuenta_id INTEGER NULL '
          'REFERENCES cuentas (id_cuenta)',
      // recurrentes y transferencias: el origen puede ser una inversión o
      // una cuenta. Orden importante: transferencias_v24 apunta a
      // recurrentes_v24; se borran las tablas viejas (primero la hija) y al
      // renombrar recurrentes_v24 SQLite actualiza la referencia.
      'CREATE TABLE recurrentes_v24 ('
          'id_recurrente INTEGER PRIMARY KEY AUTOINCREMENT,'
          'nombre TEXT NOT NULL,'
          'tipo_transferencia_id INTEGER NOT NULL,'
          'portafolio_id INTEGER NULL,'
          'destino_cuenta INTEGER NULL,'
          'destino_alternativo TEXT NULL,'
          'motivo_id INTEGER NULL,'
          'tercero_id INTEGER NULL,'
          'valor INTEGER NOT NULL,'
          'dia_mes INTEGER NOT NULL,'
          'activo INTEGER NOT NULL DEFAULT 1,'
          'descripcion TEXT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL,'
          'cuenta_id INTEGER NULL,'
          'cuenta_destino_id INTEGER NULL,'
          'CHECK ((portafolio_id IS NULL) <> (cuenta_id IS NULL)),'
          'CHECK (destino_cuenta IS NULL OR cuenta_destino_id IS NULL),'
          'FOREIGN KEY (tipo_transferencia_id) REFERENCES tipo_transferencia (id_tipo_transaccion),'
          'FOREIGN KEY (portafolio_id) REFERENCES portafolios (id_portafolio),'
          'FOREIGN KEY (destino_cuenta) REFERENCES portafolios (id_portafolio),'
          'FOREIGN KEY (motivo_id) REFERENCES motivos (id_motivo),'
          'FOREIGN KEY (tercero_id) REFERENCES terceros (id_tercero),'
          'FOREIGN KEY (cuenta_id) REFERENCES cuentas (id_cuenta),'
          'FOREIGN KEY (cuenta_destino_id) REFERENCES cuentas (id_cuenta)'
          ')',
      'INSERT INTO recurrentes_v24 (id_recurrente, nombre, tipo_transferencia_id, '
          'portafolio_id, destino_cuenta, destino_alternativo, motivo_id, '
          'tercero_id, valor, dia_mes, activo, descripcion, created_at, '
          'updated_at, deleted_at) '
          'SELECT id_recurrente, nombre, tipo_transferencia_id, portafolio_id, '
          'destino_cuenta, destino_alternativo, motivo_id, tercero_id, valor, '
          'dia_mes, activo, descripcion, created_at, updated_at, deleted_at '
          'FROM recurrentes',
      'CREATE TABLE transferencias_v24 ('
          'id_transferencia INTEGER PRIMARY KEY AUTOINCREMENT,'
          'valor INTEGER NOT NULL,'
          'impuesto INTEGER NULL,'
          'tipo_transferencia_id INTEGER NOT NULL,'
          'motivo_id INTEGER NULL,'
          'portafolio_id INTEGER NULL,'
          'destino_cuenta INTEGER NULL,'
          'destino_alternativo TEXT NULL,'
          'descripcion TEXT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL,'
          'tercero_id INTEGER NULL,'
          'recurrente_id INTEGER NULL,'
          'cuenta_id INTEGER NULL,'
          'cuenta_destino_id INTEGER NULL,'
          'CHECK ((portafolio_id IS NULL) <> (cuenta_id IS NULL)),'
          'CHECK (destino_cuenta IS NULL OR cuenta_destino_id IS NULL),'
          'FOREIGN KEY (tipo_transferencia_id) REFERENCES tipo_transferencia (id_tipo_transaccion),'
          'FOREIGN KEY (motivo_id) REFERENCES motivos (id_motivo),'
          'FOREIGN KEY (portafolio_id) REFERENCES portafolios (id_portafolio),'
          'FOREIGN KEY (destino_cuenta) REFERENCES portafolios (id_portafolio),'
          'FOREIGN KEY (tercero_id) REFERENCES terceros (id_tercero),'
          'FOREIGN KEY (recurrente_id) REFERENCES recurrentes_v24 (id_recurrente),'
          'FOREIGN KEY (cuenta_id) REFERENCES cuentas (id_cuenta),'
          'FOREIGN KEY (cuenta_destino_id) REFERENCES cuentas (id_cuenta)'
          ')',
      'INSERT INTO transferencias_v24 (id_transferencia, valor, impuesto, '
          'tipo_transferencia_id, motivo_id, portafolio_id, destino_cuenta, '
          'destino_alternativo, descripcion, created_at, updated_at, deleted_at, '
          'tercero_id, recurrente_id) '
          'SELECT id_transferencia, valor, impuesto, tipo_transferencia_id, '
          'motivo_id, portafolio_id, destino_cuenta, destino_alternativo, '
          'descripcion, created_at, updated_at, deleted_at, tercero_id, '
          'recurrente_id FROM transferencias',
      'DROP TABLE transferencias',
      'DROP TABLE recurrentes',
      'ALTER TABLE recurrentes_v24 RENAME TO recurrentes',
      'ALTER TABLE transferencias_v24 RENAME TO transferencias',
      // Al borrar la tabla se borran sus índices: se crean todos de nuevo.
      // (Lista explícita: esta migración no debe cambiar si se agregan
      // índices en versiones futuras.)
      ...indices,
      ...indicesV19,
      ...indicesV22,
      ...indicesV23,
      ...indicesV24,
    ],
    25: [
      // Corrección del modelo de la v24: el dinero siempre vive en un
      // portafolio, y cada portafolio pertenece a una cuenta (banco o
      // efectivo: cajitas, bolsillos, CDTs del banco) o a un proyecto.
      // Los movimientos vuelven a ir siempre de portafolio a portafolio.
      //
      // Requiere foreign_keys = OFF (DatabaseHelper lo garantiza): se
      // reconstruye portafolios, que es tabla padre.
      'CREATE TABLE portafolios_v25 ('
          'id_portafolio INTEGER PRIMARY KEY AUTOINCREMENT,'
          'nombre TEXT NOT NULL,'
          'nro_cuenta TEXT NULL,'
          'tipo_renta TEXT NULL,'
          'proyecto_id INTEGER NULL,'
          'tipo_portafolio_id INTEGER NULL,'
          'interes INTEGER NOT NULL DEFAULT 0,'
          'total INTEGER NULL,'
          'exenta_impuesto TEXT NULL,'
          'frecuencia_pago_id INTEGER NULL,'
          'descripcion TEXT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL,'
          'cuenta_destino_id INTEGER NULL,'
          'cuenta_id INTEGER NULL,'
          'es_principal INTEGER NOT NULL DEFAULT 0,'
          'cuenta_aportes_id INTEGER NULL,'
          'CHECK ((proyecto_id IS NULL) <> (cuenta_id IS NULL)),'
          'CHECK (es_principal = 0 OR cuenta_id IS NOT NULL),'
          'FOREIGN KEY (cuenta_id) REFERENCES cuentas (id_cuenta),'
          'FOREIGN KEY (cuenta_aportes_id) REFERENCES cuentas (id_cuenta),'
          'FOREIGN KEY (cuenta_destino_id) REFERENCES cuentas (id_cuenta)'
          ')',
      'INSERT INTO portafolios_v25 (id_portafolio, nombre, nro_cuenta, '
          'tipo_renta, proyecto_id, tipo_portafolio_id, interes, total, '
          'exenta_impuesto, frecuencia_pago_id, descripcion, created_at, '
          'updated_at, deleted_at, cuenta_destino_id) '
          'SELECT id_portafolio, nombre, nro_cuenta, tipo_renta, proyecto_id, '
          'tipo_portafolio_id, COALESCE(interes, 0), total, exenta_impuesto, '
          'frecuencia_pago_id, descripcion, created_at, updated_at, '
          'deleted_at, cuenta_destino_id FROM portafolios',
      'DROP TABLE portafolios',
      'ALTER TABLE portafolios_v25 RENAME TO portafolios',
      ...datosInicialesV25,
      // recurrentes: origen y destino vuelven a ser solo portafolios. Si en
      // la v24 se alcanzó a usar una cuenta, pasa a su portafolio principal.
      'CREATE TABLE recurrentes_v25 ('
          'id_recurrente INTEGER PRIMARY KEY AUTOINCREMENT,'
          'nombre TEXT NOT NULL,'
          'tipo_transferencia_id INTEGER NOT NULL,'
          'portafolio_id INTEGER NOT NULL,'
          'destino_cuenta INTEGER NULL,'
          'destino_alternativo TEXT NULL,'
          'motivo_id INTEGER NULL,'
          'tercero_id INTEGER NULL,'
          'valor INTEGER NOT NULL,'
          'dia_mes INTEGER NOT NULL,'
          'activo INTEGER NOT NULL DEFAULT 1,'
          'descripcion TEXT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL,'
          'FOREIGN KEY (tipo_transferencia_id) REFERENCES tipo_transferencia (id_tipo_transaccion),'
          'FOREIGN KEY (portafolio_id) REFERENCES portafolios (id_portafolio),'
          'FOREIGN KEY (destino_cuenta) REFERENCES portafolios (id_portafolio),'
          'FOREIGN KEY (motivo_id) REFERENCES motivos (id_motivo),'
          'FOREIGN KEY (tercero_id) REFERENCES terceros (id_tercero)'
          ')',
      'INSERT INTO recurrentes_v25 (id_recurrente, nombre, tipo_transferencia_id, '
          'portafolio_id, destino_cuenta, destino_alternativo, motivo_id, '
          'tercero_id, valor, dia_mes, activo, descripcion, created_at, '
          'updated_at, deleted_at) '
          'SELECT r.id_recurrente, r.nombre, r.tipo_transferencia_id, '
          'COALESCE(r.portafolio_id, $_principalDeCuentaOrigen), '
          'COALESCE(r.destino_cuenta, $_principalDeCuentaDestino), '
          'r.destino_alternativo, r.motivo_id, r.tercero_id, r.valor, '
          'r.dia_mes, r.activo, r.descripcion, r.created_at, r.updated_at, '
          'r.deleted_at FROM recurrentes r',
      'DROP TABLE recurrentes',
      'ALTER TABLE recurrentes_v25 RENAME TO recurrentes',
      // transferencias: mismo cambio.
      'CREATE TABLE transferencias_v25 ('
          'id_transferencia INTEGER PRIMARY KEY AUTOINCREMENT,'
          'valor INTEGER NOT NULL,'
          'impuesto INTEGER NULL,'
          'tipo_transferencia_id INTEGER NOT NULL,'
          'motivo_id INTEGER NULL,'
          'portafolio_id INTEGER NOT NULL,'
          'destino_cuenta INTEGER NULL,'
          'destino_alternativo TEXT NULL,'
          'descripcion TEXT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL,'
          'tercero_id INTEGER NULL,'
          'recurrente_id INTEGER NULL,'
          'FOREIGN KEY (tipo_transferencia_id) REFERENCES tipo_transferencia (id_tipo_transaccion),'
          'FOREIGN KEY (motivo_id) REFERENCES motivos (id_motivo),'
          'FOREIGN KEY (portafolio_id) REFERENCES portafolios (id_portafolio),'
          'FOREIGN KEY (destino_cuenta) REFERENCES portafolios (id_portafolio),'
          'FOREIGN KEY (tercero_id) REFERENCES terceros (id_tercero),'
          'FOREIGN KEY (recurrente_id) REFERENCES recurrentes (id_recurrente)'
          ')',
      'INSERT INTO transferencias_v25 (id_transferencia, valor, impuesto, '
          'tipo_transferencia_id, motivo_id, portafolio_id, destino_cuenta, '
          'destino_alternativo, descripcion, created_at, updated_at, deleted_at, '
          'tercero_id, recurrente_id) '
          'SELECT r.id_transferencia, r.valor, r.impuesto, '
          'r.tipo_transferencia_id, r.motivo_id, '
          'COALESCE(r.portafolio_id, $_principalDeCuentaOrigen), '
          'COALESCE(r.destino_cuenta, $_principalDeCuentaDestino), '
          'r.destino_alternativo, r.descripcion, r.created_at, r.updated_at, '
          'r.deleted_at, r.tercero_id, r.recurrente_id FROM transferencias r',
      'DROP TABLE transferencias',
      'ALTER TABLE transferencias_v25 RENAME TO transferencias',
      // Se recrean los índices de las tablas reconstruidas (lista
      // explícita: no debe cambiar con versiones futuras).
      'DROP INDEX IF EXISTS idx_transferencias_cuenta',
      'DROP INDEX IF EXISTS idx_transferencias_cuenta_destino',
      'DROP INDEX IF EXISTS idx_transferencias_cuenta_fecha',
      ...indices,
      ...indicesV19,
      ...indicesV22,
      ...indicesV23,
      indicePortafoliosCuentaDestino,
      ...indicesV25,
    ],
    26: [
      // Deudas: tarjetas de crédito y préstamos son cuentas de tipo T y P.
      // Se reconstruye cuentas para ampliar el CHECK del tipo (requiere
      // foreign_keys = OFF, que DatabaseHelper garantiza al migrar).
      'CREATE TABLE cuentas_v26 ('
          'id_cuenta INTEGER PRIMARY KEY AUTOINCREMENT,'
          'nombre TEXT NOT NULL,'
          "tipo_cuenta TEXT NOT NULL CHECK (tipo_cuenta IN ('A','C','D','E','T','P')),"
          'entidad TEXT NULL,'
          'nro_cuenta TEXT NULL,'
          "exenta_impuesto TEXT NOT NULL DEFAULT 'N',"
          'descripcion TEXT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL'
          ')',
      'INSERT INTO cuentas_v26 SELECT id_cuenta, nombre, tipo_cuenta, entidad, '
          'nro_cuenta, exenta_impuesto, descripcion, created_at, updated_at, '
          'deleted_at FROM cuentas',
      'DROP TABLE cuentas',
      'ALTER TABLE cuentas_v26 RENAME TO cuentas',
      // Condiciones de una deuda (1 a 1 con su cuenta).
      'CREATE TABLE condiciones_credito ('
          'id_cuenta INTEGER PRIMARY KEY,'
          'cupo INTEGER NULL,'
          'tasa_mensual INTEGER NOT NULL DEFAULT 0,'
          'cuota_manejo INTEGER NULL,'
          'dia_corte INTEGER NULL,'
          'dia_pago INTEGER NULL,'
          'plazo_meses INTEGER NULL,'
          'fecha_desembolso TEXT NULL,'
          'recurrente_manejo_id INTEGER NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL,'
          'FOREIGN KEY (id_cuenta) REFERENCES cuentas (id_cuenta),'
          'FOREIGN KEY (recurrente_manejo_id) REFERENCES recurrentes (id_recurrente)'
          ')',
      // Compras a cuotas con tarjeta de crédito.
      'ALTER TABLE transferencias ADD COLUMN numero_cuotas INTEGER NULL',
      // Fijos que la app registra sola (cuota de manejo).
      'ALTER TABLE recurrentes ADD COLUMN automatico INTEGER NOT NULL DEFAULT 0',
    ],
    27: [
      // El catálogo editable "frecuencia de pago" se reemplaza por una lista
      // fija de periodos en meses (ver `Periodicidad`).
      //
      // 1. Cada cuánto paga rendimientos el portafolio (0 = al vencimiento).
      'ALTER TABLE portafolios ADD COLUMN periodicidad_rendimientos INTEGER NULL',
      // La tabla puede no existir en bases muy antiguas: se asegura para
      // poder traducir lo que el usuario ya tenía.
      'CREATE TABLE IF NOT EXISTS frecuencia_pagos ('
          'id_frecuencia_pago INTEGER PRIMARY KEY, tiempo INTEGER NULL, '
          'formato TEXT NULL, created_at TEXT NULL, updated_at TEXT NULL, '
          'deleted_at TEXT NULL)',
      'UPDATE portafolios SET periodicidad_rendimientos = ('
          'SELECT CASE '
          "WHEN f.formato = 'M' AND f.tiempo IN (1, 2, 3, 6, 12) THEN f.tiempo "
          "WHEN f.formato = 'Y' AND f.tiempo = 1 THEN 12 "
          "WHEN f.formato = 'D' AND f.tiempo = 30 THEN 1 "
          "WHEN f.formato = 'D' AND f.tiempo = 60 THEN 2 "
          'END FROM frecuencia_pagos f '
          'WHERE f.id_frecuencia_pago = portafolios.frecuencia_pago_id) '
          'WHERE frecuencia_pago_id IS NOT NULL',
      // La columna vieja queda sin uso (DROP COLUMN no existe en todas las
      // versiones de SQLite de Android).
      'UPDATE portafolios SET frecuencia_pago_id = NULL',
      'DROP TABLE frecuencia_pagos',
      // 2. Fijos cada N meses y aportes programados de un portafolio.
      'ALTER TABLE recurrentes ADD COLUMN periodo_meses INTEGER NOT NULL DEFAULT 1',
      'ALTER TABLE recurrentes ADD COLUMN fecha_inicio TEXT NULL',
      'ALTER TABLE recurrentes ADD COLUMN aporte_portafolio_id INTEGER NULL '
          'REFERENCES portafolios (id_portafolio)',
      ...indicesV27,
    ],
    28: [
      // Tipo de proyecto: nivel de riesgo de la inversión.
      'ALTER TABLE tipo_proyecto ADD COLUMN riesgo TEXT NULL',
      ...datosInicialesV28,
      // El tipo pasa a ser del proyecto (antes se elegía en cada
      // portafolio): cada proyecto sin tipo toma el más usado por sus
      // portafolios.
      'UPDATE proyectos SET tipo_proyecto_id = ('
          'SELECT p.tipo_portafolio_id FROM portafolios p '
          'JOIN tipo_proyecto t ON t.id_tipo_proyecto = p.tipo_portafolio_id '
          'AND t.deleted_at IS NULL '
          'WHERE p.proyecto_id = proyectos.id_proyecto AND p.deleted_at IS NULL '
          'GROUP BY p.tipo_portafolio_id ORDER BY COUNT(*) DESC LIMIT 1) '
          'WHERE tipo_proyecto_id IS NULL',
      'CREATE INDEX IF NOT EXISTS idx_proyectos_tipo ON proyectos(tipo_proyecto_id)',
    ],
    29: [
      // Tipos de transacción: del sistema (protegidos) y activos/inactivos.
      'ALTER TABLE tipo_transferencia ADD COLUMN es_sistema INTEGER NOT NULL DEFAULT 0',
      'ALTER TABLE tipo_transferencia ADD COLUMN activo INTEGER NOT NULL DEFAULT 1',
      ...datosInicialesV29,
    ],
    30: [
      // Motivos: naturaleza (ingreso / gasto / ambos) y activo/inactivo.
      'ALTER TABLE motivos ADD COLUMN naturaleza TEXT NULL',
      'ALTER TABLE motivos ADD COLUMN activo INTEGER NOT NULL DEFAULT 1',
      ...datosInicialesV30,
    ],
    31: [
      // Plazo de un portafolio (CDT, fondos a término): apertura y
      // vencimiento (yyyy-MM-dd).
      'ALTER TABLE portafolios ADD COLUMN fecha_apertura TEXT NULL',
      'ALTER TABLE portafolios ADD COLUMN fecha_vencimiento TEXT NULL',
    ],
    32: [
      // Metas de ahorro: el avance es la suma de los saldos de sus
      // portafolios vinculados.
      'CREATE TABLE IF NOT EXISTS metas ('
          'id_meta INTEGER PRIMARY KEY AUTOINCREMENT,'
          'nombre TEXT NOT NULL,'
          'descripcion TEXT NULL,'
          'monto_objetivo INTEGER NOT NULL CHECK (monto_objetivo > 0),'
          'fecha_objetivo TEXT NULL,'
          'activo INTEGER NOT NULL DEFAULT 1,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL'
          ')',
      'CREATE TABLE IF NOT EXISTS metas_portafolios ('
          'id_meta_portafolio INTEGER PRIMARY KEY AUTOINCREMENT,'
          'meta_id INTEGER NOT NULL,'
          'portafolio_id INTEGER NOT NULL,'
          'created_at TEXT NOT NULL,'
          'updated_at TEXT NULL,'
          'deleted_at TEXT NULL,'
          'FOREIGN KEY (meta_id) REFERENCES metas (id_meta),'
          'FOREIGN KEY (portafolio_id) REFERENCES portafolios (id_portafolio)'
          ')',
      ...indicesV32,
    ],
  };

  /// Portafolio principal de la cuenta de origen/destino de una fila `r`
  /// con columnas `cuenta_id` / `cuenta_destino_id` (migración 25).
  static const _principalDeCuentaOrigen =
      '(SELECT p.id_portafolio FROM portafolios p WHERE p.cuenta_id = r.cuenta_id '
      'AND p.es_principal = 1 AND p.deleted_at IS NULL)';
  static const _principalDeCuentaDestino =
      '(SELECT p.id_portafolio FROM portafolios p '
      'WHERE p.cuenta_id = r.cuenta_destino_id '
      'AND p.es_principal = 1 AND p.deleted_at IS NULL)';

  /// Tabla donde la migración 18 guarda los movimientos huérfanos.
  static const tablaHuerfanas = 'transferencias_huerfanas';

  static const _condicionHuerfana =
      'portafolio_id NOT IN (SELECT id_portafolio FROM portafolios) '
      'OR tipo_transferencia_id NOT IN '
      '(SELECT id_tipo_transaccion FROM tipo_transferencia)';

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
