# CLAUDE.md — Inversiones (App de Finanzas Personales)

## 1. Propósito del proyecto

**Inversiones** es una aplicación móvil Flutter para la gestión de finanzas
personales con visión empresarial. Su objetivo es:

- Registrar **ingresos y egresos** (transferencias/transacciones).
- Saber **de dónde ingresó** el dinero y **a dónde salió** (motivo, portafolio,
  cuenta destino).
- Consultar **saldos y balances** por portafolio, proyecto, mes y año.
- Clasificar movimientos por **tipo de transacción**, **motivo**, **frecuencia
  de pago**, **proyecto** y **tipo de proyecto**.
- Calcular automáticamente el **impuesto 4x1000 (GMF)** cuando el portafolio
  no está exento.

La app debe ser **óptima, escalable y con estándares empresariales**.

## 2. Stack tecnológico

- **Framework:** Flutter (Dart SDK `^3.6.1`), multiplataforma
  (Android, iOS, Web, Windows, Linux, macOS).
- **Persistencia local:** SQLite vía `sqflite` + `path_provider`
  (base de datos `inversiones.db`, versión actual `18`).
  En Windows/Linux se usa `sqflite_common_ffi`
  (`DatabaseHelper.inicializarPlataforma()` en `main.dart`).
- **Navegación:** `go_router` (rutas declarativas, URL strategy por path).
- **Estado:** `provider` + patrón `FlutterFlowModel` (clases `*PageState`).
- **Codegen:** `build_runner` + `smartstruct` / `auto_mappr` para mappers
  Entity ↔ DTO (archivos `*.mapper.g.dart` generados).
- **UI/utilidades:** `google_fonts`, `fl_chart`, `intl`, `flutter_animate`,
  `dropdown_button2`, `data_table_2`, `cached_network_image`, etc.
- **Auth (preparado, desactivado):** módulo `lib/auth/firebase_auth` con
  providers (Google, Apple, email, anónimo, GitHub, JWT). Actualmente el
  código Firebase está comentado en `main.dart`.

## 3. Arquitectura por capas

El proyecto sigue una arquitectura por capas orientada a dominio.
**Respeta esta estructura al crear código nuevo.**

```
lib/
├── config/                  # Configuración global
│   └── database_config.dart # DatabaseHelper (singleton), creación/upgrade de tablas
├── domain/
│   ├── entity/              # Entidades de dominio (modelo de negocio)
│   ├── schema/              # Esquemas de tablas SQLite: DDL + CRUD (TableAbstract)
│   ├── mappers/             # Mappers Entity↔DTO con smartstruct (*.g.dart generados)
│   └── models/
│       └── table_abstract.dart  # Contrato CRUD de todas las tablas
├── infraestructure/handler/
│   ├── interfaces/          # Contratos de servicio (ej. ITransaccion)
│   └── implementations/     # Lógica de negocio (ej. TransaccionHandler)
├── page/                    # Capa de presentación, organizada por feature
│   └── <feature>/
│       ├── dto/             # DTOs de entrada/salida del feature
│       ├── page/            # Widgets (páginas)
│       └── states/          # Clases *PageState (FlutterFlowModel): orquestan UI↔handlers
├── ui/
│   ├── utils/               # Utilidades FlutterFlow (tema, i18n, widgets base, nav)
│   └── widgets/             # Widgets compartidos (ej. drawer_widget.dart)
├── auth/                    # Gestión de autenticación (Firebase, preparado)
├── index.dart               # Barrel file: exports públicos de las páginas
└── main.dart                # Punto de entrada: DB, tema, router, i18n
```

### Flujo de una funcionalidad (obligatorio)

1. **Schema** (`domain/schema/`): define la tabla SQL (`createTableQuery`,
   `dropTableQuery`) y el CRUD implementando `TableAbstract`.
2. **Entity** (`domain/entity/`): modelo de dominio con `fromJson`/`toJson`.
3. **DTO** (`page/<feature>/dto/`): objeto de transferencia para la UI.
4. **Mapper** (`domain/mappers/`): anotación `@Mapper()` de smartstruct;
   el `*.g.dart` se genera con build_runner.
5. **Interface + Implementation** (`infraestructure/handler/`): la interfaz
   (`I<Nombre>`) define el contrato; la implementación (`<Nombre>Handler`)
   contiene la lógica de negocio y usa schemas/mappers.
6. **State** (`page/<feature>/states/`): `*PageState extends FlutterFlowModel`
   invoca a los handlers a través de la **interfaz**, nunca directamente
   a la implementación concreta.
7. **Page** (`page/<feature>/page/`): widget visual; delega en su `*State`.
8. **Export** en `lib/index.dart` y registro de ruta en `ui/utils/nav/nav.dart`.

## 4. Reglas de negocio clave

- **Soft delete:** las tablas usan `deleted_at`; no se borran físicamente
  los registros de negocio.
- **Timestamps:** `created_at` obligatorio, `updated_at`/`deleted_at` nulos.
- **Impuesto 4x1000:** en `TransaccionHandler.createTransaccion`, si el
  portafolio tiene `exentaImpuesto == 'N'`, se calcula el impuesto vía
  `calcular4xMill(date)` antes de insertar.
- **Integridad referencial lógica:** las transacciones referencian
  `tipo_transferencia_id`, `motivo_id`, `portafolio_id` y opcionalmente
  `destino_cuenta` / `destino_alternativo`.
- **Monetario:** los valores se almacenan como `INTEGER` (valor, impuesto);
  mantener consistencia de unidades.

