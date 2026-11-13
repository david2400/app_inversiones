import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/recurrente_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/recurrente_interface.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late IRecurrente fijos;
  late int egreso, cuenta, idFijo;
  final noviembre = DateTime(2026, 11, 15);
  final diciembre = DateTime(2026, 12, 3);

  setUp(() async {
    await base.abrir();
    fijos = RecurrenteHandler();
    final ingreso = await base.crearTipo('Ingreso', TipoFuente.ingreso);
    egreso = await base.crearTipo('Arriendo', TipoFuente.egreso);
    cuenta = await base.crearPortafolio('Ahorros', 'N');

    final transacciones = TransaccionHandler();
    await transacciones.createTransaccion(TransaccionDto(
        valor: 10000000,
        tipoTransferenciaId: ingreso,
        portafolioId: cuenta,
        createdAt: '2026-11-01 08:00:00'));

    // Se registra el arriendo de noviembre y se marca como fijo (día 5).
    final movimiento = TransaccionDto(
        valor: 1500000,
        tipoTransferenciaId: egreso,
        portafolioId: cuenta,
        createdAt: '2026-11-05 08:00:00');
    final idMovimiento = await transacciones.createTransaccion(movimiento);
    idFijo = await fijos.crearDesdeMovimiento(movimiento,
        idTransaccion: idMovimiento, nombre: 'Arriendo', diaMes: 5);
  });

  tearDown(base.cerrar);

  test('el mes en que se creó queda registrado; el siguiente, pendiente',
      () async {
    expect(await fijos.pendientesDelMes(fecha: noviembre), isEmpty);

    final diciembrePendientes = await fijos.pendientesDelMes(fecha: diciembre);
    expect(diciembrePendientes.single.nombre, 'Arriendo');
    expect(diciembrePendientes.single.fechaProgramada, DateTime(2026, 12, 5));
  });

  test('registrar crea el movimiento con GMF y no permite duplicarlo',
      () async {
    final saldoAntes = await PortafolioHandler().obtenerSaldo(cuenta);
    await fijos.registrar(idFijo, fecha: diciembre);

    expect(await PortafolioHandler().obtenerSaldo(cuenta),
        saldoAntes - 1500000 - 6000);
    expect(await fijos.pendientesDelMes(fecha: diciembre), isEmpty);
    await expectLater(
        () => fijos.registrar(idFijo, fecha: diciembre), throwsException);
  });

  test('pausar lo saca de pendientes; validaciones de día y valor', () async {
    await fijos.actualizar(idFijo, activo: false);
    expect(await fijos.pendientesDelMes(fecha: diciembre), isEmpty);

    await expectLater(
        () => fijos.actualizar(idFijo, diaMes: 32), throwsException);
    await expectLater(() => fijos.actualizar(idFijo, valor: 0), throwsException);
  });

  test('día 31 en un mes corto cae en el último día', () {
    expect(RecurrenteHandler.fechaEnMes(DateTime(2027, 2, 10), 31),
        DateTime(2027, 2, 28));
  });
}
