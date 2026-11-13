import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/consultas/update_portafolio_dto.dart';
import 'package:inversiones/domain/entity/portafolio_entity.dart';

class PortafolioSchema implements TableAbstract {
  static const table = 'portafolios';

  static const idPortafolio = "id_portafolio";
  static const nombre = "nombre";
  static const descripcion = "descripcion";
  static const nroCuenta = "nro_cuenta";
  static const tipoRenta = "tipo_renta";
  static const proyecto = "proyecto_id";
  static const tipoPortafolio = "tipo_portafolio_id";
  static const interes = "interes";
  static const total = "total";
  static const exentaImpuesto = "exenta_impuesto";
  static const frecuenciaPago = "frecuencia_pago_id";

  /// Cuenta a la que pertenece el portafolio (banco o efectivo: cajitas,
  /// bolsillos, CDTs del banco). Excluyente con [proyecto].
  static const cuentaId = "cuenta_id";

  /// 1 si es el portafolio principal de su cuenta (donde se registran los
  /// movimientos de la cuenta). Cada cuenta tiene uno.
  static const esPrincipal = "es_principal";

  /// Cuenta de donde salen los aportes al portafolio. Nula = "Efectivo /
  /// Sin definir".
  static const cuentaAportes = "cuenta_aportes_id";

  /// Cuenta donde llegan los rendimientos y retiros. Nula = la misma
  /// cuenta de aportes.
  static const cuentaDestino = "cuenta_destino_id";
  static const createdAt = "created_at";
  static const updatedAt = "updated_at";
  static const deletedAt = "deleted_at";

  /// Campo del DTO de actualización que no existe como columna.
  static const totalImpuestoNoPersistido = "total_impuesto";

  final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  final intType = 'INTEGER NOT NULL';
  final intTypeNull = 'INTEGER NULL';
  final textType = 'TEXT NOT NULL';
  final textTypeNull = 'TEXT NULL';
  final doubleType = 'REAL NOT NULL';

  @override
  String createTableQuery() {
    return "CREATE TABLE $table ("
        "$idPortafolio $idType,"
        "$nombre $textType,"
        "$nroCuenta $textTypeNull,"
        "$tipoRenta $textTypeNull,"
        "$proyecto $intTypeNull,"
        "$tipoPortafolio $intTypeNull,"
        "$interes INTEGER NOT NULL DEFAULT 0,"
        "$total $intTypeNull,"
        "$exentaImpuesto $textTypeNull,"
        "$frecuenciaPago $intTypeNull,"
        "$descripcion $textTypeNull,"
        "$createdAt $textType,"
        "$updatedAt $textTypeNull,"
        "$deletedAt $textTypeNull,"
        "$cuentaDestino $intTypeNull,"
        "$cuentaId $intTypeNull,"
        "$esPrincipal INTEGER NOT NULL DEFAULT 0,"
        "$cuentaAportes $intTypeNull,"
        // Pertenece a una cuenta o a un proyecto, nunca a ambos.
        "CHECK (($proyecto IS NULL) <> ($cuentaId IS NULL)),"
        "CHECK ($esPrincipal = 0 OR $cuentaId IS NOT NULL),"
        "FOREIGN KEY ($cuentaId) REFERENCES ${CuentaSchema.table} (${CuentaSchema.idCuenta}),"
        "FOREIGN KEY ($cuentaAportes) REFERENCES ${CuentaSchema.table} (${CuentaSchema.idCuenta}),"
        "FOREIGN KEY ($cuentaDestino) REFERENCES ${CuentaSchema.table} (${CuentaSchema.idCuenta})"
      ")";
  }

