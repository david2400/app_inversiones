import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/perfil_inversion.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/infraestructure/handler/implementations/proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/tipo_proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/proyecto_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_proyecto_interface.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late ITipoProyecto tipos;
  late IProyecto proyectos;

  setUp(() async {
    await base.abrir();
    tipos = TipoProyectoHandler();
    proyectos = ProyectoHandler();
  });

  tearDown(base.cerrar);

  Future<int> tipoPorNombre(String nombre) async =>
      (await tipos.listarTipoProyecto())
          .firstWhere((t) => t.nombre == nombre)
          .idTipoProyecto!;

  test('la instalación nueva trae tipos base con su riesgo', () async {
    final lista = await tipos.listarTipoProyecto();
    expect(lista.map((t) => t.nombre), contains('Renta fija'));
    final rentaFija = lista.firstWhere((t) => t.nombre == 'Renta fija');
    expect(rentaFija.riesgo, NivelRiesgo.bajo);
    expect(rentaFija.cantidadProyectos, 0);
  });

  test('crear, editar y validar un tipo de proyecto', () async {
    final id = await tipos.guardarTipoProyecto(TipoProyectoDto(
        nombre: '  Ganadería ',
        descripcion: 'Novillos',
        riesgo: ''));
    var tipo = await tipos.obtenerTipoProyecto(id);
    expect(tipo.nombre, 'Ganadería');
    expect(tipo.riesgo, isNull);

    await tipos.guardarTipoProyecto(TipoProyectoDto(
        idTipoProyecto: id,
        nombre: 'Ganadería',
        descripcion: '',
        riesgo: NivelRiesgo.alto));
    tipo = await tipos.obtenerTipoProyecto(id);
    expect(tipo.riesgo, NivelRiesgo.alto);

    // Nombre repetido (sin importar mayúsculas), vacío o códigos inválidos.
    for (final invalido in [
      TipoProyectoDto(nombre: 'renta FIJA', descripcion: ''),
      TipoProyectoDto(nombre: '  ', descripcion: ''),
      TipoProyectoDto(nombre: 'X', descripcion: '', riesgo: 'Z'),
    ]) {
      await expectLater(
          () => tipos.guardarTipoProyecto(invalido), throwsException);
    }
  });

  test('no se elimina un tipo con proyectos; sí uno sin uso', () async {
    final rentaFija = await tipoPorNombre('Renta fija');
    final idProyecto = await proyectos.createProyecto(ProyectoDto(
        nombre: 'CDTs',
        descripcion: '',
        usuarioId: 1,
        tipoProyectoId: rentaFija));

    expect((await tipos.obtenerTipoProyecto(rentaFija)).cantidadProyectos, 1);
    await expectLater(
        () => tipos.deleteTipoProyecto(rentaFija), throwsException);

    // Al cambiarle el tipo al proyecto, ya se puede eliminar.
    await proyectos.actualizarProyecto(ProyectoDto(
        idProyecto: idProyecto,
        nombre: 'CDTs',
        descripcion: '',
        usuarioId: 1,
        tipoProyectoId: 0));
    expect((await proyectos.obtenerProyecto(idProyecto)).tipoProyectoId,
        isNull);
    await tipos.deleteTipoProyecto(rentaFija);
    expect((await tipos.listarTipoProyecto()).map((t) => t.nombre),
        isNot(contains('Renta fija')));

    // Un tipo eliminado o inexistente no se puede asignar.
    await expectLater(
        () => proyectos.createProyecto(ProyectoDto(
            nombre: 'Otro',
            descripcion: '',
            usuarioId: 1,
            tipoProyectoId: rentaFija)),
        throwsException);
  });

  test('resumen de proyectos: tipo, saldo y cantidad de portafolios',
      () async {
    final fincaRaiz = await tipoPorNombre('Finca raíz');
    final idProyecto = await proyectos.createProyecto(ProyectoDto(
        nombre: 'Apartamento',
        descripcion: '',
        usuarioId: 1,
        tipoProyectoId: fincaRaiz));
    final ingreso = await base.crearTipo('Ingreso X', TipoFuente.ingreso);
    final p1 = await base.crearPortafolio('Arriendos', 'S',
        proyectoId: idProyecto);
    await base.crearPortafolio('Mantenimiento', 'S', proyectoId: idProyecto);
    await TransaccionHandler().createTransaccion(TransaccionDto(
        valor: 1200000, tipoTransferenciaId: ingreso, portafolioId: p1));

    final resumen = (await proyectos.listarResumen())
        .firstWhere((r) => r.proyecto.idProyecto == idProyecto);
    expect(resumen.tipo?.nombre, 'Finca raíz');
    expect(resumen.saldo, 1200000);
    expect(resumen.cantidadPortafolios, 2);
  });
}