## 5. Convenciones de código

- **Idioma:** todo el código en **español** (clases, métodos, variables).
  Los textos de i18n van en `ui/utils/internationalization.dart`
  (locales soportados: en, es, de, ar).
- **Nombres de BD:** `snake_case` para tablas y columnas
  (`id_transferencia`, `tipo_transferencia_id`, `created_at`).
- **Dart:** `PascalCase` clases, `camelCase` métodos/variables,
  `snake_case` archivos. Features en `page/` pueden usar carpetas
  camelCase existentes (`frecuenciaPago`, `tipoTransaccion`).
- **Constantes de columnas:** cada schema declara sus columnas como
  `static const` (ver `TransferenciaShema` como referencia).
- **Inyección manual:** los handlers se instancian como
  `ITransaccion handler = TransaccionHandler();` — siempre programar
  contra la interfaz.
- **Errores:** `try/catch` con `rethrow` en handlers y states; lanzar
  `Exception` con mensaje en español para errores de negocio.
- **Lints:** `flutter_lints` activo en `analysis_options.yaml`.
- **NO editar** archivos generados `*.g.dart` ni el boilerplate de
  `ui/utils/flutter_flow_*` salvo necesidad real.
- Añadir el export de toda página nueva en `lib/index.dart`.

## 6. Base de datos

- **Singleton:** `DatabaseHelper()` (factory) en `config/database_config.dart`.
- **Crear tabla nueva:** clase `*Schema implements TableAbstract`, agregarla
  a `DatabaseHelper._tablas` y crear una migración que la cree.
- **Migraciones (`config/migraciones.dart`):** versionadas y no
  destructivas. Para cambiar el esquema: subir `Migraciones.versionActual`,
  agregar sus sentencias en `_pasos[nuevaVersion]` con DDL "congelado" y
  actualizar el `createTableQuery` del schema (instalaciones nuevas).
  Nunca modificar una migración ya publicada. Cambios que `ALTER TABLE` no
  soporta: crear tabla nueva → copiar → borrar → renombrar.
- Antes de migrar se guarda `inversiones.db.v<N>.<marca>.bak`.
- `PRAGMA foreign_keys = ON` (onConfigure). `transferencias` tiene FKs
  (v18); los huérfanos antiguos quedaron en `transferencias_huerfanas`.
- **Auditoría y soft delete:** usar `Auditoria` (`domain/models/auditoria.dart`):
  `filtroActivo`, `datosCreacion`, `datosActualizacion`, `borradoLogico`.
- Errores/logs: `Registro` (`config/registro.dart`), nunca `print`.

Tablas actuales: `frecuencia_pagos`, `motivos`, `portafolios`, `proyectos`,
`tipo_proyecto`, `tipo_transferencia`, `transferencias`, `usuarios`.

## 7. Comandos

```bash
flutter pub get                          # instalar dependencias
flutter pub run build_runner build --delete-conflicting-outputs
                                         # regenerar mappers *.g.dart
flutter analyze                          # lint / análisis estático
flutter test                             # tests
flutter run -d windows|chrome|android    # ejecutar
flutter build apk|web|windows            # build de release
```

## 8. Directrices para Claude

- Antes de crear un feature, revisa uno existente (recomendado:
  `movimientos/transacciones` es el más completo) y **replica su patrón**.
- Funcionalidad completa = Schema + Entity + DTO + Mapper + Interface +
  Implementation + State + Page + export en `index.dart` + ruta en `nav.dart`.
- Código limpio: SOLID, DRY, controladores/pages ligeros, lógica en handlers.
- Prioriza: **simplicidad > escalabilidad > mantenibilidad > rendimiento**.
- Evita valores hardcodeados; usa constantes `static const` o configuración.
- Consultas SQL: usa los métodos del schema; no dupliques SQL en handlers
  si ya existe un método reutilizable.
- No exponer información sensible; validar entradas de usuario en los states.
- Responde siempre en **español**.

## 9. Deuda técnica conocida / mejoras pendientes

- Schemas de `domain` importan DTOs de consulta de `page/`
  (`TransaccionBalanceDto`, `TransaccionPortafolioDto`, `UpdatePortafolioDto`):
  moverlos a `domain`.
- Clase base para schemas (CRUD y tipos de columna repetidos).
- `portafolios` sin FKs (`proyecto_id`, `frecuencia_pago_id`,
  `tipo_portafolio_id` sin tabla); tabla `impuestos` y
  `proyectos.tipo_proyecto_id` pendientes.
- `updateTransaccion` no recalcula GMF; política actual: anular y registrar.
- Firebase Auth implementado pero deshabilitado (comentado en `main.dart`).
- Avisos de estilo (info) en el boilerplate `ui/utils/flutter_flow_*`.

## 10. Reglas de negocio implementadas

- Saldo = calculado desde movimientos activos (`TransferenciaShema.obtenerSaldos`);
  `portafolios.total` está en desuso.
- `tipo_fuente`: `I` ingreso, `E` egreso, `M` transferencia (`TipoFuente`).
- GMF 4x1000 (`CalculadoraGmf`): valor × 4 / 1000 en egresos y transferencias
  que salen de un portafolio con `exenta_impuesto = 'N'`.
- Egresos/transferencias exigen saldo suficiente (incluye GMF).
- Dashboard y proyecto: transferencias internas no son ingreso/egreso.
- Movimientos no se editan: se anulan (soft delete) y se registran de nuevo.
