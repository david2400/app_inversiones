import 'package:inversiones/domain/entity/tipo_proyecto_entity.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/domain/schema/proyecto_schema.dart';
import 'package:inversiones/domain/schema/tipo_proyecto_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/patrimonio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/saldo_portafolio_dto.dart';
import 'package:inversiones/page/home/dto/patrimonio_dto.dart';

class PatrimonioHandler implements IPatrimonio {
  final IPortafolio _portafolios;
  final TransferenciaShema _transferencias;

  PatrimonioHandler(
      {IPortafolio? portafolios, TransferenciaShema? transferencias})
      : _portafolios = portafolios ?? PortafolioHandler(),
        _transferencias = transferencias ?? TransferenciaShema();

  @override
  Future<PatrimonioDto> obtenerPatrimonio(
      {DateTime? fecha, int meses = 12}) async {
    try {
      final hoy = fecha ?? DateTime.now();
      final saldos = await _portafolios.listarSaldos();
      final cuentas = {
        for (final c in await CuentaSchema().getAll()) c.idCuenta: c,
      };

      // 1. Cuentas y deudas: el saldo de una cuenta es la suma de sus
      // portafolios; en tarjetas y préstamos, el negativo es deuda.
      final saldoPorCuenta = <int, int>{};
      var invertido = 0;
      for (final s in saldos) {
        if (s.cuentaId != null) {
          saldoPorCuenta[s.cuentaId!] =
              (saldoPorCuenta[s.cuentaId!] ?? 0) + s.saldo;
        } else if (s.proyectoId != null) {
          invertido += s.saldo;
        }
      }
      var enCuentas = 0;
      var deudas = 0;
      saldoPorCuenta.forEach((idCuenta, saldo) {
        final cuenta = cuentas[idCuenta];
        final esPasivo =
            cuenta != null && TipoCuenta.esPasivo(cuenta.tipoCuenta);
        if (esPasivo && saldo < 0) {
          deudas += -saldo;
        } else {
          enCuentas += saldo;
        }
      });

      // 2. Evolución: patrimonio acumulado al cierre de cada mes.
      final variaciones =
          await _transferencias.obtenerVariacionPatrimonioMensual();
      final evolucion = <PuntoPatrimonioDto>[];
      final primerMes = DateTime(hoy.year, hoy.month - (meses - 1));
      final periodoInicial = _periodo(primerMes);
      var acumulado = variaciones
          .where((v) => v.periodo.compareTo(periodoInicial) < 0)
          .fold<int>(0, (s, v) => s + v.neto);
      final porPeriodo = {for (final v in variaciones) v.periodo: v.neto};
      for (var i = 0; i < meses; i++) {
        final periodo =
            _periodo(DateTime(primerMes.year, primerMes.month + i));
        acumulado += porPeriodo[periodo] ?? 0;
        evolucion.add(
            PuntoPatrimonioDto(periodo: periodo, patrimonio: acumulado));
      }

      // 3. Rentabilidad por proyecto y por tipo.
      final tipos = {
        for (final t in await TipoProyectoSchema().getAll())
          t.idTipoProyecto: t,
      };
      final proyectos = await _rentabilidadPorProyecto(saldos, tipos);
      final porTipo = _agruparPorTipo(proyectos, tipos);
      final porProyecto = [for (final p in proyectos) p.$1];

      return PatrimonioDto(
        enCuentas: enCuentas,
        invertido: invertido,
        deudas: deudas,
        evolucion: evolucion,
        porTipo: porTipo,
        porProyecto: porProyecto,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Rentabilidad de cada proyecto (mayor saldo primero) con el id de su
  /// tipo (nulo si no tiene o si el tipo ya no existe).
  Future<List<(RentabilidadDto, int?)>> _rentabilidadPorProyecto(
      List<SaldoPortafolioDto> saldos, Map<int?, TipoProyecto> tipos) async {
    final flujos = await _transferencias.obtenerFlujosInversion(
        descripcionSaldoInicial: PortafolioHandler.descripcionSaldoInicial);
    final lista = <(RentabilidadDto, int?)>[];
    for (final proyecto in await ProyectoSchema().getAll()) {
      final id = proyecto.idProyecto!;
      final propios = flujos.where((f) => f.proyectoId == id).toList();
      final idTipo = tipos.containsKey(proyecto.tipoProyectoId)
          ? proyecto.tipoProyectoId
          : null;
      lista.add((
        RentabilidadDto(
          id: id,
          nombre: proyecto.nombre,
          riesgo: tipos[idTipo]?.riesgo,
          saldo: saldos
              .where((s) => s.proyectoId == id)
              .fold(0, (t, s) => t + s.saldo),
          aportado: propios.fold(0, (t, f) => t + f.aportes),
          retirado: propios.fold(0, (t, f) => t + f.retiros),
          ganancia: propios.fold(0, (t, f) => t + f.rendimientos - f.gastos),
          cantidad: propios.length,
        ),
        idTipo,
      ));
    }
    lista.sort((a, b) => b.$1.saldo.compareTo(a.$1.saldo));
    return lista;
  }

  /// Suma la rentabilidad de los proyectos de cada tipo (mayor saldo
  /// primero; los proyectos sin tipo van juntos con id nulo).
  List<RentabilidadDto> _agruparPorTipo(List<(RentabilidadDto, int?)> proyectos,
      Map<int?, TipoProyecto> tipos) {
    final grupos = <int?, List<RentabilidadDto>>{};
    for (final (proyecto, idTipo) in proyectos) {
      grupos.putIfAbsent(idTipo, () => []).add(proyecto);
    }
    return [
      for (final MapEntry(key: idTipo, value: grupo) in grupos.entries)
        RentabilidadDto(
          id: idTipo,
          nombre: tipos[idTipo]?.nombre,
          riesgo: tipos[idTipo]?.riesgo,
          saldo: grupo.fold(0, (t, p) => t + p.saldo),
          aportado: grupo.fold(0, (t, p) => t + p.aportado),
          retirado: grupo.fold(0, (t, p) => t + p.retirado),
          ganancia: grupo.fold(0, (t, p) => t + p.ganancia),
          cantidad: grupo.length,
        ),
    ]..sort((a, b) => b.saldo.compareTo(a.saldo));
  }

  static String _periodo(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';
}
