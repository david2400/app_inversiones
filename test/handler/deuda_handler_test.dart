import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/calculadora_credito.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/schema/condiciones_credito_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/recurrente_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/deuda_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/recurrente_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/deuda_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/cuentas/dto/deuda_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late IDeuda deudas;
  late ICuenta cuentas;
  late IPortafolio portafolios;

  Future<int> crearAhorros({int saldo = 0, String exenta = 'N'}) =>
      cuentas.guardarCuenta(
          CuentaDto(
              nombre: 'Ahorros',
              tipoCuenta: TipoCuenta.ahorros,
              exentaImpuesto: exenta),
          saldoInicial: saldo);

  Future<int> crearTarjeta({int cupo = 1000000, int cuotaManejo = 0}) =>
      deudas.guardarTarjeta(
        CuentaDto(nombre: 'Visa', tipoCuenta: TipoCuenta.tarjetaCredito),
        CondicionesCreditoDto(
            cupo: cupo,
            tasaMensual: 2000, // 2 % E.M.
            cuotaManejo: cuotaManejo,
            diaCorte: 15,
            diaPago: 5),
      );

  Future<int> saldo(int idCuenta) async => (await cuentas.obtenerCuenta(idCuenta)).saldo;

  setUp(() async {
    await base.abrir();
    deudas = DeudaHandler();
    cuentas = CuentaHandler();
    portafolios = PortafolioHandler();
  });

  tearDown(base.cerrar);

  test('compras con tarjeta suben la deuda hasta el cupo, sin 4x1000', () async {
    final visa = await crearTarjeta();
    await deudas.registrarCompra(visa, 600000, descripcion: 'Mercado');

    await expectLater(
        () => deudas.registrarCompra(visa, 500000), throwsException);

    final r = await deudas.resumen(visa);
    expect(r.deuda, 600000);
    expect(r.disponible, 400000);
    expect(r.interesEstimado, 12000);
    expect(await saldo(visa), -600000);
  });

  test('compras a cuotas: cuotas pagadas, cuota del mes y saldo pendiente',
      () async {
    final visa = await crearTarjeta();
    await deudas.registrarCompra(visa, 300000,
        numeroCuotas: 3, fecha: '2026-09-10 10:00:00');
    await deudas.registrarCompra(visa, 50000); // de contado: no se lista

    final r = await deudas.resumen(visa, hoy: DateTime(2026, 11, 13));
    expect(r.comprasACuotas, hasLength(1));
    final compra = r.comprasACuotas.single;
    expect(compra.cuotasPagadas, 2);
    expect(compra.cuotaMensual, 100000);
    expect(compra.saldoPendiente, 100000);
    expect(r.cuotasDelMes, 100000);
    expect(r.proximoCorte, DateTime(2026, 11, 15));
    expect(r.proximoPago, DateTime(2026, 12, 5));
  });

  test('pagar la tarjeta desde ahorros: baja la deuda y cobra el 4x1000 allí',
      () async {
    final ahorros = await crearAhorros(saldo: 1000000);
    final visa = await crearTarjeta();
    await deudas.registrarCompra(visa, 600000);

    await deudas.pagar(visa, idCuentaOrigen: ahorros, valor: 600000);

    expect((await deudas.resumen(visa)).deuda, 0);
    expect(await saldo(ahorros), 1000000 - 600000 - 2400);
  });

  test('intereses del extracto suben la deuda', () async {
    final visa = await crearTarjeta();
    await deudas.registrarCompra(visa, 100000);
    await deudas.registrarIntereses(visa, 2000);
    expect((await deudas.resumen(visa)).deuda, 102000);
  });

  test('la cuota de manejo se registra sola desde el día de corte, una vez',
      () async {
    final visa = await crearTarjeta(cuotaManejo: 30000);
    final condiciones =
        await CondicionesCreditoSchema().getById(visa);
    final fijo =
        await RecurrenteSchema().getById(condiciones!.recurrenteManejoId!);
    expect(fijo!.automatico, isTrue);
    expect(fijo.valor, 30000);

    final hoy = DateTime.now();
    final recurrentes = RecurrenteHandler();
    expect(
        await recurrentes.registrarAutomaticos(
            fecha: DateTime(hoy.year, hoy.month + 1, 10)),
        isEmpty);
    expect(
        await recurrentes.registrarAutomaticos(
            fecha: DateTime(hoy.year, hoy.month + 1, 20)),
        hasLength(1));
    expect(
        await recurrentes.registrarAutomaticos(
            fecha: DateTime(hoy.year, hoy.month + 1, 25)),
        isEmpty);
    expect(await saldo(visa), -30000);

    // Quitar la cuota de manejo pausa el fijo.
    await deudas.guardarTarjeta(
      CuentaDto(
          idCuenta: visa, nombre: 'Visa', tipoCuenta: TipoCuenta.tarjetaCredito),
      CondicionesCreditoDto(cupo: 1000000, tasaMensual: 2000, cuotaManejo: 0),
    );
    expect((await RecurrenteSchema().getById(fijo.idRecurrente!))!.activo,
        isFalse);
  });

  test('préstamo: desembolso, cuota fija y pago de cuota capital + intereses',
      () async {
    final ahorros = await crearAhorros();
    final prestamo = await deudas.crearPrestamo(
      CuentaDto(nombre: 'Libre inversión', tipoCuenta: TipoCuenta.prestamo),
      CondicionesCreditoDto(cupo: 10000000, tasaMensual: 1500, plazoMeses: 12),
      idCuentaDesembolso: ahorros,
    );

    expect(await saldo(ahorros), 10000000);
    var r = await deudas.resumen(prestamo);
    expect(r.deuda, 10000000);
    expect(r.cuotaFija, 916800);
    expect(r.amortizacion, hasLength(12));
    expect(r.amortizacion.last.saldo, 0);

    await deudas.pagarCuotaPrestamo(prestamo, idCuentaOrigen: ahorros);

    r = await deudas.resumen(prestamo);
    expect(r.deuda, 9233200);
    // Abono 766.800 + 4x1000 3.067; intereses 150.000 + 4x1000 600.
    expect(await saldo(ahorros), 9079533);
  });

  test('validaciones de deudas', () async {
    final ahorros = await crearAhorros();
    await expectLater(() => crearTarjeta(cupo: 0), throwsException);
    await expectLater(
        () => deudas.crearPrestamo(
              CuentaDto(nombre: 'X', tipoCuenta: TipoCuenta.prestamo),
              CondicionesCreditoDto(cupo: 1000, tasaMensual: 0, plazoMeses: 0),
              idCuentaDesembolso: ahorros,
            ),
        throwsException);
    await expectLater(
        () => deudas.registrarCompra(ahorros, 1000), throwsException);
    await expectLater(() => deudas.resumen(ahorros), throwsException);
  });

  test('eliminar una tarjeta sin movimientos elimina su cuota de manejo',
      () async {
    final visa = await crearTarjeta(cuotaManejo: 20000);
    final idFijo =
        (await CondicionesCreditoSchema().getById(visa))!.recurrenteManejoId!;
    await cuentas.eliminarCuenta(visa);
    expect(await RecurrenteSchema().getById(idFijo), isNull);
    expect(await CondicionesCreditoSchema().getById(visa), isNull);
    expect(await PortafolioSchema().getPrincipalDeCuenta(visa), isNull);
  });

  test('calculadora: cuota fija sin interés y conversión de tasa', () {
    expect(CalculadoraCredito.cuotaFija(1200, 0, 12), 100);
    expect(CalculadoraCredito.tasaDesdePorcentaje(1.85), 1850);
    expect(CalculadoraCredito.porcentaje(1850), 1.85);
    expect(CalculadoraCredito.interesMensual(-5, 2000), 0);
  });

  test('el saldo inicial de una cuenta queda en su portafolio principal', () async {
    final ahorros = await crearAhorros(saldo: 10);
    final principal =
        (await PortafolioSchema().getPrincipalDeCuenta(ahorros))!.idPortafolio!;
    expect(await portafolios.obtenerSaldo(principal), 10);
  });
}
