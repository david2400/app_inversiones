import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/infraestructure/handler/implementations/motivo_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/motivo_interface.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late IMotivo motivos;

  setUp(() async {
    await base.abrir();
    motivos = MotivoHandler();
  });

  tearDown(base.cerrar);

  MotivosDto nuevo(String nombre, {String? naturaleza}) =>
      MotivosDto(nombre: nombre, descripcion: '', naturaleza: naturaleza);

  test('los motivos base traen su naturaleza y se filtran por ella', () async {
    final ingresos =
        (await motivos.listarActivos(naturaleza: TipoFuente.ingreso))
            .map((m) => m.nombre);
    expect(ingresos, contains('Salario'));
    expect(ingresos, isNot(contains('Mercado')));
    // "Otros" sirve para ambos.
    expect(ingresos, contains('Otros'));

    final gastos = (await motivos.listarActivos(naturaleza: TipoFuente.egreso))
        .map((m) => m.nombre);
    expect(gastos, containsAll(['Mercado', 'Otros']));
    expect(gastos, isNot(contains('Salario')));
  });

  test('crear, editar y validar', () async {
    final id = await motivos
        .guardarMotivo(nuevo('  Mascotas ', naturaleza: TipoFuente.egreso));
    var motivo = await motivos.obtenerMotivo(id);
    expect(motivo.nombre, 'Mascotas');
    expect(motivo.naturaleza, TipoFuente.egreso);

    await motivos.guardarMotivo(MotivosDto(
        idMotivo: id, nombre: 'Mascotas', descripcion: 'Comida', naturaleza: ''));
    motivo = await motivos.obtenerMotivo(id);
    expect(motivo.naturaleza, isNull);
    expect(motivo.descripcion, 'Comida');

    for (final invalido in [
      nuevo('mascotas'),
      nuevo('  '),
      nuevo('X', naturaleza: 'M'),
    ]) {
      await expectLater(
          () => motivos.guardarMotivo(invalido), throwsException);
    }
  });

  test('con movimientos no se elimina; se oculta y vuelve a aparecer',
      () async {
    final id = await motivos
        .guardarMotivo(nuevo('Bonos', naturaleza: TipoFuente.ingreso));
    final ingreso = await base.crearTipo('Ingreso X', TipoFuente.ingreso);
    final portafolio = await base.crearPortafolio('Ahorros', 'S');
    await TransaccionHandler().createTransaccion(TransaccionDto(
        valor: 250000,
        tipoTransferenciaId: ingreso,
        portafolioId: portafolio,
        motivoId: id));

    final motivo = await motivos.obtenerMotivo(id);
    expect(motivo.cantidadMovimientos, 1);
    expect(motivo.totalMovido, 250000);
    await expectLater(() => motivos.deleteMotivo(id), throwsException);

    await motivos.cambiarActivo(id, false);
    expect((await motivos.listarActivos()).map((m) => m.idMotivo),
        isNot(contains(id)));
    // Sigue en la administración, como inactivo.
    expect((await motivos.listarConUso())
        .singleWhere((m) => m.idMotivo == id)
        .activo, isFalse);
    await motivos.cambiarActivo(id, true);
    expect((await motivos.listarActivos()).map((m) => m.idMotivo),
        contains(id));

    final sinUso = await motivos.guardarMotivo(nuevo('Temporal'));
    await motivos.deleteMotivo(sinUso);
    await expectLater(() => motivos.obtenerMotivo(sinUso), throwsException);
  });
}
