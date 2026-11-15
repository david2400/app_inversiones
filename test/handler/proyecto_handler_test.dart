import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/infraestructure/handler/implementations/proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/proyecto_interface.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late IProyecto proyectos;

  setUp(() async {
    await base.abrir();
    proyectos = ProyectoHandler();
  });

  tearDown(base.cerrar);

  test('editar un proyecto cambia nombre y descripción', () async {
    final id = await proyectos.createProyecto(ProyectoDto(
        nombre: 'Finca', descripcion: 'Lote', usuarioId: 1));

    await proyectos.actualizarProyecto(ProyectoDto(
        idProyecto: id,
        nombre: ' Finca La Esperanza ',
        descripcion: 'Lote y casa',
        usuarioId: 1));

    final editado = await proyectos.obtenerProyecto(id);
    expect(editado.nombre, 'Finca La Esperanza');
    expect(editado.descripcion, 'Lote y casa');
    expect(editado.createdAt, isNotNull);

    await expectLater(
        () => proyectos.actualizarProyecto(ProyectoDto(
            idProyecto: id, nombre: '  ', descripcion: '', usuarioId: 1)),
        throwsException);
    await expectLater(() => proyectos.obtenerProyecto(9999), throwsException);
  });
}
