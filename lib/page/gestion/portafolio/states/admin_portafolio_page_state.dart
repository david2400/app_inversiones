import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/cuenta_impl.dart';
import 'package:inversiones/domain/models/calculadora_rendimiento.dart';
import 'package:inversiones/domain/models/periodicidad.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/recurrente_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/recurrente_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/cuenta_interface.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/aporte_programado_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/gestion/portafolio/page/admin_portafolio_page.dart';
import 'package:inversiones/ui/utils/form_field_controller.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

class AdminPortafolioPageState extends FlutterFlowModel<AdminPortafolioPage> {
  FocusNode? nombreFocus;
  TextEditingController? nombreController;

  // String? Function(BuildContext, String?)? nombreValidator;

  FocusNode? nroCuentaFocus;
  TextEditingController? nroCuentaController;

  // String? Function(BuildContext, String?)? descripcionValidator;

  FocusNode? descripcionFocus;
  TextEditingController? descripcionController;

  // String? Function(BuildContext, String?)? descripcionValidator;

  String? tipoTransferenciaId;
  FormFieldController<String>? tipoTransferenciaController;

  String? tipoRenta;
  FormFieldController<String>? tipoRentaController;

  int? tipoPortafolioId;
  FormFieldController<int>? tipoPortafolioController;

  FocusNode? interesFocus;
  TextEditingController? interesController;

  // String? Function(BuildContext, String?)? interesValidator;

  /// Cada cuánto paga rendimientos (ver `Periodicidad`; nulo = sin
  /// definir).
  int? periodicidadRendimientos;

  /// Saldo del portafolio que se edita (base de la proyección).
  int saldoActual = 0;

  /// Plazo de un CDT o inversión a término (opcional).
  DateTime? fechaApertura;
  DateTime? fechaVencimiento;

  static final _formatoFecha = DateFormat('yyyy-MM-dd');

  static String? _fecha(DateTime? fecha) =>
      fecha == null ? null : _formatoFecha.format(fecha);

  /// Rendimiento estimado al vencimiento sobre [capital] con la tasa del
  /// formulario, desde hoy (o la apertura, si es futura). Nulo si faltan
  /// datos.
  int? rendimientoEstimado(int capital) {
    final vence = fechaVencimiento;
    final tasa = int.tryParse(interesController.text.trim()) ?? 0;
    if (vence == null || tasa <= 0 || capital <= 0) return null;
    final hoy = DateTime.now();
    final desde = (fechaApertura != null && fechaApertura!.isAfter(hoy))
        ? fechaApertura!
        : hoy;
    return CalculadoraRendimiento.rendimiento(
        capital: capital,
        tasaEa: tasa,
        dias: CalculadoraRendimiento.diasEntre(desde, vence));
  }

  // Aporte programado ------------------------------------------------------

  /// Si el portafolio recibe aportes que se repiten.
  bool programarAporte = false;

  /// Si tenía un aporte programado al abrir (para saber si se quitó).
  bool _teniaAporte = false;

  final aporteValorController = TextEditingController();
  final aporteDiaController = TextEditingController();
  int aportePeriodo = Periodicidad.mensual;

  /// `true`: la app lo registra sola; `false`: queda pendiente en Fijos.
  bool aporteAutomatico = false;
  bool aporteActivo = true;

  bool? exentaImpuesto = false;

  /// Cuenta de donde salen los aportes (nula = Efectivo / Sin definir).
  int? cuentaAportesId;

  /// Si los rendimientos llegan a la misma cuenta de aportes.
  bool mismaCuentaRendimientos = true;

  /// Cuenta de rendimientos cuando no es la misma de aportes.
  int? cuentaRendimientosId;

  /// Dinero que ya hay en la cuenta al crearla (opcional).
  final saldoInicialController = TextEditingController();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nombreFocus?.dispose();
    nombreController?.dispose();

    descripcionFocus?.dispose();
    descripcionController?.dispose();

