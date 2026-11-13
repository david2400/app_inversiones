import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/entity/portafolio_entity.dart';
import 'package:inversiones/domain/entity/tipo_transaccion_entity.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Base de datos SQLite en memoria con el esquema actual, inyectada en
/// [DatabaseHelper] para que schemas y handlers la usen.
class BaseDatosPrueba {
  late Database db;

  Future<void> abrir() async {
    sqfliteFfiInit();
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    // Igual que en la app (DatabaseHelper._onConfigure).
    await db.execute('PRAGMA foreign_keys = ON');
    await DatabaseHelper.crearEsquema(db);
    DatabaseHelper.baseDeDatosDePrueba = db;
  }

  Future<void> cerrar() async {
    DatabaseHelper.baseDeDatosDePrueba = null;
    await db.close();
  }

  Future<int> crearTipo(String nombre, String fuente) =>
      TipoTransaccionSchema().insert(
          TipoTransaccion(nombre: nombre, descripcion: '', tipoFuente: fuente));

  Future<int> crearPortafolio(String nombre, String exenta,
          {int proyectoId = 1}) =>
      PortafolioSchema().insert(Portafolio(
          nombre: nombre,
          tipoRenta: 'F',
          proyectoId: proyectoId,
          tipoPortafolioId: 1,
          interes: 0,
          exentaImpuesto: exenta,
          frecuenciaPagoId: 1));
}
