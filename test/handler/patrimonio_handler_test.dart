import 'package:flutter_test/flutter_test.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/deuda_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/patrimonio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/proyecto_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/cuentas/dto/deuda_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';

import '../helpers/base_datos_prueba.dart';

void main() {
  final base = BaseDatosPrueba();

  setUp(base.abrir);
  tearDown(base.cerrar);

  test('patrimonio: cuentas + invertido − deudas, evolución y rentabilidad',
      () async {
    final ahorros = await CuentaHandler().guardarCuenta(
        CuentaDto(
            nombre: 'Ahorros',
            tipoCuenta: TipoCuenta.ahorros,
            exentaImpuesto: 'S'),
        saldoInicial: 1000000);
    final visa = await DeudaHandler().guardarTarjeta(
        CuentaDto(nombre: 'Visa', tipoCuenta: TipoCuenta.tarjetaCredito),
        CondicionesCreditoDto(
            cupo: 5000000, tasaMensual: 2000, diaCorte: 15, diaPago: 5));
    await DeudaHandler().registrarCompra(visa, 200000);

    final idProyecto = await ProyectoHandler().createProyecto(ProyectoDto(
        nombre: 'CDTs',
        descripcion: '',
        usuarioId: 1,
        tipoProyectoId: 1));
    final cdt = await PortafolioHandler().createPortafolio(PortafolioDto(
        nombre: 'CDT 90',
        proyectoId: idProyecto,
        exentaImpuesto: 'S',
        cuentaAportesId: ahorros));
    final transacciones = TransaccionHandler();
    await transacciones.registrarAporte(cdt, 300000);
    // Rendimiento reinvertido: es ganancia y se queda en el CDT.
    await transacciones.registrarRendimiento(cdt, 30000, reinvertir: true);

    final p = await PatrimonioHandler().obtenerPatrimonio(meses: 3);
    expect(p.enCuentas, 700000);
    expect(p.invertido, 330000);
    expect(p.deudas, 200000);
    expect(p.neto, 830000);
    expect(p.evolucion, hasLength(3));
    expect(p.evolucion.last.patrimonio, p.neto);

    final proyecto =
        p.porProyecto.singleWhere((r) => r.id == idProyecto);
    expect(proyecto.aportado, 300000);
    expect(proyecto.ganancia, 30000);
    expect(proyecto.saldo, 330000);
    expect(proyecto.porcentaje, closeTo(10, 0.001));
    expect(p.porTipo.single.id, 1);
    expect(p.porTipo.single.ganancia, 30000);
  });

  test('un retiro a la cuenta no es ganancia ni pérdida', () async {
    final ahorros = await CuentaHandler().guardarCuenta(
        CuentaDto(
            nombre: 'Ahorros',
            tipoCuenta: TipoCuenta.ahorros,
            exentaImpuesto: 'S'),
        saldoInicial: 500000);
    final idProyecto = await ProyectoHandler().createProyecto(
        ProyectoDto(nombre: 'Fondo', descripcion: '', usuarioId: 1));
    final fondo = await PortafolioHandler().createPortafolio(PortafolioDto(
        nombre: 'Fondo',
        proyectoId: idProyecto,
        exentaImpuesto: 'S',
        cuentaAportesId: ahorros));
    final transacciones = TransaccionHandler();
    await transacciones.registrarAporte(fondo, 400000);
    // Rendimiento que llega a la cuenta de aportes.
    await transacciones.registrarRendimiento(fondo, 20000);

    final p = await PatrimonioHandler().obtenerPatrimonio(meses: 1);
    final r = p.porProyecto.single;
    expect(r.aportado, 400000);
    expect(r.retirado, 20000);
    expect(r.ganancia, 20000);
    expect(r.saldo, 400000);
    expect(p.porTipo.single.id, isNull); // proyecto sin tipo
    expect(p.neto, 520000);
  });
}