    interesFocus?.dispose();
    interesController?.dispose();
    saldoInicialController.dispose();
    aporteValorController.dispose();
    aporteDiaController.dispose();
  }

  static const _diaMinimo = 1;
  static const _diaMaximo = 31;

  /// Valida los datos del aporte programado; retorna el mensaje de error o
  /// `null` si son válidos (o si no se programa).
  String? validarAporte() {
    if (!programarAporte) return null;
    final valor = int.tryParse(aporteValorController.text.trim()) ?? 0;
    if (valor <= 0) return 'El valor del aporte debe ser mayor a cero';
    final dia = int.tryParse(aporteDiaController.text.trim()) ?? 0;
    if (dia < _diaMinimo || dia > _diaMaximo) {
      return 'El día del aporte debe estar entre $_diaMinimo y $_diaMaximo';
    }
    return null;
  }

  AporteProgramadoDto? _aporte() {
    if (!programarAporte) return null;
    final error = validarAporte();
    if (error != null) throw Exception(error);
    return AporteProgramadoDto(
      valor: int.parse(aporteValorController.text.trim()),
      periodoMeses: aportePeriodo,
      diaMes: int.parse(aporteDiaController.text.trim()),
      automatico: aporteAutomatico,
      activo: aporteActivo,
    );
  }

  PortafolioDto _initDataPortafolio() {
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    return PortafolioDto(
        nombre: nombreController.text,
        nroCuenta: nroCuentaController.text,
        tipoRenta: tipoRenta,
        proyectoId: widget.idProyecto,
        tipoPortafolioId: tipoPortafolioId,
        interes: int.tryParse(interesController.text),
        exentaImpuesto: exentaImpuesto! ? 'S' : 'N',
        periodicidadRendimientos: periodicidadRendimientos,
        fechaApertura: _fecha(fechaApertura),
        fechaVencimiento: _fecha(fechaVencimiento),
        descripcion: descripcionController.text,
        cuentaAportesId: cuentaAportesId,
        cuentaDestinoId:
            mismaCuentaRendimientos ? null : cuentaRendimientosId,
        createdAt: formattedDateTime);
  }

  /// Cuentas para elegir de dónde salen los aportes y a dónde llegan los
  /// rendimientos.
  Future<List<CuentaDto>> listarCuentas() async {
    try {
      final ICuenta cuentaHandler = CuentaHandler();
      return await cuentaHandler.listarCuentas();
    } catch (e) {
      rethrow;
    }
  }

  /// Portafolio que se está editando (`null` al crear).
  PortafolioDto? portafolioEditado;

  bool get editando => portafolioEditado != null;

  /// Si el portafolio es una cajita de una cuenta: hereda su 4x1000.
  bool get esDeCuenta => portafolioEditado?.cuentaId != null;

  /// Carga el portafolio [id] en los campos del formulario.
  Future<void> cargarPortafolio(int id) async {
    final IPortafolio portafolioHandler = PortafolioHandler();
    final p = await portafolioHandler.obtenerPortafolioById(id);
    if (p.esPrincipal) {
      throw Exception('El portafolio principal se edita desde la cuenta');
    }
    portafolioEditado = p;
    nombreController?.text = p.nombre;
    nroCuentaController?.text = p.nroCuenta ?? '';
    descripcionController?.text = p.descripcion ?? '';
    interesController?.text = p.interes?.toString() ?? '';
    tipoRenta = p.tipoRenta ?? '';
    tipoPortafolioId = p.tipoPortafolioId ?? 0;
    periodicidadRendimientos = p.periodicidadRendimientos;
    saldoActual = await portafolioHandler.obtenerSaldo(id);
    fechaApertura = DateTime.tryParse(p.fechaApertura ?? '');
    fechaVencimiento = DateTime.tryParse(p.fechaVencimiento ?? '');
    exentaImpuesto = p.exentaImpuesto == 'S';
    cuentaAportesId = p.cuentaAportesId;
    mismaCuentaRendimientos = p.cuentaDestinoId == null;
    cuentaRendimientosId = p.cuentaDestinoId;

    final IRecurrente recurrenteHandler = RecurrenteHandler();
    final aporte = await recurrenteHandler.obtenerAporteProgramado(id);
    _teniaAporte = aporte != null;
    programarAporte = aporte != null;
    if (aporte != null) {
      aporteValorController.text = '${aporte.valor}';
      aporteDiaController.text = '${aporte.diaMes}';
      aportePeriodo = aporte.periodoMeses;
      aporteAutomatico = aporte.automatico;
      aporteActivo = aporte.activo;
    }
  }

  /// Crea el portafolio o guarda los cambios si se está editando.
  Future<int> guardarPortafolio() async {
    final editado = portafolioEditado;
    if (editado == null) return insertPortafolio();
    final IPortafolio portafolioHandler = PortafolioHandler();
    return portafolioHandler.actualizarPortafolio(PortafolioDto(
      idPortafolio: editado.idPortafolio,
      nombre: nombreController.text,
      nroCuenta: nroCuentaController.text,
      tipoRenta: tipoRenta,
      proyectoId: editado.proyectoId,
      cuentaId: editado.cuentaId,
      tipoPortafolioId: tipoPortafolioId,
      interes: int.tryParse(interesController.text),
      exentaImpuesto: (exentaImpuesto ?? false) ? 'S' : 'N',
      periodicidadRendimientos: periodicidadRendimientos,
      fechaApertura: _fecha(fechaApertura),
      fechaVencimiento: _fecha(fechaVencimiento),
      descripcion: descripcionController.text,
      cuentaAportesId: cuentaAportesId,
      cuentaDestinoId: mismaCuentaRendimientos ? null : cuentaRendimientosId,
    ),
        aporteProgramado: _aporte(),
        quitarAporte: _teniaAporte && !programarAporte);
  }

  Future<int> insertPortafolio() async {
    try {
      PortafolioDto portafolioDto = _initDataPortafolio();

      IPortafolio portafolioHandler = PortafolioHandler();
      int result = await portafolioHandler.createPortafolio(portafolioDto,
          saldoInicial: int.tryParse(saldoInicialController.text) ?? 0,
          aporteProgramado: _aporte());

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
