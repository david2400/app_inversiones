import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/page/gestion/portafolio/dto/update_portafolio_dto.dart';
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
        "$tipoRenta $intType,"
        "$proyecto $intType,"
        "$tipoPortafolio $intType,"
        "$interes $intType,"
        "$total $intTypeNull,"
        "$exentaImpuesto $textTypeNull,"
        "$frecuenciaPago $intType,"
        "$descripcion $textTypeNull,"
        "$createdAt $textType,"
        "$updatedAt $textTypeNull,"
        "$deletedAt $textTypeNull"
      ")";
  }

  @override
  Future<int> deleteAll() async {
    final db = await DatabaseHelper().database;
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
    final db = await DatabaseHelper().database;
    final result = await db.query(table, where: Auditoria.filtroActivo);

    return result.isNotEmpty
        ? result.map((e) => Portafolio.fromJson(e)).toList()
        : [];
  }

  @override
  Future<Portafolio?> getById(int idT) async {
    final db = await DatabaseHelper().database;
    final result = await db.query(table, where: "$idPortafolio = ? AND ${Auditoria.filtroActivo}", whereArgs: [idT]);
    return result.isNotEmpty ? Portafolio.fromJson(result.first) : null;
  }

  Future<List<Portafolio>> getByIdProyecto(int idProyecto) async {
    final db = await DatabaseHelper().database;
    final result =
        await db.query(table, where: "$proyecto = ? AND ${Auditoria.filtroActivo}", whereArgs: [idProyecto]);

    return result.isNotEmpty
        ? result.map((e) => Portafolio.fromJson(e)).toList()
        : [];
  }

  @override
  Future<int> update(object) async {
    UpdatePortafolioDto updatePortafolioModel = object as UpdatePortafolioDto;

    final db = await DatabaseHelper().database;
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

    final db = await DatabaseHelper().database;
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
    final db = await DatabaseHelper().database;
    final result =
        await Auditoria.borradoLogico(db, table, idPortafolio, idTable);

    return result;
  }
}