  @override
  Future<int> deleteAll() async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawDelete('''
      DELETE FROM $table
    ''');
    return result;
  }

  @override
  String dropTableQuery() {
    return "DROP TABLE IF EXISTS $table";
  }

  @override
  Future<List<Portafolio>> getAll() async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table, where: Auditoria.filtroActivo);

    return result.isNotEmpty
        ? result.map((e) => Portafolio.fromJson(e)).toList()
        : [];
  }

  @override
  Future<Portafolio?> getById(int idT) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table, where: "$idPortafolio = ? AND ${Auditoria.filtroActivo}", whereArgs: [idT]);
    return result.isNotEmpty ? Portafolio.fromJson(result.first) : null;
  }

  Future<List<Portafolio>> getByIdProyecto(int idProyecto) async {
    final db = await DatabaseHelper().ejecutor;
    final result =
        await db.query(table, where: "$proyecto = ? AND ${Auditoria.filtroActivo}", whereArgs: [idProyecto]);

    return result.isNotEmpty
        ? result.map((e) => Portafolio.fromJson(e)).toList()
        : [];
  }

  @override
  Future<int> update(object) async {
    UpdatePortafolioDto updatePortafolioModel = object as UpdatePortafolioDto;

    final db = await DatabaseHelper().ejecutor;
    final result = await db.update(
      table,
      Auditoria.datosActualizacion(updatePortafolioModel.toJson())
        ..remove(totalImpuestoNoPersistido),
      where: 'id_portafolio = ?',
      whereArgs: [updatePortafolioModel.idPortafolio],
    );

    return result;
  }

  @override
  Future<int> insert(object) async {
    Portafolio portafolioModel = object as Portafolio;

    final db = await DatabaseHelper().ejecutor;
    final result = await db.insert(table, Auditoria.datosCreacion(portafolioModel.toJson()));

    return result;
  }

  @override
  Future<int> insertAll(List object) async {
    int result = 0;

    await deleteAll();
    for (var element in object) {
      result += await insert(element);
    }
    return result;
  }

  @override
  Future<int> deleteById(int idTable) async {
    final db = await DatabaseHelper().ejecutor;
    final result =
        await Auditoria.borradoLogico(db, table, idPortafolio, idTable);

    return result;
  }

  /// Portafolio principal activo de la cuenta [idCuenta].
  Future<Portafolio?> getPrincipalDeCuenta(int idCuenta) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table,
        where: '$cuentaId = ? AND $esPrincipal = 1 AND ${Auditoria.filtroActivo}',
        whereArgs: [idCuenta]);
    return result.isNotEmpty ? Portafolio.fromJson(result.first) : null;
  }

  /// Portafolios activos de la cuenta [idCuenta] (el principal primero).
  Future<List<Portafolio>> getByCuenta(int idCuenta) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table,
        where: '$cuentaId = ? AND ${Auditoria.filtroActivo}',
        whereArgs: [idCuenta],
        orderBy: '$esPrincipal DESC, $nombre COLLATE NOCASE');
    return result.map(Portafolio.fromJson).toList();
  }

  /// Copia la exención de GMF de la cuenta a todos sus portafolios.
  Future<int> sincronizarExencionDeCuenta(int idCuenta, String exenta) async {
    final db = await DatabaseHelper().ejecutor;
    return db.update(
        table, {exentaImpuesto: exenta, updatedAt: Auditoria.ahora()},
        where: '$cuentaId = ? AND ${Auditoria.filtroActivo}',
        whereArgs: [idCuenta]);
  }

  /// Renombra el portafolio principal de la cuenta [idCuenta].
  Future<int> renombrarPrincipal(int idCuenta, String nuevoNombre) async {
    final db = await DatabaseHelper().ejecutor;
    return db.update(table, {nombre: nuevoNombre, updatedAt: Auditoria.ahora()},
        where: '$cuentaId = ? AND $esPrincipal = 1 AND ${Auditoria.filtroActivo}',
        whereArgs: [idCuenta]);
  }

  /// Convierte el portafolio en el principal de la cuenta [idCuenta]: deja
  /// de pertenecer a su proyecto. Sus movimientos no cambian.
  Future<int> asignarComoPrincipal(int id, int idCuenta) async {
    final db = await DatabaseHelper().ejecutor;
    return db.update(
        table,
        {
          cuentaId: idCuenta,
          proyecto: null,
          esPrincipal: 1,
          cuentaAportes: null,
          cuentaDestino: null,
          updatedAt: Auditoria.ahora(),
        },
        where: '$idPortafolio = ? AND ${Auditoria.filtroActivo}',
        whereArgs: [id]);
  }

  /// Quita la cuenta [idCuenta] como cuenta de aportes o de rendimientos de
  /// los portafolios que la usaban (pasan a "Efectivo / Sin definir").
  Future<void> quitarReferenciasACuenta(int idCuenta) async {
    final db = await DatabaseHelper().ejecutor;
    for (final columna in [cuentaAportes, cuentaDestino]) {
      await db.update(table, {columna: null, updatedAt: Auditoria.ahora()},
          where: '$columna = ?', whereArgs: [idCuenta]);
    }
  }
}
