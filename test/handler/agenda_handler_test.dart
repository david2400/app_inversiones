import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/entity/recurrente_entity.dart';
import 'package:inversiones/domain/models/proyector_flujo.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/recurrente_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/agenda_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/recurrente_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/agenda_interface.dart';
import 'package:inversiones/page/agenda/dto/agenda_dto.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/aporte_programado_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();
  late IAgenda agenda;
  final hoy = DateTime(2026, 11, 14);

  Future<int> cuenta(String nombre, int saldo) async {
    final id = await CuentaHandler().guardarCuenta(
        CuentaDto(
            nombre: nombre,
            tipoCuenta: TipoCuenta.ahorros,
            exentaImpuesto: 'S'),
        saldoInicial: saldo);
    return (await PortafolioSchema().getPrincipalDeCuenta(id))!.idPortafolio!;
  }

  Future<void> fijo(String nombre, String fuente, int valor, int dia,
      {required int origen, int? destino}) async {
    final tipo = await TipoTransaccionSchema().getPrimeroPorFuente(fuente);
    await RecurrenteSchema().insert(Recurrente(
      nombre: nombre,
      tipoTransferenciaId: tipo!.idTipoTransaccion!,
      portafolioId: origen,
      destinoCuenta: destino,
      valor: valor,
      diaMes: dia,
    ));
  }

  List<EventoAgendaDto> eventos(AgendaDto a, String titulo) => [
        for (final d in a.dias)
          for (final e in d.eventos)
            if (e.titulo == titulo) e
      ];

  setUp(() async {
    await base.abrir();
    agenda = AgendaHandler();
  });

  tearDown(base.cerrar);

  test('proyector: orden, cierre de mes, mínimo y primer negativo', () {
    EventoAgendaDto e(DateTime f, int efecto, String t) => EventoAgendaDto(
        fecha: f,
        titulo: t,
        tipo: efecto > 0 ? TipoEventoAgenda.ingreso : TipoEventoAgenda.gasto,
        valor: efecto.abs(),
        efecto: efecto);
    final a = ProyectorFlujo.proyectar(
      saldoInicial: 100,
      desde: hoy,
      hasta: DateTime(2027, 2, 14),
      eventos: [
        e(DateTime(2026, 11, 1), -50, 'Atrasado'), // se muestra hoy
        e(DateTime(2026, 11, 20), -200, 'Arriendo'),
        e(DateTime(2026, 11, 20), 300, 'Salario'),
        e(DateTime(2026, 12, 5), -400, 'Viaje'),
        e(DateTime(2027, 3, 1), 999, 'Fuera'),
      ],
    );
    expect(a.dias.map((d) => d.fecha),
        [hoy, DateTime(2026, 11, 20), DateTime(2026, 12, 5)]);
    expect(a.dias[1].eventos.first.titulo, 'Salario'); // primero lo que entra
    expect(a.dias.map((d) => d.saldo), [50, 150, -250]);
    expect(a.saldoFinDeMes, 150);
    expect(a.saldoFinal, -250);
    expect(a.entradas, 300);
    expect(a.salidas, 650);
    expect(a.saldoMinimo, -250);
    expect(a.primerNegativo, DateTime(2026, 12, 5));
  });

  test('fijos de 3 meses: ingresos, gastos, atrasados y aportes', () async {
    final ahorros = await cuenta('Ahorros', 2000000);
    final otra = await cuenta('Bolsillo', 0);
    await fijo('Salario', TipoFuente.ingreso, 3000000, 30, origen: ahorros);
    await fijo('Arriendo', TipoFuente.egreso, 1500000, 5, origen: ahorros);
    await fijo('Traslado', TipoFuente.transferencia, 200000, 20,
        origen: ahorros, destino: otra);
    final ahorrosCuenta = (await PortafolioSchema().getById(ahorros))!.cuentaId;
    final cdt = await PortafolioHandler().createPortafolio(PortafolioDto(
        nombre: 'CDT',
        proyectoId: 1,
        exentaImpuesto: 'S',
        cuentaAportesId: ahorrosCuenta));
    await RecurrenteHandler().guardarAporteProgramado(
        cdt,
        AporteProgramadoDto(valor: 100000, periodoMeses: 1, diaMes: 10),
        hoy: hoy);

    final a = await agenda.proyectar(hoy: hoy);
    expect(a.saldoInicial, 2000000);

    expect(eventos(a, 'Salario').map((e) => e.fecha), [
      DateTime(2026, 11, 30),
      DateTime(2026, 12, 30),
      DateTime(2027, 1, 30),
    ]);
    final arriendo = eventos(a, 'Arriendo');
    expect(arriendo, hasLength(4)); // nov (atrasado), dic, ene, feb
    expect(arriendo.first.atrasado, isTrue);
    expect(arriendo.first.efecto, -1500000);

    // Entre cuentas propias exentas el disponible no cambia.
    expect(eventos(a, 'Traslado').every((e) => e.efecto == 0), isTrue);

    // El aporte al CDT sí sale del disponible.
    final aportes = eventos(a, 'Aporte a CDT');
    expect(aportes, isNotEmpty);
    expect(aportes.every((e) => e.efecto == -100000), isTrue);
    expect(a.saldoFinal,
        2000000 + 3 * 3000000 - 4 * 1500000 - aportes.length * 100000);

    // Registrar el atrasado lo quita de la agenda.
    await agenda.registrarFijo(arriendo.first.idRecurrente!,
        fecha: DateTime(2026, 11, 5));
    expect(eventos(await agenda.proyectar(hoy: hoy), 'Arriendo'),
        hasLength(3));
  });

  test('alerta de saldo negativo y vencimiento de CDT', () async {
    final ahorros = await cuenta('Ahorros', 300000);
    await fijo('Servicios', TipoFuente.egreso, 500000, 20, origen: ahorros);
    final cdt = await PortafolioHandler().createPortafolio(PortafolioDto(
        nombre: 'CDT dic',
        proyectoId: 1,
        interes: 12,
        exentaImpuesto: 'S',
        fechaApertura: '2026-06-01',
        fechaVencimiento: '2026-12-01'));
    await TransaccionHandler().registrarAporte(cdt, 1000000); // desde Efectivo

    final a = await agenda.proyectar(hoy: hoy);
    // Efectivo quedó en −1.000.000 por el aporte: el disponible arranca así.
    expect(a.saldoInicial, 300000 - 1000000);
    expect(a.primerNegativo, hoy);

    final vence = eventos(a, 'CDT dic').single;
    expect(vence.tipo, TipoEventoAgenda.vencimiento);
    expect(vence.fecha, DateTime(2026, 12, 1));
    expect(vence.efecto, greaterThan(1000000));
    expect(vence.estimado, isTrue);
  });
}
