import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/calculadora_rendimiento.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late TransaccionHandler transacciones;
  late PortafolioHandler portafolios;

  setUp(() async {
    await base.abrir();
    transacciones = TransaccionHandler();
    portafolios = PortafolioHandler();
  });

  tearDown(base.cerrar);

  test('corregir un egreso recalcula el GMF y deja el original anulado',
      () async {
    final ingreso = await base.crearTipo('Ingreso X', TipoFuente.ingreso);
    final egreso = await base.crearTipo('Egreso X', TipoFuente.egreso);
    final cuenta = await base.crearPortafolio('Ahorros', 'N');
    await transacciones.createTransaccion(TransaccionDto(
        valor: 1000000, tipoTransferenciaId: ingreso, portafolioId: cuenta));
    final id = await transacciones.createTransaccion(TransaccionDto(
        valor: 100000,
        tipoTransferenciaId: egreso,
        portafolioId: cuenta,
        createdAt: '2026-10-05 10:00:00'));
    expect(await portafolios.obtenerSaldo(cuenta), 1000000 - 100000 - 400);

    final nuevo = await transacciones.corregirTransaccion(
        id,
        TransaccionDto(
            valor: 250000, tipoTransferenciaId: egreso, portafolioId: cuenta));
    expect(nuevo, isNot(id));
    expect(await portafolios.obtenerSaldo(cuenta), 1000000 - 250000 - 1000);
    // Conserva la fecha del original y el original queda anulado.
    final corregido = await transacciones.findTransaccion(nuevo);
    expect(corregido.createdAt, '2026-10-05 10:00:00');
    expect(corregido.impuesto, 1000);
    expect(await TransferenciaShema().getById(id), isNull);

    // Si la corrección no cabe en el saldo, no se anula nada.
    await expectLater(
        () => transacciones.corregirTransaccion(
            nuevo,
            TransaccionDto(
                valor: 5000000,
                tipoTransferenciaId: egreso,
                portafolioId: cuenta)),
        throwsException);
    expect(await TransferenciaShema().getById(nuevo), isNotNull);
    expect(await portafolios.obtenerSaldo(cuenta), 1000000 - 250000 - 1000);
  });

  test('retirar un CDT vencido a su cuenta y avisar su vencimiento', () async {
    final ahorros = await CuentaHandler().guardarCuenta(
        CuentaDto(
            nombre: 'Ahorros',
            tipoCuenta: TipoCuenta.ahorros,
            exentaImpuesto: 'S'),
        saldoInicial: 2000000);
    final cdt = await portafolios.createPortafolio(PortafolioDto(
        nombre: 'CDT 180',
        proyectoId: 1,
        interes: 12,
        exentaImpuesto: 'N',
        cuentaAportesId: ahorros,
        fechaApertura: '2026-01-01',
        fechaVencimiento: '2026-07-01'));
    await transacciones.registrarAporte(cdt, 1000000);

    final vencimientos = await portafolios.listarVencimientos(
        hoy: DateTime(2026, 6, 20), dias: 30);
    expect(vencimientos.single.idPortafolio, cdt);
    expect(vencimientos.single.diasRestantes, 11);
    expect(vencimientos.single.rendimientoEstimado, greaterThan(0));
    expect(
        await portafolios.listarVencimientos(
            hoy: DateTime(2026, 5, 1), dias: 30),
        isEmpty);

    // Retira todo: el CDT paga 4x1000, así que llega el saldo menos el GMF.
    await transacciones.retirarACuenta(cdt);
    expect(await portafolios.obtenerSaldo(cdt), inInclusiveRange(0, 1));
    final principal =
        (await PortafolioSchema().getPrincipalDeCuenta(ahorros))!.idPortafolio!;
    expect(await portafolios.obtenerSaldo(principal),
        greaterThan(2000000 - 1000000 + 995000));
    await expectLater(
        () => transacciones.retirarACuenta(cdt, valor: 1000000),
        throwsException);
  });

  test('plazo inválido y proyección de rendimiento', () async {
    await expectLater(
        () => portafolios.createPortafolio(PortafolioDto(
            nombre: 'Mal',
            proyectoId: 1,
            fechaApertura: '2026-05-01',
            fechaVencimiento: '2026-04-01')),
        throwsException);
    // 10 % E.A. durante un año completo.
    expect(
        CalculadoraRendimiento.rendimiento(
            capital: 1000000, tasaEa: 10, dias: 365),
        100000);
    expect(
        CalculadoraRendimiento.rendimiento(
            capital: 1000000, tasaEa: 10, dias: 0),
        0);
  });
}
