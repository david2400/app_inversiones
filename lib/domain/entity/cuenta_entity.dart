/// Cuenta donde vive el dinero: ahorros, corriente, digital o efectivo.
/// Los rendimientos de las inversiones llegan a una cuenta.
class Cuenta {
  int? idCuenta;
  String nombre;

  /// Ver `TipoCuenta`.
  String tipoCuenta;

  /// Banco o aplicación (Bancolombia, Nequi...).
  String? entidad;
  String? nroCuenta;

  /// 'S' si está exenta del GMF (4x1000), 'N' si no.
  String exentaImpuesto;
  String? descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  Cuenta({
    this.idCuenta,
    required this.nombre,
    required this.tipoCuenta,
    this.entidad,
    this.nroCuenta,
    this.exentaImpuesto = 'N',
    this.descripcion,
    this.createdAt,
    this.updatedAt,
    this.deleteAt,
  });

  factory Cuenta.fromJson(Map<String, dynamic> json) => Cuenta(
        idCuenta: json["id_cuenta"],
        nombre: json["nombre"],
        tipoCuenta: json["tipo_cuenta"],
        entidad: json["entidad"],
        nroCuenta: json["nro_cuenta"],
        exentaImpuesto: json["exenta_impuesto"] ?? 'N',
        descripcion: json["descripcion"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_cuenta": idCuenta,
        "nombre": nombre,
        "tipo_cuenta": tipoCuenta,
        "entidad": entidad,
        "nro_cuenta": nroCuenta,
        "exenta_impuesto": exentaImpuesto,
        "descripcion": descripcion,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
