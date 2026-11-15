import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/agenda_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/agenda_interface.dart';
import 'package:inversiones/page/agenda/dto/agenda_dto.dart';
import 'package:inversiones/page/agenda/page/agenda_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

/// Orquesta la agenda y el flujo de caja proyectado.
class AgendaPageState extends FlutterFlowModel<AgendaPage> {
  final IAgenda _agendaHandler = AgendaHandler();

  /// Meses hacia adelante que se proyectan.
  static const horizonteMeses = 3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<AgendaDto> cargar() async {
    try {
      return await _agendaHandler.proyectar(meses: horizonteMeses);
    } catch (e) {
      rethrow;
    }
  }

  /// Registra el fijo en el mes de su fecha.
  Future<void> registrarFijo(EventoAgendaDto evento) async {
    try {
      await _agendaHandler.registrarFijo(evento.idRecurrente!,
          fecha: evento.fecha);
    } catch (e) {
      rethrow;
    }
  }
}
