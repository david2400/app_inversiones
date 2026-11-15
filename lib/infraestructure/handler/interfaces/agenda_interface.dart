import 'package:inversiones/page/agenda/dto/agenda_dto.dart';

/// Agenda de compromisos e ingresos esperados y flujo de caja proyectado
/// del dinero disponible.
abstract class IAgenda {
  /// Eventos desde [hoy] (hoy por defecto) hasta [meses] meses después:
  /// fijos y aportes programados, pagos de tarjetas y cuotas de préstamos,
  /// vencimientos de CDT y fechas de metas, con el saldo proyectado.
  Future<AgendaDto> proyectar({DateTime? hoy, int meses = 3});

  /// Registra el fijo del mes de [fecha] (atajo desde la agenda).
  Future<int> registrarFijo(int idRecurrente, {DateTime? fecha});
}
