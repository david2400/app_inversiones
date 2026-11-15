import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/periodicidad.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/recurrente_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/recurrente_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/recurrente_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/aporte_programado_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late ICuenta cuentas;
  late IPortafolio portafolios;
  late IRecurrente fijos;

  Future<int> principal(int idCuenta) async =>
      (await PortafolioSchema().getPrincipalDeCuenta(idCuenta))!.idPortafolio!;

  PortafolioDto cdt({int? aportes}) => PortafolioDto(
        nombre: 'CDT',
        proyectoId: 1,
        exentaImpuesto: 'S',
        periodicidadRendimientos: Periodicidad.alVencimiento,
        cuentaAportesId: aportes,
      );

  AporteProgramadoDto trimestral({bool automatico = true}) =>
      AporteProgramadoDto(
        valor: 100000,
        periodoMeses: Periodicidad.trimestral,
        diaMes: 10,
        automatico: automatico,
        fechaInicio: '2026-01-10',
      );

  setUp(() async {
    await base.abrir();
    cuentas = CuentaHandler();
    portafolios = PortafolioHandler();
    fijos = RecurrenteHandler();
  });

  tearDown(base.cerrar);

  test('periodicidad: meses que tocan y próximo mes', () {
    final inicio = DateTime(2026, 1, 10);
    bool toca(int mes) => Periodicidad.tocaEnMes(
        inicio: inicio, meses: Periodicidad.trimestral, mes: DateTime(2026, mes));
    expect([for (var m = 1; m <= 12; m++) if (toca(m)) m], [1, 4, 7, 10]);
    expect(
        Periodicidad.tocaEnMes(
            inicio: inicio, meses: Periodicidad.mensual, mes: DateTime(2025, 12)),
        isFalse);
    expect(
        Periodicidad.proximoMes(
            inicio: inicio,
            meses: Periodicidad.semestral,
            desde: DateTime(2026, 2, 20)),
        DateTime(2026, 7));
    expect(Periodicidad.esRepetible(Periodicidad.alVencimiento), isFalse);
    expect(Periodicidad.esDeRendimientos(Periodicidad.alVencimiento), isTrue);
  });

  test('crear un portafolio con aporte programado trimestral automático',
      () async {
    final ahorros = await cuentas.guardarCuenta(
        CuentaDto(
            nombre: 'Ahorros',
            tipoCuenta: TipoCuenta.ahorros,
            exentaImpuesto: 'S'),
        saldoInicial: 1000000);
    final id = await portafolios.createPortafolio(cdt(aportes: ahorros),
        aporteProgramado: trimestral());

    final p = (await PortafolioSchema().getById(id))!;
    expect(p.periodicidadRendimientos, Periodicidad.alVencimiento);
    final aporte = (await fijos.obtenerAporteProgramado(id))!;
    expect(aporte.periodoMeses, Periodicidad.trimestral);

    // Abril toca; mayo no (el próximo es julio).
    final abril = (await fijos.listar(fecha: DateTime(2026, 4, 2))).single;
    expect(abril.tocaEnMes, isTrue);
    expect(abril.esAporte, isTrue);
    final mayo = (await fijos.listar(fecha: DateTime(2026, 5, 2))).single;
    expect(mayo.tocaEnMes, isFalse);
    expect(mayo.pendiente, isFalse);
    expect(mayo.fechaProgramada, DateTime(2026, 7, 10));
    await expectLater(
        () => fijos.registrar(aporte.idRecurrente!, fecha: DateTime(2026, 5, 2)),
        throwsException);

    // Antes del día 10 no se registra; desde el 10 sí, una sola vez.
    expect(await fijos.registrarAutomaticos(fecha: DateTime(2026, 4, 9)),
        isEmpty);
    expect(
        await fijos.registrarAutomaticos(fecha: DateTime(2026, 4, 12)),
        hasLength(1));
    expect(await fijos.registrarAutomaticos(fecha: DateTime(2026, 4, 20)),
        isEmpty);
    expect(await portafolios.obtenerSaldo(id), 100000);
    expect(await portafolios.obtenerSaldo(await principal(ahorros)), 900000);
  });

  test('el origen sigue a la cuenta de aportes del portafolio', () async {
    final ahorros = await cuentas.guardarCuenta(
        CuentaDto(
            nombre: 'Ahorros',
            tipoCuenta: TipoCuenta.ahorros,
            exentaImpuesto: 'S'),
        saldoInicial: 500000);
    final id = await portafolios.createPortafolio(cdt(),
        aporteProgramado: trimestral(automatico: false));
    final idFijo = (await fijos.obtenerAporteProgramado(id))!.idRecurrente!;
    final efectivo = await principal(CuentaSchema.idEfectivo);
    expect((await RecurrenteSchema().getById(idFijo))!.portafolioId, efectivo);

    // Se configura la cuenta de aportes sin tocar el aporte: se sincroniza.
    await portafolios.actualizarPortafolio(
        cdt(aportes: ahorros)..idPortafolio = id);
    final fijo = (await RecurrenteSchema().getById(idFijo))!;
    expect(fijo.portafolioId, await principal(ahorros));
    expect(fijo.periodoMeses, Periodicidad.trimestral);

    // Registrar a mano saca el dinero de la cuenta de aportes vigente.
    await fijos.registrar(idFijo, fecha: DateTime(2026, 4, 10));
    expect(await portafolios.obtenerSaldo(await principal(ahorros)), 400000);

    // Quitar el aporte lo elimina de Fijos.
    await portafolios.actualizarPortafolio(
        cdt(aportes: ahorros)..idPortafolio = id,
        quitarAporte: true);
    expect(await fijos.obtenerAporteProgramado(id), isNull);
  });

  test('validaciones y limpieza del aporte programado', () async {
    final id = await portafolios.createPortafolio(cdt());
    await expectLater(
        () => fijos.guardarAporteProgramado(
            id,
            AporteProgramadoDto(
                valor: 1000, periodoMeses: 4, diaMes: 10)), // periodo inválido
        throwsException);
    await expectLater(
        () => fijos.guardarAporteProgramado(
            id, AporteProgramadoDto(valor: 0, periodoMeses: 1, diaMes: 10)),
        throwsException);

    // Sin fecha de inicio empieza en la próxima fecha con ese día.
    await fijos.guardarAporteProgramado(
        id, AporteProgramadoDto(valor: 1000, periodoMeses: 1, diaMes: 5),
        hoy: DateTime(2026, 3, 20));
    expect((await fijos.obtenerAporteProgramado(id))!.fechaInicio,
        '2026-04-05');

    // Un segundo guardado actualiza, no duplica.
    await fijos.guardarAporteProgramado(
        id, AporteProgramadoDto(valor: 2000, periodoMeses: 1, diaMes: 5));
    expect(
        (await fijos.listar(fecha: DateTime(2026, 4, 1)))
            .where((f) => f.esAporte),
        hasLength(1));

    // Eliminar el portafolio elimina su aporte programado.
    await portafolios.deletePortafolio(id);
    expect(await fijos.obtenerAporteProgramado(id), isNull);
  });
}
