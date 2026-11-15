import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/calculadora_meta.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/meta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/meta_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/metas/dto/meta_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late IMeta metas;
  late PortafolioHandler portafolios;
  final hoy = DateTime(2026, 11, 14);

  /// Ahorros con 2.000.000 y un CDT (0 % E.A.) con 500.000 aportados desde
  /// ahorros. Retorna (principal de ahorros, cdt).
  Future<(int, int)> escenario({int tasaCdt = 0}) async {
    final ahorros = await CuentaHandler().guardarCuenta(
        CuentaDto(
            nombre: 'Ahorros',
            tipoCuenta: TipoCuenta.ahorros,
            exentaImpuesto: 'S'),
        saldoInicial: 2000000);
    final principal =
        (await PortafolioSchema().getPrincipalDeCuenta(ahorros))!.idPortafolio!;
    final cdt = await portafolios.createPortafolio(PortafolioDto(
        nombre: 'CDT viaje',
        proyectoId: 1,
        interes: tasaCdt,
        exentaImpuesto: 'S',
        cuentaAportesId: ahorros));
    await TransaccionHandler().registrarAporte(cdt, 500000);
    return (principal, cdt);
  }

  MetaDto viaje(List<int> ids, {String? fecha = '2027-11-14', int monto = 3000000}) =>
      MetaDto(
          nombre: 'Viaje', montoObjetivo: monto, fechaObjetivo: fecha, portafolioIds: ids);

  setUp(() async {
    await base.abrir();
    metas = MetaHandler();
    portafolios = PortafolioHandler();
  });

  tearDown(base.cerrar);

  test('calculadora: meses, cuota con y sin rendimiento y proyección', () {
    expect(CalculadoraMeta.mesesRestantes(hoy, DateTime(2027, 11, 14)), 12);
    expect(CalculadoraMeta.mesesRestantes(hoy, DateTime(2027, 11, 13)), 11);
    expect(CalculadoraMeta.mesesRestantes(hoy, DateTime(2026, 10, 1)), 0);

    expect(
        CalculadoraMeta.cuotaMensual(
            objetivo: 1200000, saldo: 0, tasaEa: 0, meses: 12),
        100000);
    final conTasa = CalculadoraMeta.cuotaMensual(
        objetivo: 1200000, saldo: 0, tasaEa: 10, meses: 12);
    expect(conTasa, lessThan(100000));
    expect(conTasa, greaterThan(90000));
    // Con la cuota sugerida la proyección llega al objetivo.
    expect(
        CalculadoraMeta.proyectar(
            saldo: 0, aporteMensual: conTasa, tasaEa: 10, meses: 12),
        greaterThanOrEqualTo(1200000));
    // El saldo actual con rendimiento ya alcanza: no hace falta aportar.
    expect(
        CalculadoraMeta.cuotaMensual(
            objetivo: 1050000, saldo: 1000000, tasaEa: 10, meses: 12),
        0);
    expect(
        CalculadoraMeta.tasaPonderada(
            [(saldo: 300, tasaEa: 10), (saldo: 100, tasaEa: 2)]),
        8);
  });

  test('el avance es la suma de los saldos y el aporte la pone al día',
      () async {
    final (principal, cdt) = await escenario();
    final id = await metas.guardar(viaje([cdt, principal]));

    var avance = await metas.obtenerAvance(id, hoy: hoy);
    expect(avance.ahorrado, 2000000); // 1.500.000 en ahorros + 500.000 CDT
    expect(avance.falta, 1000000);
    expect(avance.porcentaje, closeTo(2 / 3, 0.001));
    expect(avance.mesesRestantes, 12);
    expect(avance.cuotaSugerida, 83334);
    expect(avance.estado, EstadoMeta.atrasada);

    // El CDT recibe sus aportes desde ahorros, que también es de la meta:
    // ese aporte no haría crecer el total.
    await expectLater(
        () => metas.programarAporte(id, idPortafolio: cdt, hoy: hoy),
        throwsException);

    // Solo con el CDT, el aporte desde ahorros sí suma.
    final dto = await metas.obtenerMeta(id);
    expect(dto.portafolioIds, unorderedEquals([cdt, principal]));
    dto.portafolioIds = [cdt];
    await metas.guardar(dto);
    avance = await metas.obtenerAvance(id, hoy: hoy);
    expect(avance.ahorrado, 500000);
    expect(avance.cuotaSugerida, 208334);

    await metas.programarAporte(id, idPortafolio: cdt, diaMes: 5, hoy: hoy);
    avance = await metas.obtenerAvance(id, hoy: hoy);
    expect(avance.aporteProgramadoMensual, 208334);
    expect(avance.proyeccion, greaterThanOrEqualTo(3000000));
    expect(avance.estado, EstadoMeta.alDia);

    // Si se vuelve a agregar ahorros, ese aporte pasa a ser interno.
    dto.portafolioIds = [cdt, principal];
    await metas.guardar(dto);
    avance = await metas.obtenerAvance(id, hoy: hoy);
    expect(avance.aporteProgramadoMensual, 0);
    expect(avance.estado, EstadoMeta.atrasada);
  });

  test('estados: sin fecha, completada, vencida y pausada', () async {
    final (principal, cdt) = await escenario();
    final fondo = await metas.guardar(viaje([principal], fecha: null));
    expect((await metas.obtenerAvance(fondo, hoy: hoy)).estado,
        EstadoMeta.sinFecha);

    final lista = await metas.guardar(viaje([cdt], monto: 400000));
    expect((await metas.obtenerAvance(lista, hoy: hoy)).estado,
        EstadoMeta.completada);

    await metas.cambiarActivo(fondo, false);
    expect((await metas.obtenerAvance(fondo, hoy: hoy)).estado,
        EstadoMeta.pausada);

    final dto = await metas.obtenerMeta(lista);
    dto
      ..montoObjetivo = 9000000
      ..fechaObjetivo = '2026-11-01';
    await metas.guardar(dto);
    expect((await metas.obtenerAvance(lista, hoy: hoy)).estado,
        EstadoMeta.vencida);

    final resumen = await metas.resumen(hoy: hoy);
    expect(resumen.cantidad, 1); // la pausada no cuenta
    expect(resumen.atrasadas, 1);
    expect(resumen.destacadas.single.idMeta, lista);
  });

  test('validaciones y un portafolio por meta', () async {
    final (principal, cdt) = await escenario();
    await expectLater(() => metas.guardar(viaje([])), throwsException);
    await expectLater(() => metas.guardar(viaje([cdt], monto: 0)), throwsException);
    await expectLater(
        () => metas.guardar(MetaDto(
            nombre: '  ', montoObjetivo: 1000, portafolioIds: [cdt])),
        throwsException);
    await expectLater(
        () => metas.guardar(viaje([cdt], fecha: 'mañana')), throwsException);

    final id = await metas.guardar(viaje([cdt]));
    await expectLater(() => metas.guardar(viaje([cdt, principal])),
        throwsException);
    expect(
        (await metas.portafoliosDisponibles()).map((p) => p.idPortafolio),
        isNot(contains(cdt)));
    // La propia meta sí puede seguir usándolo al editarse.
    expect(
        (await metas.portafoliosDisponibles(idMeta: id))
            .map((p) => p.idPortafolio),
        contains(cdt));

    // Al eliminar la meta el portafolio queda libre.
    await metas.eliminar(id);
    expect(
        (await metas.portafoliosDisponibles()).map((p) => p.idPortafolio),
        contains(cdt));
    await expectLater(() => metas.obtenerAvance(id), throwsException);
  });

  test('eliminar un portafolio lo quita de su meta', () async {
    final (principal, _) = await escenario();
    final vacio = await portafolios.createPortafolio(
        PortafolioDto(nombre: 'Cajita', proyectoId: 1, exentaImpuesto: 'S'));
    final id = await metas.guardar(viaje([principal, vacio]));
    await portafolios.deletePortafolio(vacio);
    expect((await metas.obtenerMeta(id)).portafolioIds, [principal]);
  });
}
