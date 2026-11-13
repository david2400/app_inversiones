import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/page/recurrentes/dto/recurrente_dto.dart';

/// Movimientos fijos mensuales (arriendo, salario, servicios...).
abstract class IRecurrente {
  /// Todos los fijos con su estado en el mes de [fecha] (hoy por defecto).
  Future<List<RecurrenteDto>> listar({DateTime? fecha});

  /// Fijos activos aún no registrados en el mes de [fecha].
  Future<List<RecurrenteDto>> pendientesDelMes({DateTime? fecha});

  /// Registra [movimiento] y lo guarda como fijo mensual en una sola
  /// transacción. Retorna el id del movimiento.
  Future<int> registrarMovimientoFijo(TransaccionDto movimiento,
      {required String nombre, required int diaMes});

  /// Crea un fijo a partir de un movimiento ya registrado ([idTransaccion])
  /// y lo vincula, para que ese mes quede como registrado.
  Future<int> crearDesdeMovimiento(TransaccionDto movimiento,
      {required int idTransaccion, required String nombre, required int diaMes});

  Future<void> actualizar(int idRecurrente,
      {String? nombre, int? valor, int? diaMes, bool? activo});

  Future<void> eliminar(int idRecurrente);

  /// Registra el movimiento del mes a partir de la plantilla. Falla si ya
  /// se registró en ese mes. Retorna el id del movimiento.
  Future<int> registrar(int idRecurrente, {DateTime? fecha, int? valor});

  /// Registra los fijos automáticos (cuota de manejo) cuyo día ya llegó en
  /// el mes de [fecha] y aún no están registrados. Retorna los ids de los
  /// movimientos creados.
  Future<List<int>> registrarAutomaticos({DateTime? fecha});
}
