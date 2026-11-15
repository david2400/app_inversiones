import 'package:inversiones/domain/entity/meta_entity.dart';
import 'package:inversiones/page/metas/dto/meta_dto.dart';

/// Conversión entre la entidad [Meta] y los DTOs del formulario. El avance
/// ([AvanceMetaDto]) lo arma el handler porque combina varias fuentes.
class MetaMapper {
  const MetaMapper();

  Meta aEntidad(MetaDto dto) => Meta(
        idMeta: dto.idMeta,
        nombre: dto.nombre.trim(),
        descripcion: _texto(dto.descripcion),
        montoObjetivo: dto.montoObjetivo,
        fechaObjetivo: _texto(dto.fechaObjetivo),
        activo: dto.activo,
      );

  MetaDto aDto(Meta meta, List<int> portafolioIds) => MetaDto(
        idMeta: meta.idMeta,
        nombre: meta.nombre,
        descripcion: meta.descripcion,
        montoObjetivo: meta.montoObjetivo,
        fechaObjetivo: meta.fechaObjetivo,
        portafolioIds: portafolioIds,
        activo: meta.activo,
      );

  static String? _texto(String? valor) {
    final limpio = valor?.trim();
    return (limpio == null || limpio.isEmpty) ? null : limpio;
  }
}
