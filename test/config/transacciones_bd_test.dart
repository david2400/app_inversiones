import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/entity/tercero_entity.dart';
import 'package:inversiones/domain/schema/tercero_schema.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();

  setUp(base.abrir);
  tearDown(base.cerrar);

  test('si algo falla dentro de la transacción, se revierte todo', () async {
    await expectLater(
      () => DatabaseHelper().enTransaccion(() async {
        await TerceroSchema().insert(Tercero(nombre: 'Temporal'));
        throw Exception('falla a mitad de camino');
      }),
      throwsException,
    );
    expect(await TerceroSchema().getAll(), isEmpty);
  });

  test('las transacciones anidadas se confirman juntas', () async {
    await DatabaseHelper().enTransaccion(() async {
      await TerceroSchema().insert(Tercero(nombre: 'Uno'));
      await DatabaseHelper().enTransaccion(
          () => TerceroSchema().insert(Tercero(nombre: 'Dos')));
    });
    expect((await TerceroSchema().getAll()).map((t) => t.nombre), ['Dos', 'Uno']);
  });
}
