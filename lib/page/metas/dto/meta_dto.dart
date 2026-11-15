import 'dart:math';

/// Datos que el formulario envía para crear o editar una meta.
class MetaDto {
  int? idMeta;
  String nombre;
  String? descripcion;
  int montoObjetivo;

  /// yyyy-MM-dd; nula = sin fecha.
  String? fechaObjetivo;

  /// Portafolios cuyo saldo cuenta como avance (al menos uno).
  List<int> portafolioIds;
  bool activo;

  MetaDto({
    this.idMeta,
    required this.nombre,
    this.descripcion,
    required this.montoObjetivo,
    this.fechaObjetivo,
    this.portafolioIds = const [],
    this.activo = true,
  });
}

/// Estado de una meta respecto a su objetivo.
enum EstadoMeta {
  /// El saldo ya alcanza el objetivo.
  completada,

  /// Con fecha: el aporte programado cubre la cuota sugerida.
  alDia,

  /// Con fecha: no hay aporte programado o no alcanza la cuota sugerida.
  atrasada,

  /// La fecha objetivo pasó sin completar la meta.
  vencida,

  /// Sin fecha objetivo: solo se muestra el avance.
  sinFecha,

  /// Pausada por el usuario.
  pausada;

  /// Clave i18n del estado.
  String get clave => 'meta_estado_$name';
}

/// Portafolio vinculado a una meta con su saldo y tasa.
class PortafolioMetaDto {
  final int idPortafolio;
  final String nombre;
  final int saldo;

  /// Tasa efectiva anual (%).
  final num tasaEa;

  /// Aporte programado activo del portafolio, llevado a valor mensual.
  final int aporteMensual;

  const PortafolioMetaDto({
    required this.idPortafolio,
    required this.nombre,
    required this.saldo,
    required this.tasaEa,
    required this.aporteMensual,
  });
}

/// Meta con su avance calculado.
class AvanceMetaDto {
  final int idMeta;
  final String nombre;
  final String? descripcion;
  final int montoObjetivo;
  final DateTime? fechaObjetivo;
  final bool activo;
  final List<PortafolioMetaDto> portafolios;

  /// Suma de los saldos de los portafolios (nunca negativa).
  final int ahorrado;

  /// Meses de aporte que quedan hasta la fecha (nulo si no tiene fecha).
  final int? mesesRestantes;

  /// Tasa E.A. ponderada por saldo de los portafolios.
  final double tasaEa;

  /// Aporte mensual sugerido para llegar a tiempo (nulo si no tiene fecha).
  final int? cuotaSugerida;

  /// Suma mensual de los aportes programados de sus portafolios.
  final int aporteProgramadoMensual;

  /// Proyección del ahorro a la fecha con los aportes programados actuales
  /// y el rendimiento (nula si no tiene fecha).
  final int? proyeccion;
  final EstadoMeta estado;

  const AvanceMetaDto({
    required this.idMeta,
    required this.nombre,
    this.descripcion,
    required this.montoObjetivo,
    this.fechaObjetivo,
    required this.activo,
    required this.portafolios,
    required this.ahorrado,
    this.mesesRestantes,
    required this.tasaEa,
    this.cuotaSugerida,
    required this.aporteProgramadoMensual,
    this.proyeccion,
    required this.estado,
  });

  int get falta => max(0, montoObjetivo - ahorrado);

  /// Avance entre 0 y 1.
  double get porcentaje =>
      montoObjetivo <= 0 ? 0 : min(1.0, max(0.0, ahorrado / montoObjetivo));

  bool get completada => estado == EstadoMeta.completada;
}

/// Resumen de las metas activas para el inicio.
class ResumenMetasDto {
  final int cantidad;
  final int completadas;
  final int atrasadas;
  final int objetivoTotal;
  final int ahorradoTotal;

  /// Las metas activas más próximas (para la tarjeta del inicio).
  final List<AvanceMetaDto> destacadas;

  const ResumenMetasDto({
    required this.cantidad,
    required this.completadas,
    required this.atrasadas,
    required this.objetivoTotal,
    required this.ahorradoTotal,
    required this.destacadas,
  });

  double get porcentaje =>
      objetivoTotal <= 0 ? 0 : min(1.0, max(0.0, ahorradoTotal / objetivoTotal));
}
