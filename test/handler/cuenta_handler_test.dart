import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late ICuenta cuentas;
  late IPortafolio portafolios;
  late ITransaccion transacciones;

  Future<int> crearCuenta(String nombre,
          {String tipo = TipoCuenta.ahorros,
          String exenta = 'N',
          int saldoInicial = 0}) =>
      cuentas.guardarCuenta(
          CuentaDto(nombre: nombre, tipoCuenta: tipo, exentaImpuesto: exenta),
          saldoInicial: saldoInicial);

  Future<int> principal(int idCuenta) async =>
      (await PortafolioSchema().getPrincipalDeCuenta(idCuenta))!.idPortafolio!;

  Future<int> crearInversion(String nombre,
          {int? aportes, int? rendimientos, String exenta = 'S'}) =>
      portafolios.createPortafolio(PortafolioDto(
        nombre: nombre,
        proyectoId: 1,
        tipoPortafolioId: 1,
        interes: 10,
        exentaImpuesto: exenta,
        cuentaAportesId: aportes,
        cuentaDestinoId: rendimientos,
      ));

  Future<int> tipo(String fuente) async =>
      (await TipoTransaccionSchema().getPrimeroPorFuente(fuente))!
          .idTipoTransaccion!;

  setUp(() async {
    await base.abrir();
    cuentas = CuentaHandler();
    portafolios = PortafolioHandler();
    transacciones = TransaccionHandler();
  });

  tearDown(base.cerrar);

  test('crear cuenta crea su portafolio principal con el saldo inicial',
      () async {
    final id = await crearCuenta('Bancolombia', saldoInicial: 1000000);

    final lista = await cuentas.listarCuentas();
    expect(lista.first.idCuenta, CuentaSchema.idEfectivo);
    final cuenta = lista.firstWhere((c) => c.idCuenta == id);
    expect(cuenta.saldo, 1000000);
    expect(cuenta.cantidadPortafolios, 1);
    expect(cuenta.idPortafolioPrincipal, await principal(id));

    // Editar renombra el principal y sincroniza la exención.
    await cuentas.guardarCuenta(CuentaDto(
        idCuenta: id,
        nombre: 'Bancolombia Ahorros',
        tipoCuenta: TipoCuenta.ahorros,
        exentaImpuesto: 'S'));
    final p = await PortafolioSchema().getById(await principal(id));
    expect(p!.nombre, 'Bancolombia Ahorros');
    expect(p.exentaImpuesto, 'S');
  });

  test('valida nombre, tipo y exención', () async {
    await expectLater(() => crearCuenta('  '), throwsException);
    await expectLater(() => crearCuenta('X', tipo: 'Z'), throwsException);
    await expectLater(() => crearCuenta('X', exenta: 'talvez'), throwsException);
  });

  test('el 4x1000 lo define la cuenta; el efectivo nunca paga', () async {
    final gravada = await crearCuenta('Ahorros', saldoInicial: 100000);
    final efectivo = await crearCuenta('Billetera',
        tipo: TipoCuenta.efectivo, exenta: 'N', saldoInicial: 100000);

    for (final id in [gravada, efectivo]) {
      await transacciones.createTransaccion(TransaccionDto(
          valor: 50000,
          tipoTransferenciaId: await tipo(TipoFuente.egreso),
          portafolioId: await principal(id)));
    }
    expect(await portafolios.obtenerSaldo(await principal(gravada)), 49800);
    expect(await portafolios.obtenerSaldo(await principal(efectivo)), 50000);
  });

  test('una cajita de la cuenta hereda su 4x1000 y suma a su saldo', () async {
    final id = await crearCuenta('Nu', saldoInicial: 1000, exenta: 'S');
    final cajita = await portafolios.createPortafolio(
        PortafolioDto(nombre: 'Cajita', cuentaId: id, exentaImpuesto: 'N'),
        saldoInicial: 500);

    expect((await PortafolioSchema().getById(cajita))!.exentaImpuesto, 'S');
    final cuenta = await cuentas.obtenerCuenta(id);
    expect(cuenta.saldo, 1500);
    expect(cuenta.cantidadPortafolios, 2);
  });

  test('un portafolio debe ser de una cuenta o de un proyecto', () async {
    await expectLater(
        () => portafolios.createPortafolio(PortafolioDto(nombre: 'Huérfano')),
        throwsException);
  });

  test('aporte: sale de la cuenta de aportes y paga su 4x1000', () async {
    final ahorros = await crearCuenta('Ahorros', saldoInicial: 1000000);
    final cdt = await crearInversion('CDT', aportes: ahorros);

    await transacciones.registrarAporte(cdt, 500000);

    expect(await portafolios.obtenerSaldo(cdt), 500000);
    expect(await portafolios.obtenerSaldo(await principal(ahorros)),
        1000000 - 500000 - 2000);
  });

  test('aporte sin cuenta definida sale de "Efectivo / Sin definir"',
      () async {
    final cdt = await crearInversion('CDT');
    // Efectivo no tiene saldo: se rechaza y no queda nada registrado.
    await expectLater(
        () => transacciones.registrarAporte(cdt, 1000), throwsException);
    expect(await portafolios.obtenerSaldo(cdt), 0);

    await transacciones.registrarRendimiento(
        await crearInversion('Otra'), 5000); // llega a Efectivo
    await transacciones.registrarAporte(cdt, 1000);
    expect(await portafolios.obtenerSaldo(cdt), 1000);
  });

  test('no se aporta al portafolio principal de una cuenta', () async {
    final id = await crearCuenta('Ahorros');
    final idPrincipal = await principal(id);
    await expectLater(
        () => transacciones.registrarAporte(idPrincipal, 10),
        throwsException);
  });

  test('rendimiento: llega a la cuenta de rendimientos, o a la de aportes',
      () async {
    final ahorros = await crearCuenta('Ahorros', saldoInicial: 100000);
    final nequi = await crearCuenta('Nequi', tipo: TipoCuenta.digital);
    final mismaCuenta = await crearInversion('CDT 1', aportes: ahorros);
    final otraCuenta =
        await crearInversion('CDT 2', aportes: ahorros, rendimientos: nequi);

    await transacciones.registrarRendimiento(mismaCuenta, 3000);
    await transacciones.registrarRendimiento(otraCuenta, 7000);

    expect(await portafolios.obtenerSaldo(mismaCuenta), 0);
    expect(await portafolios.obtenerSaldo(otraCuenta), 0);
    expect(
        await portafolios.obtenerSaldo(await principal(ahorros)), 103000);
    expect(await portafolios.obtenerSaldo(await principal(nequi)), 7000);
  });

  test('rendimiento reinvertido o de la cuenta principal se queda ahí',
      () async {
    final ahorros = await crearCuenta('Ahorros');
    final cdt = await crearInversion('CDT', aportes: ahorros);

    await transacciones.registrarRendimiento(cdt, 2500, reinvertir: true);
    await transacciones.registrarRendimiento(await principal(ahorros), 800);

    expect(await portafolios.obtenerSaldo(cdt), 2500);
    expect(await portafolios.obtenerSaldo(await principal(ahorros)), 800);
  });

  test('eliminar cuenta: no Efectivo, no con movimientos ni portafolios',
      () async {
    await expectLater(() => cuentas.eliminarCuenta(CuentaSchema.idEfectivo),
        throwsException);

    final conSaldo = await crearCuenta('Con saldo', saldoInicial: 10);
    await expectLater(() => cuentas.eliminarCuenta(conSaldo), throwsException);

    final conCajita = await crearCuenta('Con cajita');
    await portafolios.createPortafolio(
        PortafolioDto(nombre: 'Cajita', cuentaId: conCajita));
    await expectLater(() => cuentas.eliminarCuenta(conCajita), throwsException);

    final vacia = await crearCuenta('Vacía');
    final cdt = await crearInversion('CDT', aportes: vacia);
    await cuentas.eliminarCuenta(vacia);
    expect((await cuentas.listarCuentas()).any((c) => c.idCuenta == vacia),
        isFalse);
    expect(await PortafolioSchema().getPrincipalDeCuenta(vacia), isNull);
    // La inversión que aportaba desde ahí pasa a Efectivo.
    expect((await PortafolioSchema().getById(cdt))!.cuentaAportesId, isNull);
  });

  test('convertir un portafolio de proyecto en cuenta conserva sus movimientos',
      () async {
    final viejo = await base.crearPortafolio('Davivienda', 'N');
    await transacciones.createTransaccion(TransaccionDto(
        valor: 1000,
        tipoTransferenciaId: await tipo(TipoFuente.ingreso),
        portafolioId: viejo));

    final idCuenta = await cuentas.convertirPortafolioEnCuenta(viejo,
        tipoCuenta: TipoCuenta.ahorros, entidad: 'Davivienda');

    final p = (await PortafolioSchema().getById(viejo))!;
    expect(p.cuentaId, idCuenta);
    expect(p.proyectoId, isNull);
    expect(p.esPrincipal, isTrue);
    final cuenta = await cuentas.obtenerCuenta(idCuenta);
    expect(cuenta.saldo, 1000);
    expect(cuenta.entidad, 'Davivienda');
    expect(cuenta.exentaImpuesto, 'N');

    await expectLater(
        () => cuentas.convertirPortafolioEnCuenta(viejo,
            tipoCuenta: TipoCuenta.ahorros),
        throwsException);
  });
}
