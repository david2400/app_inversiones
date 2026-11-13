/// Persona o entidad con la que se mueve dinero: quién paga un ingreso o
/// a quién se le paga un egreso (empresa, cliente, arrendador, tienda...).
class Tercero {
  int? idTercero;
  String nombre;
  String? descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  Tercero({
    this.idTercero,
    required this.nombre,
    this.descripcion,
    this.createdAt,
    this.updatedAt,
    this.deleteAt,
  });

  factory Tercero.fromJson(Map<String, dynamic> json) => Tercero(
        idTercero: json["id_tercero"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_tercero": idTercero,
        "nombre": nombre,
        "descripcion": descripcion,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
