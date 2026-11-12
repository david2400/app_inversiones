import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/entity/portafolio_entity.dart';
import 'package:inversiones/domain/entity/tipo_transaccion_entity.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late ITransaccion transacciones;
  late IPortafolio portafolios;
  late int ingreso, egreso, transferencia;
  late int cuentaGravada, cuentaExenta;

  Future<int> crearTipo(String nombre, String fuente) => TipoTransaccionSchema()
      .insert(TipoTransaccion(nombre: nombre, descripcion: '', tipoFuente: fuente));

  Future<int> crearPortafolio(String nombre, String exenta) =>
      PortafolioSchema().insert(Portafolio(
          nombre: nombre,
          tipoRenta: 'F',
          proyectoId: 1,
          tipoPortafolioId: 1,
          interes: 0,
          exentaImpuesto: exenta,
          frecuenciaPagoId: 1));

  Future<int> registrar(int tipo, int origen, int valor, {int? destino}) =>
      transacciones.createTransaccion(TransaccionDto(
          valor: valor,
          tipoTransferenciaId: tipo,
          portafolioId: origen,
          destinoCuenta: destino));

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await DatabaseHelper.crearEsquema(db);
    DatabaseHelper.baseDeDatosDePrueba = db;

    transacciones = TransaccionHandler();
    portafolios = PortafolioHandler();

    ingreso = await crearTipo('Ingreso', TipoFuente.ingreso);
    egreso = await crearTipo('Egreso', TipoFuente.egreso);
    transferencia = await crearTipo('Transferencia', TipoFuente.transferencia);
    cuentaGravada = await crearPortafolio('Ahorros', 'N');
    cuentaExenta = await crearPortafolio('Nómina', 'S');
  });

  tearDown(() async {
    DatabaseHelper.baseDeDatosDePrueba = null;
    await db.close();
  });

  test('ingreso, egreso y transferencia actualizan saldos con GMF', () async {
    await registrar(ingreso, cuentaGravada, 1000000);
    expect(await portafolios.obtenerSaldo(cuentaGravada), 1000000);

    await registrar(egreso, cuentaGravada, 100000);
    expect(await portafolios.obtenerSaldo(cuentaGravada), 1000000 - 100400);

    await registrar(transferencia, cuentaGravada, 200000,
        destino: cuentaExenta);
    expect(await portafolios.obtenerSaldo(cuentaGravada), 899600 - 200800);
    expect(await portafolios.obtenerSaldo(cuentaExenta), 200000);

    final saldos = await portafolios.listarSaldos();
    final gravada = saldos.firstWhere((s) => s.idPortafolio == cuentaGravada);
    expect(gravada.ingresos, 1000000);
    expect(gravada.egresos, 300000);
    expect(gravada.impuestos, 1200);
  });

  test('portafolio exento no paga GMF', () async {
    await registrar(ingreso, cuentaExenta, 50000);
    await registrar(egreso, cuentaExenta, 50000);
    expect(await portafolios.obtenerSaldo(cuentaExenta), 0);
  });

  test('rechaza egresos sin saldo suficiente', () async {
    await expectLater(() => registrar(egreso, cuentaExenta, 1), throwsException);
  });

  test('rechaza transferencia al mismo portafolio o sin destino', () async {
    await registrar(ingreso, cuentaGravada, 1000);
    await expectLater(
        () => registrar(transferencia, cuentaGravada, 10,
            destino: cuentaGravada),
        throwsException);
    await expectLater(() => registrar(transferencia, cuentaGravada, 10), throwsException);
  });

  test('rechaza valores no positivos', () async {
    await expectLater(() => registrar(ingreso, cuentaGravada, 0), throwsException);
  });

  test('el borrado es lógico y excluye el movimiento del saldo', () async {
    await registrar(ingreso, cuentaExenta, 1000);
    final id = await registrar(egreso, cuentaExenta, 400);

    await transacciones.deleteTransaccion(id);

    expect(await portafolios.obtenerSaldo(cuentaExenta), 1000);
    final fila = await db.query('transferencias',
        where: 'id_transferencia = ?', whereArgs: [id]);
    expect(fila.single['deleted_at'], isNotNull);
  });

  test('no permite borrar un portafolio con movimientos', () async {
    await registrar(ingreso, cuentaExenta, 1000);
    await expectLater(() => portafolios.deletePortafolio(cuentaExenta), throwsException);
  });
}
