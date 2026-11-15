import 'package:inversiones/page/metas/dto/meta_dto.dart';

/// Metas de ahorro: objetivo, fecha opcional y portafolios cuyo saldo es el
/// avance.
abstract class IMeta {
  /// Todas las metas con su avance al día [hoy] (hoy por defecto). Activas
  /// primero, luego por fecha objetivo.
  Future<List<AvanceMetaDto>> listar({DateTime? hoy});

  /// Avance de una meta.
  Future<AvanceMetaDto> obtenerAvance(int idMeta, {DateTime? hoy});

  /// Datos de la meta para editarla.
  Future<MetaDto> obtenerMeta(int idMeta);

  /// Resumen de las metas activas para el inicio ([maximo] destacadas).
  Future<ResumenMetasDto> resumen({DateTime? hoy, int maximo = 3});

  /// Portafolios que se pueden vincular a la meta [idMeta] (o a una nueva):
  /// los que no pertenecen a otra meta y no son tarjetas ni préstamos.
  Future<List<PortafolioMetaDto>> portafoliosDisponibles({int? idMeta});

  /// Crea o actualiza la meta y sus portafolios. Retorna su id.
  Future<int> guardar(MetaDto meta);

  /// Pausa o reactiva la meta.
  Future<void> cambiarActivo(int idMeta, bool activo);

  /// Elimina la meta (borrado lógico). Los portafolios, sus movimientos y
  /// sus aportes programados no se tocan.
  Future<void> eliminar(int idMeta);

  /// Crea o actualiza el aporte programado mensual de [idPortafolio] (uno
  /// de los de la meta) por [valor], o por la cuota sugerida si no se
  /// indica.
  Future<void> programarAporte(int idMeta,
      {required int idPortafolio,
      int? valor,
      int diaMes = 1,
      bool automatico = false,
      DateTime? hoy});
}
