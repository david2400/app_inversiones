import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/entity/motivos_entity.dart';
import 'package:inversiones/domain/models/filtro_movimientos.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/domain/entity/tercero_entity.dart';
import 'package:inversiones/domain/schema/tercero_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/resumen_financiero_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/resumen_financiero_interface.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late IResumenFinanciero resumen;
  late int a, b, c;

  Future<void> registrar(String fecha, int tipo, int origen, int valor,
          {int? destino, String? externo, int? motivo, int? tercero}) =>
      TransaccionHandler().createTransaccion(TransaccionDto(
          valor: valor,
          tipoTransferenciaId: tipo,
          portafolioId: origen,
          destinoCuenta: destino,
          destinoAlternativo: externo,
          motivoId: motivo,
          terceroId: tercero,
          createdAt: '$fecha 10:00:00'));

  setUp(() async {
    await base.abrir();
    resumen = ResumenFinancieroHandler();

    final ingreso = await base.crearTipo('Ingreso', TipoFuente.ingreso);
    final egreso = await base.crearTipo('Egreso', TipoFuente.egreso);
    final transferencia =
        await base.crearTipo('Transferencia', TipoFuente.transferencia);

    a = await base.crearPortafolio('A', 'N', proyectoId: 1); // gravado
    b = await base.crearPortafolio('B', 'S', proyectoId: 1); // exento
    c = await base.crearPortafolio('C', 'S', proyectoId: 2);

    final empresa = await TerceroSchema()
        .insert(Tercero(nombre: 'Empresa XYZ'));
    await registrar('2026-10-05', ingreso, a, 1000000, tercero: empresa);
    final comida = await MotivosSchema()
        .insert(Motivos(nombre: 'Comida', descripcion: ''));
    await registrar('2026-11-02', egreso, a, 100000,
        motivo: comida); // GMF 400
    await registrar('2026-11-03', transferencia, a, 200000,
        destino: b); // interna, GMF 800
    await registrar('2026-11-04', transferencia, a, 50000,
        destino: c); // a otro proyecto, GMF 200
    await registrar('2026-11-05', transferencia, a, 10000,
        externo: 'Banco X'); // externa, GMF 40
  });

  tearDown(base.cerrar);

  test('dashboard: saldo total, mes actual e histórico', () async {
    final r = await resumen.obtenerResumen(fecha: DateTime(2026, 11, 15));

    // 1.000.000 - egresos externos 110.000 - GMF 1.440
    expect(r.saldoTotal, 888560);
    expect(r.historico, hasLength(ResumenFinancieroHandler.mesesHistorico));
    expect(r.historico.first.periodo, '2026-06');
    expect(r.historico.last.periodo, '2026-11');

    final octubre = r.historico[r.historico.length - 2];
    expect(octubre.ingresos, 1000000);

    // Las transferencias entre portafolios propios no son egresos.
    expect(r.mesActual.ingresos, 0);
    expect(r.mesActual.egresos, 110000);
    expect(r.mesActual.impuestos, 1440);
    expect(r.mesActual.neto, -111440);

    // 3 portafolios del test + el principal de "Efectivo / Sin definir".
    expect(r.saldos, hasLength(4));
    expect(r.ultimosMovimientos, hasLength(ResumenFinancieroHandler.limiteMovimientos));
    expect(r.ultimosMovimientos.first.valor, 10000); // el más reciente

    // ¿A dónde se fue el dinero? Egresos y transferencias externas del mes.
    expect(r.egresosPorMotivo, hasLength(2));
    expect(r.egresosPorMotivo.first.nombre, 'Comida');
    expect(r.egresosPorMotivo.first.total, 100000);
    expect(r.egresosPorMotivo.last.nombre, isNull);
    // En noviembre no hubo ingresos.
    expect(r.ingresosPorOrigen, isEmpty);
    expect(r.egresosPorMotivo.last.total, 10000);
  });

  test('proyecto: excluye transferencias internas', () async {
    final p1 = await resumen.resumenProyecto(1);
    expect(p1.ingresos, 1000000);
    expect(p1.egresos, 160000); // egreso + a otro proyecto + externa
    expect(p1.impuestos, 1440);
    expect(p1.saldo, 838560); // = saldo A + saldo B

    final p2 = await resumen.resumenProyecto(2);
    expect(p2.ingresos, 50000);
    expect(p2.saldo, 50000);
  });

  test('portafolio: incluye transferencias entrantes', () async {
    final totalB = await resumen.resumenPortafolio(b);
    expect(totalB.ingresos, 200000);
    expect(totalB.saldo, 200000);

    final totalA = await resumen.resumenPortafolio(a);
    expect(totalA.saldo, 1000000 - 100400 - 200800 - 50200 - 10040);
  });

  test('reporte anual global: 12 meses y totales', () async {
    final r = await resumen.reporteAnual(anio: 2026);
    expect(r.meses, hasLength(12));
    expect(r.meses.first.periodo, '2026-01');
    expect(r.meses[9].ingresos, 1000000); // octubre
    expect(r.meses[10].egresos, 110000); // noviembre, sin transferencias internas
    expect(r.total.ingresos, 1000000);
    expect(r.total.impuestos, 1440);
    expect(r.total.neto, 1000000 - 110000 - 1440);

    // ¿De dónde vino? El ingreso de octubre, por tercero.
    expect(r.ingresosPorOrigen.single.nombre, 'Empresa XYZ');
    expect(r.ingresosPorOrigen.single.total, 1000000);

    // ¿A dónde se fue? Motivo si no hay tercero; cuenta externa si aplica.
    expect(r.egresosPorDestino.map((e) => e.nombre), ['Comida', 'Banco X']);

    // Movimientos entre cuentas: de mayor a menor, con GMF.
    expect(r.flujosEntreCuentas, hasLength(3));
    expect(r.flujosEntreCuentas.first.origen, 'A');
    expect(r.flujosEntreCuentas.first.destino, 'B');
    expect(r.flujosEntreCuentas.first.externo, isFalse);
    expect(r.flujosEntreCuentas.first.impuestos, 800);
    expect(r.flujosEntreCuentas.last.destino, 'Banco X');
    expect(r.flujosEntreCuentas.last.externo, isTrue);

    // Evolución: saldo al cierre de octubre y noviembre (= saldo total).
    expect(r.saldoInicialAnio, 0);
    expect(r.saldosAlCierre[9], 1000000);
    expect(r.saldosAlCierre[10], 888560);

    // El año siguiente arranca con el saldo acumulado.
    final siguiente = await resumen.reporteAnual(anio: 2027);
    expect(siguiente.saldoInicialAnio, 888560);

    final vacio = await resumen.reporteAnual(anio: 2025);
    expect(vacio.total.ingresos, 0);
  });

  test('reporte anual por proyecto', () async {
    final p1 = await resumen.reporteAnual(anio: 2026, idProyecto: 1);
    expect(p1.meses[10].egresos, 160000);
    expect(p1.total.neto, 838560);
    expect(p1.saldosAlCierre[10], 838560); // = saldo A + saldo B

    final p1Siguiente =
        await resumen.reporteAnual(anio: 2027, idProyecto: 1);
    expect(p1Siguiente.saldoInicialAnio, 838560);

    final p2 = await resumen.reporteAnual(anio: 2026, idProyecto: 2);
    expect(p2.meses[10].ingresos, 50000);
    expect(p2.total.egresos, 0);
    // Solo la transferencia que llega desde el proyecto 1.
    expect(p2.flujosEntreCuentas.single.destino, 'C');
    expect(p2.ingresosPorOrigen, isEmpty);
  });

  test('búsqueda de movimientos: filtros, texto, totales y límite', () async {
    final h = TransaccionHandler();

    final todo = await h.buscarMovimientos(const FiltroMovimientos());
    expect(todo.cantidadTotal, 5);
    expect(todo.totales.ingresos, 1000000);
    expect(todo.totales.egresos, 110000); // egreso + transferencia externa
    expect(todo.totales.impuestos, 1440);
    expect(todo.movimientos.first.valor, 10000); // el más reciente primero

    final transferencias = await h.buscarMovimientos(const FiltroMovimientos(
        desde: '2026-11-01',
        hasta: '2026-12-01',
        tipoFuente: TipoFuente.transferencia));
    expect(transferencias.movimientos, hasLength(3));

    final texto =
        await h.buscarMovimientos(const FiltroMovimientos(texto: 'banco'));
    expect(texto.movimientos.single.flujo, 'A → Banco X');

    final cuentaB = await h.buscarMovimientos(FiltroMovimientos(idPortafolio: b));
    expect(cuentaB.movimientos.single.valor, 200000);

    final limitado =
        await h.buscarMovimientos(const FiltroMovimientos(limite: 2));
    expect(limitado.movimientos, hasLength(2));
    expect(limitado.truncado, isTrue);
  });

  test('portafolio inexistente lanza excepción', () async {
    await expectLater(() => resumen.resumenPortafolio(999), throwsException);
  });
}
