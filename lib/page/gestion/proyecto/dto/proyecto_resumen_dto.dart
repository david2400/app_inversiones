import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';

/// Proyecto con su tipo y el dinero que tiene hoy (suma del saldo de sus
/// portafolios), para listarlos agrupados por tipo.
class ProyectoResumenDto {
  final ProyectoDto proyecto;

  /// Tipo del proyecto; nulo si no está clasificado.
  final TipoProyectoDto? tipo;
  final int saldo;
  final int cantidadPortafolios;

  const ProyectoResumenDto({
    required this.proyecto,
    this.tipo,
    required this.saldo,
    required this.cantidadPortafolios,
  });
}
