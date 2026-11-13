import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late ITransaccion transacciones;
  late IPortafolio portafolios;
  late int ingreso, egreso, transferencia;
  late int cuentaGravada, cuentaExenta;

  Future<int> registrar(int tipo, int origen, int valor, {int? destino}) =>
      transacciones.createTransaccion(TransaccionDto(
          valor: valor,
          tipoTransferenciaId: tipo,
          portafolioId: origen,
          destinoCuenta: destino));

  setUp(() async {
    await base.abrir();
    transacciones = TransaccionHandler();
    portafolios = PortafolioHandler();

    ingreso = await base.crearTipo('Ingreso', TipoFuente.ingreso);
    egreso = await base.crearTipo('Egreso', TipoFuente.egreso);
    transferencia = await base.crearTipo('Transferencia', TipoFuente.transferencia);
    cuentaGravada = await base.crearPortafolio('Ahorros', 'N');
    cuentaExenta = await base.crearPortafolio('Nómina', 'S');
  });

  tearDown(base.cerrar);

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
    final fila = await base.db.query('transferencias',
        where: 'id_transferencia = ?', whereArgs: [id]);
    expect(fila.single['deleted_at'], isNotNull);
  });

  test('no permite borrar un portafolio con movimientos', () async {
    await registrar(ingreso, cuentaExenta, 1000);
    await expectLater(() => portafolios.deletePortafolio(cuentaExenta), throwsException);
  });

  test('crear portafolio con saldo inicial registra el ingreso', () async {
    final id = await portafolios.createPortafolio(
        PortafolioDto(
            nombre: 'Davivienda',
            tipoRenta: 'F',
            proyectoId: 1,
            tipoPortafolioId: 1,
            interes: 0,
            exentaImpuesto: 'N',
            frecuenciaPagoId: 1),
        saldoInicial: 750000);

    expect(await portafolios.obtenerSaldo(id), 750000);
    final movimientos = await transacciones.listaTransaccionesByPortafolio(id);
    expect(movimientos.single.descripcion, PortafolioHandler.descripcionSaldoInicial);
  });

  test('saldo inicial negativo se rechaza', () async {
    await expectLater(
        () => portafolios.createPortafolio(
            PortafolioDto(
                nombre: 'X',
                tipoRenta: 'F',
                proyectoId: 1,
                tipoPortafolioId: 1,
                interes: 0,
                frecuenciaPagoId: 1),
            saldoInicial: -1),
        throwsException);
  });

  test('ajustar saldo registra la diferencia sin GMF', () async {
    await registrar(ingreso, cuentaGravada, 1000000);

    // El banco dice 1.050.000: se registra un ingreso de 50.000.
    await transacciones.ajustarSaldo(cuentaGravada, 1050000);
    expect(await portafolios.obtenerSaldo(cuentaGravada), 1050000);

    // Ahora dice 900.000: egreso de 150.000, sin 4x1000 aunque esté gravada.
    await transacciones.ajustarSaldo(cuentaGravada, 900000);
    expect(await portafolios.obtenerSaldo(cuentaGravada), 900000);

    await expectLater(
        () => transacciones.ajustarSaldo(cuentaGravada, 900000), throwsException);
  });
}
