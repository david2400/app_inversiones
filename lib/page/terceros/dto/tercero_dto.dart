class TerceroDto {
  int? idTercero;
  String nombre;
  String? descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  TerceroDto({
    this.idTercero,
    required this.nombre,
    this.descripcion,
    this.createdAt,
    this.updatedAt,
    this.deleteAt,
  });
}
