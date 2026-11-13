import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/infraestructure/handler/implementations/tercero_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tercero_interface.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/page/terceros/dto/tercero_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late ITercero terceros;

  setUp(() async {
    await base.abrir();
    terceros = TerceroHandler();
  });

  tearDown(base.cerrar);

  test('crea, lista ordenado y edita', () async {
    await terceros.guardarTercero(TerceroDto(nombre: '  Zeta SAS '));
    final id = await terceros.guardarTercero(TerceroDto(nombre: 'Arrendador'));

    var lista = await terceros.listarTerceros();
    expect(lista.map((t) => t.nombre), ['Arrendador', 'Zeta SAS']);

    await terceros.guardarTercero(
        TerceroDto(idTercero: id, nombre: 'Arrendador apto', descripcion: ' '));
    lista = await terceros.listarTerceros();
    expect(lista.first.nombre, 'Arrendador apto');
    expect(lista.first.descripcion, isNull);
  });

  test('rechaza nombre vacío o duplicado', () async {
    await terceros.guardarTercero(TerceroDto(nombre: 'Claro'));
    await expectLater(
        () => terceros.guardarTercero(TerceroDto(nombre: '   ')),
        throwsException);
    await expectLater(
        () => terceros.guardarTercero(TerceroDto(nombre: 'claro')),
        throwsException);
  });

  test('no elimina un tercero con movimientos; sí uno sin uso', () async {
    final ingreso = await base.crearTipo('Ingreso', TipoFuente.ingreso);
    final cuenta = await base.crearPortafolio('Ahorros', 'S');
    final empresa = await terceros.guardarTercero(TerceroDto(nombre: 'Empresa'));
    final libre = await terceros.guardarTercero(TerceroDto(nombre: 'Libre'));

    await TransaccionHandler().createTransaccion(TransaccionDto(
        valor: 1000,
        tipoTransferenciaId: ingreso,
        portafolioId: cuenta,
        terceroId: empresa));

    await expectLater(() => terceros.eliminarTercero(empresa), throwsException);
    await terceros.eliminarTercero(libre);
    expect((await terceros.listarTerceros()).map((t) => t.nombre), ['Empresa']);
  });

  test('una transferencia entre cuentas propias no guarda tercero', () async {
    final ingreso = await base.crearTipo('Ingreso', TipoFuente.ingreso);
    final transferencia =
        await base.crearTipo('Transferencia', TipoFuente.transferencia);
    final a = await base.crearPortafolio('A', 'S');
    final b = await base.crearPortafolio('B', 'S');
    final empresa = await terceros.guardarTercero(TerceroDto(nombre: 'Empresa'));

    final handler = TransaccionHandler();
    await handler.createTransaccion(TransaccionDto(
        valor: 1000, tipoTransferenciaId: ingreso, portafolioId: a));
    final id = await handler.createTransaccion(TransaccionDto(
        valor: 500,
        tipoTransferenciaId: transferencia,
        portafolioId: a,
        destinoCuenta: b,
        terceroId: empresa));

    final guardada = await handler.findTransaccion(id);
    expect(guardada.terceroId, isNull);
  });
}
