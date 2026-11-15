import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';

/// Tipos de transacción. Su naturaleza (`TipoFuente`: ingreso, egreso o
/// transferencia) define cómo mueve los saldos. Hay uno del sistema por
/// naturaleza, que la app usa para aportes, rendimientos y deudas.
abstract class ITipoTransaccion {
  /// Todos los tipos no eliminados (activos e inactivos), con cantidad de
  /// movimientos y total movido, ordenados por naturaleza y nombre.
  Future<List<TipoTransaccionDto>> listarTipoTransaccion();

  /// Solo los activos, para elegir en los formularios.
  Future<List<TipoTransaccionDto>> listarActivos();

  /// Tipo por id (con su uso); lanza excepción si no existe.
  Future<TipoTransaccionDto> obtenerTipoTransaccion(int id);

  /// Crea (sin id) o actualiza. Nombre obligatorio y único. La naturaleza
  /// no cambia si es del sistema o si ya tiene movimientos o fijos.
  /// Retorna el id.
  Future<int> guardarTipoTransaccion(TipoTransaccionDto tipoTransaccionDto);

  /// Activa u oculta el tipo en los formularios. Los del sistema no se
  /// desactivan.
  Future<void> cambiarActivo(int id, bool activo);

  /// Borrado lógico. No se permite si es del sistema o si tiene
  /// movimientos o fijos (en ese caso, desactívalo).
  Future<int> deleteTipoTransaccion(int id);
}
