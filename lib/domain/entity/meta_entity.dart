/// Meta de ahorro: cuánto se quiere reunir y, opcionalmente, para cuándo.
/// El avance no se registra aparte: es la suma de los saldos de los
/// portafolios vinculados ([MetaPortafolio]).
class Meta {
  int? idMeta;
  String nombre;
  String? descripcion;
  int montoObjetivo;

  /// Fecha objetivo (yyyy-MM-dd); nula = meta sin fecha (p. ej. fondo de
  /// emergencia).
  String? fechaObjetivo;

  /// `false` = pausada: no se muestra como pendiente.
  bool activo;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  Meta({
    this.idMeta,
    required this.nombre,
    this.descripcion,
    required this.montoObjetivo,
    this.fechaObjetivo,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
    this.deleteAt,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        idMeta: json['id_meta'],
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        montoObjetivo: json['monto_objetivo'],
        fechaObjetivo: json['fecha_objetivo'],
        activo: (json['activo'] ?? 1) == 1,
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        deleteAt: json['deleted_at'],
      );

  Map<String, dynamic> toJson() => {
        'id_meta': idMeta,
        'nombre': nombre,
        'descripcion': descripcion,
        'monto_objetivo': montoObjetivo,
        'fecha_objetivo': fechaObjetivo,
        'activo': activo ? 1 : 0,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deleteAt,
      };
}

/// Vínculo de un portafolio con una meta. Un portafolio pertenece como
/// máximo a una meta activa, para no contar su saldo dos veces.
class MetaPortafolio {
  int? idMetaPortafolio;
  int metaId;
  int portafolioId;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  MetaPortafolio({
    this.idMetaPortafolio,
    required this.metaId,
    required this.portafolioId,
    this.createdAt,
    this.updatedAt,
    this.deleteAt,
  });

  factory MetaPortafolio.fromJson(Map<String, dynamic> json) => MetaPortafolio(
        idMetaPortafolio: json['id_meta_portafolio'],
        metaId: json['meta_id'],
        portafolioId: json['portafolio_id'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        deleteAt: json['deleted_at'],
      );

  Map<String, dynamic> toJson() => {
        'id_meta_portafolio': idMetaPortafolio,
        'meta_id': metaId,
        'portafolio_id': portafolioId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deleteAt,
      };
}
