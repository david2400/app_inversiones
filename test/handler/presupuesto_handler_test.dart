import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/entity/motivos_entity.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/presupuesto_impl.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/presupuesto_interface.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/page/presupuestos/dto/presupuesto_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late IPresupuesto presupuestos;
  late int egreso, transferencia, cuenta, otraCuenta, mercado;
  final noviembre = DateTime(2026, 11, 15);

  Future<void> gastar(int valor, String fecha, {int? tipo, int? destino}) =>
      TransaccionHandler().createTransaccion(TransaccionDto(
          valor: valor,
          tipoTransferenciaId: tipo ?? egreso,
          portafolioId: cuenta,
          destinoCuenta: destino,
          motivoId: mercado,
          createdAt: '$fecha 09:00:00'));

  setUp(() async {
    await base.abrir();
    presupuestos = PresupuestoHandler();
    final ingreso = await base.crearTipo('Ingreso', TipoFuente.ingreso);
    egreso = await base.crearTipo('Egreso', TipoFuente.egreso);
    transferencia =
        await base.crearTipo('Transferencia', TipoFuente.transferencia);
    cuenta = await base.crearPortafolio('Ahorros', 'S');
    otraCuenta = await base.crearPortafolio('Nequi', 'S');
    mercado = await MotivosSchema()
        .insert(Motivos(nombre: 'Mercado test', descripcion: ''));

    await TransaccionHandler().createTransaccion(TransaccionDto(
        valor: 2000000,
        tipoTransferenciaId: ingreso,
        portafolioId: cuenta,
        createdAt: '2026-11-01 08:00:00'));
  });

  tearDown(base.cerrar);

  Future<EjecucionPresupuestoDto> delMercado() async =>
      (await presupuestos.ejecucionDelMes(fecha: noviembre))
          .singleWhere((p) => p.motivoId == mercado);

  test('calcula gastado, porcentaje y estado', () async {
    await presupuestos.guardar(motivoId: mercado, montoMensual: 300000);

    await gastar(250000, '2026-11-05');
    var p = await delMercado();
    expect(p.gastado, 250000);
    expect(p.porcentaje, 83);
    expect(p.estado, EstadoPresupuesto.alerta);
    expect(p.disponible, 50000);

    await gastar(100000, '2026-11-20');
    p = await delMercado();
    expect(p.estado, EstadoPresupuesto.excedido);
    expect(p.disponible, -50000);
  });

  test('no cuenta otros meses ni transferencias entre cuentas propias',
      () async {
    await presupuestos.guardar(motivoId: mercado, montoMensual: 300000);
    await gastar(40000, '2026-10-28'); // octubre
    await gastar(90000, '2026-11-06',
        tipo: transferencia, destino: otraCuenta); // interna

    final p = await delMercado();
    expect(p.gastado, 0);
    expect(p.estado, EstadoPresupuesto.normal);
  });

  test('guardar actualiza sin duplicar; eliminar y validaciones', () async {
    await presupuestos.guardar(motivoId: mercado, montoMensual: 300000);
    await presupuestos.guardar(motivoId: mercado, montoMensual: 450000);
    final p = await delMercado();
    expect(p.montoMensual, 450000);

    await expectLater(
        () => presupuestos.guardar(motivoId: mercado, montoMensual: 0),
        throwsException);
    await expectLater(
        () => presupuestos.guardar(motivoId: 99999, montoMensual: 1000),
        throwsException);

    await presupuestos.eliminar(p.idPresupuesto);
    expect(await presupuestos.ejecucionDelMes(fecha: noviembre), isEmpty);
  });

  test('presupuesto por cuenta: solo cuenta lo que sale de esa cuenta',
      () async {
    final idNu = await CuentaHandler().guardarCuenta(
        CuentaDto(nombre: 'Nu', tipoCuenta: TipoCuenta.digital, exentaImpuesto: 'S'),
        saldoInicial: 500000);
    final principalNu =
        (await PortafolioSchema().getPrincipalDeCuenta(idNu))!.idPortafolio!;

    await presupuestos.guardar(motivoId: mercado, montoMensual: 300000);
    await presupuestos.guardar(
        motivoId: mercado, montoMensual: 100000, cuentaId: idNu);
    await presupuestos.guardar(
        motivoId: mercado, montoMensual: 50000, cuentaId: CuentaSchema.idEfectivo);
    // Actualizar el de la cuenta no crea otro.
    await presupuestos.guardar(
        motivoId: mercado, montoMensual: 120000, cuentaId: idNu);

    await gastar(80000, '2026-11-05');
    await TransaccionHandler().createTransaccion(TransaccionDto(
        valor: 30000,
        tipoTransferenciaId: egreso,
        portafolioId: principalNu,
        motivoId: mercado,
        createdAt: '2026-11-06 09:00:00'));

    final delMes = (await presupuestos.ejecucionDelMes(fecha: noviembre))
        .where((p) => p.motivoId == mercado)
        .toList();
    expect(delMes, hasLength(3));
    expect(delMes.singleWhere((p) => p.cuentaId == null).gastado, 110000);
    final deNu = delMes.singleWhere((p) => p.cuentaId == idNu);
    expect(deNu.gastado, 30000);
    expect(deNu.montoMensual, 120000);
    expect(deNu.cuenta, 'Nu');
    expect(
        delMes.singleWhere((p) => p.cuentaId == CuentaSchema.idEfectivo).gastado,
        0);

    await expectLater(
        () => presupuestos.guardar(
            motivoId: mercado, montoMensual: 1, cuentaId: 9999),
        throwsException);
  });
}
