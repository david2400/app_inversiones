import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/infraestructure/handler/implementations/motivo_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/recurrente_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/tercero_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/tipo_transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/motivo_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/recurrente_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tercero_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_transaccion_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/page/admin_transaccion_page.dart';
import 'package:inversiones/page/terceros/dto/tercero_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

/// Estado del formulario de movimientos. Orquesta catálogos, la vista
/// previa (GMF y saldo) y el guardado; la lógica de negocio vive en los
/// handlers.
class AdminTransaccionPageState extends FlutterFlowModel<AdminTransaccionPage> {
  final ITransaccion _transaccionHandler = TransaccionHandler();
  final IPortafolio _portafolioHandler = PortafolioHandler();
  final ITipoTransaccion _tipoHandler = TipoTransaccionHandler();
  final IMotivo _motivoHandler = MotivoHandler();
  final ITercero _terceroHandler = TerceroHandler();
  final IRecurrente _recurrenteHandler = RecurrenteHandler();

  // Catálogos
  List<TipoTransaccionDto> tipos = [];
  List<PortafolioDto> portafolios = [];
  List<MotivosDto> motivos = [];
  List<TerceroDto> terceros = [];

  // Selección
  int? tipoId;
  int? portafolioId;
  int? destinoId;
  bool destinoExterno = false;
  int? motivoId;
  int? terceroId;
  DateTime fecha = DateTime.now();
  int? saldoOrigen;

  final valorController = TextEditingController();
  final cuentaExternaController = TextEditingController();
  final descripcionController = TextEditingController();

  /// Guardar además como movimiento fijo mensual (mismo día cada mes).
  bool repetirMensual = false;
  final nombreFijoController = TextEditingController();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    valorController.dispose();
    cuentaExternaController.dispose();
    descripcionController.dispose();
    nombreFijoController.dispose();
  }

  /// Nombre sugerido para el movimiento fijo: tercero, motivo o tipo.
  String get nombreFijoSugerido {
    for (final t in terceros) {
      if (t.idTercero == terceroId) return t.nombre;
    }
    for (final mo in motivos) {
      if (mo.idMotivo == motivoId) return mo.nombre;
    }
    return tipo?.nombre ?? '';
  }

  TipoTransaccionDto? get tipo {
    for (final t in tipos) {
      if (t.idTipoTransaccion == tipoId) return t;
    }
    return null;
  }

  PortafolioDto? get portafolio {
    for (final p in portafolios) {
      if (p.idPortafolio == portafolioId) return p;
    }
    return null;
  }

  String? get naturaleza => tipo?.tipoFuente;
  bool get esIngreso => naturaleza == TipoFuente.ingreso;
  bool get esTransferencia => naturaleza == TipoFuente.transferencia;
  bool get debita => naturaleza != null && TipoFuente.debitaOrigen(naturaleza!);

  /// Entre cuentas propias no hay tercero.
  bool get admiteTercero =>
      naturaleza != null && (!esTransferencia || destinoExterno);

  /// Portafolios que pueden ser destino (todos menos el origen).
  List<PortafolioDto> get destinosPosibles =>
      portafolios.where((p) => p.idPortafolio != portafolioId).toList();

  int get valor => int.tryParse(valorController.text) ?? 0;

  int get gmf => (naturaleza == null || portafolio == null)
      ? 0
      : _transaccionHandler.calcularGmf(
          valor: valor,
          tipoFuente: naturaleza!,
          exentaImpuesto: portafolio!.exentaImpuesto);

  int get totalDebitado => debita ? valor + gmf : 0;

  int? get saldoDespues {
    if (saldoOrigen == null || naturaleza == null) return null;
    return esIngreso ? saldoOrigen! + valor : saldoOrigen! - totalDebitado;
  }

  Future<void> cargarCatalogos(int? portafolioInicial) async {
    try {
      final resultados = await Future.wait([
        _tipoHandler.listarTipoTransaccion(),
        _portafolioHandler.listarPortafolios(),
        _motivoHandler.listarMotivos(),
        _terceroHandler.listarTerceros(),
      ]);
      tipos = resultados[0] as List<TipoTransaccionDto>;
      portafolios = resultados[1] as List<PortafolioDto>;
      motivos = resultados[2] as List<MotivosDto>;
      terceros = resultados[3] as List<TerceroDto>;
      if (portafolioInicial != null &&
          portafolios.any((p) => p.idPortafolio == portafolioInicial)) {
        portafolioId = portafolioInicial;
        await actualizarSaldo();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> actualizarSaldo() async {
    try {
      saldoOrigen = portafolioId == null
          ? null
          : await _portafolioHandler.obtenerSaldo(portafolioId!);
    } catch (e) {
      rethrow;
    }
  }

  /// Crea un tercero desde el formulario y lo deja seleccionado.
  Future<void> crearTercero(String nombre) async {
    try {
      final id = await _terceroHandler.guardarTercero(TerceroDto(nombre: nombre));
      terceros = await _terceroHandler.listarTerceros();
      terceroId = id;
    } catch (e) {
      rethrow;
    }
  }

  /// Retorna la clave i18n del primer error de validación, o `null`.
  String? validar() {
    if (tipo == null) return 'frm_error_tipo';
    if (valor <= 0) return 'frm_error_valor';
    if (portafolioId == null) return 'frm_error_cuenta';
    if (esTransferencia) {
      if (destinoExterno && cuentaExternaController.text.trim().isEmpty) {
        return 'frm_error_externa';
      }
      if (!destinoExterno && destinoId == null) return 'frm_error_destino';
    }
    return null;
  }

  Future<int> guardar() async {
    try {
      final ahora = DateTime.now();
      final fechaHora = DateTime(fecha.year, fecha.month, fecha.day,
          ahora.hour, ahora.minute, ahora.second);
      final descripcion = descripcionController.text.trim();

      final movimiento = TransaccionDto(
        valor: valor,
        tipoTransferenciaId: tipoId!,
        portafolioId: portafolioId!,
        destinoCuenta: esTransferencia && !destinoExterno ? destinoId : null,
        destinoAlternativo: esTransferencia && destinoExterno
            ? cuentaExternaController.text.trim()
            : null,
        motivoId: motivoId,
        terceroId: admiteTercero ? terceroId : null,
        descripcion: descripcion.isEmpty ? null : descripcion,
        createdAt: DateFormat(Auditoria.formatoFecha).format(fechaHora),
      );
      if (!repetirMensual) {
        return await _transaccionHandler.createTransaccion(movimiento);
      }
      final nombre = nombreFijoController.text.trim();
      return await _recurrenteHandler.registrarMovimientoFijo(movimiento,
          nombre: nombre.isEmpty ? nombreFijoSugerido : nombre,
          diaMes: fecha.day);
    } catch (e) {
      rethrow;
    }
  }
}
