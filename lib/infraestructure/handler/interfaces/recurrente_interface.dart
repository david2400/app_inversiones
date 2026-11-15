import 'package:inversiones/page/gestion/portafolio/dto/aporte_programado_dto.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/page/recurrentes/dto/recurrente_dto.dart';

/// Movimientos fijos que se repiten cada N meses (arriendo, salario,
/// servicios, aportes programados a portafolios...).
abstract class IRecurrente {
  /// Todos los fijos con su estado en el mes de [fecha] (hoy por defecto).
  Future<List<RecurrenteDto>> listar({DateTime? fecha});

  /// Fijos activos que tocan en el mes de [fecha] y aún no se registran.
  Future<List<RecurrenteDto>> pendientesDelMes({DateTime? fecha});

  /// Registra [movimiento] y lo guarda como fijo mensual en una sola
  /// transacción. Retorna el id del movimiento.
  Future<int> registrarMovimientoFijo(TransaccionDto movimiento,
      {required String nombre, required int diaMes});

  /// Crea un fijo a partir de un movimiento ya registrado ([idTransaccion])
  /// y lo vincula, para que ese mes quede como registrado.
  Future<int> crearDesdeMovimiento(TransaccionDto movimiento,
      {required int idTransaccion, required String nombre, required int diaMes});

  /// Cambiar [periodoMeses] reinicia el conteo desde la próxima fecha.
  Future<void> actualizar(int idRecurrente,
      {String? nombre,
      int? valor,
      int? diaMes,
      bool? activo,
      int? periodoMeses});

  Future<void> eliminar(int idRecurrente);

  /// Registra el movimiento del mes a partir de la plantilla. Falla si ya
  /// se registró en ese mes. Retorna el id del movimiento.
  Future<int> registrar(int idRecurrente, {DateTime? fecha, int? valor});

  /// Registra los fijos automáticos (cuota de manejo) cuyo día ya llegó en
  /// el mes de [fecha] y aún no están registrados. Retorna los ids de los
  /// movimientos creados.
  Future<List<int>> registrarAutomaticos({DateTime? fecha});

  /// Aporte programado del portafolio, o `null` si no tiene.
  Future<AporteProgramadoDto?> obtenerAporteProgramado(int idPortafolio);

  /// Crea, actualiza o (con [aporte] nulo) elimina el aporte programado del
  /// portafolio. El origen es su cuenta de aportes o "Efectivo / Sin
  /// definir". Si no se indica fecha de inicio, empieza en la próxima
  /// fecha con ese día.
  Future<void> guardarAporteProgramado(
      int idPortafolio, AporteProgramadoDto? aporte,
      {DateTime? hoy});

  /// Actualiza nombre y cuenta de origen del aporte programado cuando
  /// cambian los datos del portafolio.
  Future<void> sincronizarAporteProgramado(int idPortafolio);
}
