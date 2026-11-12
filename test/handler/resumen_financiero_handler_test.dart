import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
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
          {int? destino, String? externo}) =>
      TransaccionHandler().createTransaccion(TransaccionDto(
          valor: valor,
          tipoTransferenciaId: tipo,
          portafolioId: origen,
          destinoCuenta: destino,
          destinoAlternativo: externo,
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

    await registrar('2026-10-05', ingreso, a, 1000000);
    await registrar('2026-11-02', egreso, a, 100000); // GMF 400
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

    expect(r.saldos, hasLength(3));
    expect(r.ultimosMovimientos, hasLength(ResumenFinancieroHandler.limiteMovimientos));
    expect(r.ultimosMovimientos.first.valor, 10000); // el más reciente
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

  test('portafolio inexistente lanza excepción', () async {
    await expectLater(() => resumen.resumenPortafolio(999), throwsException);
  });
}
