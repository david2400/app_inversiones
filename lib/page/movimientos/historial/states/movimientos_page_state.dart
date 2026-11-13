import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inversiones/domain/models/filtro_movimientos.dart';
import 'package:inversiones/infraestructure/handler/implementations/motivo_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/tercero_impl.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/motivo_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/portafolio_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tercero_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:inversiones/page/movimientos/historial/page/movimientos_page.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/resultado_movimientos_dto.dart';
import 'package:inversiones/page/terceros/dto/tercero_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_model.dart';

/// Periodos rápidos del historial.
enum PeriodoMovimientos { mesActual, mesAnterior, anioActual, todo }

class MovimientosPageState extends FlutterFlowModel<MovimientosPage> {
  final ITransaccion _transaccionHandler = TransaccionHandler();
  final IPortafolio _portafolioHandler = PortafolioHandler();
  final ITercero _terceroHandler = TerceroHandler();
  final IMotivo _motivoHandler = MotivoHandler();

  static final _formatoDia = DateFormat('yyyy-MM-dd');

  // Catálogos para los filtros
  List<PortafolioDto> portafolios = [];
  List<TerceroDto> terceros = [];
  List<MotivosDto> motivos = [];

  // Filtros
  PeriodoMovimientos periodo = PeriodoMovimientos.mesActual;
  String? tipoFuente;
  int? idPortafolio;
  int? idTercero;
  int? idMotivo;
  final busquedaController = TextEditingController();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() => busquedaController.dispose();

  int get filtrosAvanzadosActivos =>
      [idPortafolio, idTercero, idMotivo].where((f) => f != null).length;

  Future<void> cargarCatalogos() async {
    try {
      portafolios = await _portafolioHandler.listarPortafolios();
      terceros = await _terceroHandler.listarTerceros();
      motivos = await _motivoHandler.listarMotivos();
    } catch (e) {
      rethrow;
    }
  }

  Future<ResultadoMovimientosDto> buscar() async {
    try {
      final (desde, hasta) = _rango(DateTime.now());
      return await _transaccionHandler.buscarMovimientos(FiltroMovimientos(
        desde: desde,
        hasta: hasta,
        tipoFuente: tipoFuente,
        idPortafolio: idPortafolio,
        idTercero: idTercero,
        idMotivo: idMotivo,
        texto: busquedaController.text,
      ));
    } catch (e) {
      rethrow;
    }
  }

  (String?, String?) _rango(DateTime hoy) {
    String dia(DateTime d) => _formatoDia.format(d);
    switch (periodo) {
      case PeriodoMovimientos.mesActual:
        return (dia(DateTime(hoy.year, hoy.month, 1)),
            dia(DateTime(hoy.year, hoy.month + 1, 1)));
      case PeriodoMovimientos.mesAnterior:
        return (dia(DateTime(hoy.year, hoy.month - 1, 1)),
            dia(DateTime(hoy.year, hoy.month, 1)));
      case PeriodoMovimientos.anioActual:
        return (dia(DateTime(hoy.year, 1, 1)), dia(DateTime(hoy.year + 1, 1, 1)));
      case PeriodoMovimientos.todo:
        return (null, null);
    }
  }
}
