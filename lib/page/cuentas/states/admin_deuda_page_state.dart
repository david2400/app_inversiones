import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/calculadora_credito.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/deuda_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/deuda_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/cuentas/dto/deuda_dto.dart';
import 'package:inversiones/page/cuentas/page/campo_numero.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

/// Estado de los formularios de tarjeta de crédito y préstamo.
class AdminDeudaPageState extends FlutterFlowModel<StatefulWidget> {
  final IDeuda _deudaHandler = DeudaHandler();
  final ICuenta _cuentaHandler = CuentaHandler();

  final nombreController = TextEditingController();
  final entidadController = TextEditingController();
  final nroController = TextEditingController();
  final montoController = TextEditingController();
  final tasaController = TextEditingController();
  final cuotaManejoController = TextEditingController();
  final diaCorteController = TextEditingController();
  final diaPagoController = TextEditingController();
  final plazoController = TextEditingController();

  /// Préstamo: cuenta donde llega el desembolso.
  int? idCuentaDesembolso;

  /// Tarjeta que se edita (nula al crear).
  CuentaDto? cuenta;
  CondicionesCreditoDto? condiciones;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    for (final c in [
      nombreController,
      entidadController,
      nroController,
      montoController,
      tasaController,
      cuotaManejoController,
      diaCorteController,
      diaPagoController,
      plazoController,
    ]) {
      c.dispose();
    }
  }

  /// Cuentas de activo (para el desembolso).
  Future<List<CuentaDto>> cuentasDeActivo() async {
    try {
      final cuentas = await _cuentaHandler.listarCuentas();
      return cuentas.where((c) => !TipoCuenta.esPasivo(c.tipoCuenta)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Carga una tarjeta para editarla.
  Future<void> cargarTarjeta(int idCuenta) async {
    try {
      final dto = await _cuentaHandler.obtenerCuenta(idCuenta);
      final cond = await _deudaHandler.obtenerCondiciones(idCuenta);
      cuenta = dto;
      condiciones = cond;
      nombreController.text = dto.nombre;
      entidadController.text = dto.entidad ?? '';
      nroController.text = dto.nroCuenta ?? '';
      if (cond != null) {
        montoController.text = '${cond.cupo ?? ''}';
        tasaController.text = _textoTasa(cond.tasaMensual);
        cuotaManejoController.text =
            cond.cuotaManejo == null ? '' : '${cond.cuotaManejo}';
        diaCorteController.text = cond.diaCorte == null ? '' : '${cond.diaCorte}';
        diaPagoController.text = cond.diaPago == null ? '' : '${cond.diaPago}';
      }
    } catch (e) {
      rethrow;
    }
  }

  static String _textoTasa(int tasa) =>
      CalculadoraCredito.porcentaje(tasa).toString().replaceAll('.', ',');

  int get _tasa => CalculadoraCredito.tasaDesdePorcentaje(
      CampoNumero.numero(tasaController.text) ?? 0);

  CuentaDto _cuenta(String tipo) => CuentaDto(
        idCuenta: cuenta?.idCuenta,
        nombre: nombreController.text,
        tipoCuenta: tipo,
        entidad: entidadController.text,
        nroCuenta: nroController.text,
        exentaImpuesto: 'S',
        createdAt: cuenta?.createdAt,
      );

  bool get hayCambios =>
      cuenta == null &&
      (nombreController.text.trim().isNotEmpty ||
          montoController.text.trim().isNotEmpty);

  Future<int> guardarTarjeta() async {
    try {
      return await _deudaHandler.guardarTarjeta(
        _cuenta(TipoCuenta.tarjetaCredito),
        CondicionesCreditoDto(
          cupo: CampoNumero.entero(montoController.text),
          tasaMensual: _tasa,
          cuotaManejo: CampoNumero.entero(cuotaManejoController.text),
          diaCorte: CampoNumero.entero(diaCorteController.text),
          diaPago: CampoNumero.entero(diaPagoController.text),
          recurrenteManejoId: condiciones?.recurrenteManejoId,
          createdAt: condiciones?.createdAt,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Cuota fija estimada con lo escrito en el formulario de préstamo.
  int get cuotaEstimada => CalculadoraCredito.cuotaFija(
      CampoNumero.entero(montoController.text) ?? 0,
      _tasa,
      CampoNumero.entero(plazoController.text) ?? 0);

  Future<int> crearPrestamo() async {
    try {
      if (idCuentaDesembolso == null) {
        throw Exception('Elige la cuenta donde llegó el dinero');
      }
      return await _deudaHandler.crearPrestamo(
        _cuenta(TipoCuenta.prestamo),
        CondicionesCreditoDto(
          cupo: CampoNumero.entero(montoController.text),
          tasaMensual: _tasa,
          plazoMeses: CampoNumero.entero(plazoController.text),
          diaPago: CampoNumero.entero(diaPagoController.text),
        ),
        idCuentaDesembolso: idCuentaDesembolso!,
      );
    } catch (e) {
      rethrow;
    }
  }
}
