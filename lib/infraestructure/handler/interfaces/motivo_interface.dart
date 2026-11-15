import 'package:inversiones/page/motivos/dto/motivos_dto.dart';

/// Motivos: por qué entra o sale el dinero. Cada uno puede ser de ingreso,
/// de gasto o servir para ambos.
abstract class IMotivo {
  /// Todos los motivos activos (para filtros e historial).
  Future<List<MotivosDto>> listarMotivos();

  /// Activos para un formulario: con [naturaleza] (`I` / `E`) solo los de
  /// esa naturaleza y los que sirven para ambas.
  Future<List<MotivosDto>> listarActivos({String? naturaleza});

  /// Todos los no eliminados (activos e inactivos) con cantidad de
  /// movimientos y total movido, para administrarlos.
  Future<List<MotivosDto>> listarConUso();

  /// Motivo con su uso; lanza excepción si no existe.
  Future<MotivosDto> obtenerMotivo(int id);

  /// Crea (sin id) o actualiza. Nombre obligatorio y único; naturaleza
  /// `I`, `E` o nula. Retorna el id.
  Future<int> guardarMotivo(MotivosDto motivo);

  /// Activa u oculta el motivo en los formularios.
  Future<void> cambiarActivo(int id, bool activo);

  /// Borrado lógico; no se permite si tiene movimientos, fijos o
  /// presupuestos (en ese caso, desactívalo).
  Future<int> deleteMotivo(int id);
}
