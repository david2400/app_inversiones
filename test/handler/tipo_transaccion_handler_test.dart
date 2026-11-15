import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/tipo_transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_transaccion_interface.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late ITipoTransaccion tipos;

  setUp(() async {
    await base.abrir();
    tipos = TipoTransaccionHandler();
  });

  tearDown(base.cerrar);

  TipoTransaccionDto nuevo(String nombre, String fuente) =>
      TipoTransaccionDto(nombre: nombre, descripcion: '', tipoFuente: fuente);

  test('hay un tipo del sistema por naturaleza, protegido', () async {
    final lista = await tipos.listarTipoTransaccion();
    final sistema = lista.where((t) => t.esSistema).toList();
    expect(sistema.map((t) => t.tipoFuente).toSet(),
        {TipoFuente.ingreso, TipoFuente.egreso, TipoFuente.transferencia});
    final ingreso =
        sistema.firstWhere((t) => t.tipoFuente == TipoFuente.ingreso);

    // La app lo usa para sus operaciones.
    expect(
        (await TipoTransaccionSchema().getPrimeroPorFuente(TipoFuente.ingreso))!
            .idTipoTransaccion,
        ingreso.idTipoTransaccion);

    await expectLater(
        () => tipos.deleteTipoTransaccion(ingreso.idTipoTransaccion!),
        throwsException);
    await expectLater(
        () => tipos.cambiarActivo(ingreso.idTipoTransaccion!, false),
        throwsException);
    await expectLater(
        () => tipos.guardarTipoTransaccion(TipoTransaccionDto(
            idTipoTransaccion: ingreso.idTipoTransaccion,
            nombre: ingreso.nombre,
            descripcion: '',
            tipoFuente: TipoFuente.egreso)),
        throwsException);

    // Sí se puede renombrar.
    await tipos.guardarTipoTransaccion(TipoTransaccionDto(
        idTipoTransaccion: ingreso.idTipoTransaccion,
        nombre: 'Entradas',
        descripcion: 'Todo lo que entra',
        tipoFuente: TipoFuente.ingreso));
    expect((await tipos.obtenerTipoTransaccion(ingreso.idTipoTransaccion!))
        .nombre, 'Entradas');
  });

  test('validaciones: nombre único, obligatorio y naturaleza válida',
      () async {
    await tipos.guardarTipoTransaccion(nuevo('Salario', TipoFuente.ingreso));
    for (final invalido in [
      nuevo('  salario ', TipoFuente.ingreso),
      nuevo('  ', TipoFuente.ingreso),
      nuevo('Otro', 'X'),
    ]) {
      await expectLater(
          () => tipos.guardarTipoTransaccion(invalido), throwsException);
    }
  });

  test('con movimientos: no cambia de naturaleza ni se elimina; sí se oculta',
      () async {
    final id = await tipos.guardarTipoTransaccion(
        nuevo('Arriendo recibido', TipoFuente.ingreso));
    final portafolio = await base.crearPortafolio('Ahorros', 'S');
    await TransaccionHandler().createTransaccion(TransaccionDto(
        valor: 900000, tipoTransferenciaId: id, portafolioId: portafolio));

    final tipo = await tipos.obtenerTipoTransaccion(id);
    expect(tipo.cantidadMovimientos, 1);
    expect(tipo.totalMovido, 900000);

    await expectLater(
        () => tipos.guardarTipoTransaccion(TipoTransaccionDto(
            idTipoTransaccion: id,
            nombre: 'Arriendo recibido',
            descripcion: '',
            tipoFuente: TipoFuente.egreso)),
        throwsException);
    await expectLater(() => tipos.deleteTipoTransaccion(id), throwsException);

    await tipos.cambiarActivo(id, false);
    expect((await tipos.listarActivos()).map((t) => t.idTipoTransaccion),
        isNot(contains(id)));
    expect((await tipos.obtenerTipoTransaccion(id)).activo, isFalse);
    await tipos.cambiarActivo(id, true);
    expect((await tipos.listarActivos()).map((t) => t.idTipoTransaccion),
        contains(id));
  });

  test('sin uso: cambia de naturaleza y se elimina', () async {
    final id =
        await tipos.guardarTipoTransaccion(nuevo('Varios', TipoFuente.egreso));
    await tipos.guardarTipoTransaccion(TipoTransaccionDto(
        idTipoTransaccion: id,
        nombre: 'Varios',
        descripcion: '',
        tipoFuente: TipoFuente.ingreso));
    expect((await tipos.obtenerTipoTransaccion(id)).tipoFuente,
        TipoFuente.ingreso);
    await tipos.deleteTipoTransaccion(id);
    await expectLater(() => tipos.obtenerTipoTransaccion(id), throwsException);
  });
}
