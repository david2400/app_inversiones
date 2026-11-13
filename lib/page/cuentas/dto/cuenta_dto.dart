/// Cuenta para la capa de presentación: datos de la cuenta y, en las
/// consultas, su saldo y su portafolio principal.
class CuentaDto {
  int? idCuenta;
  String nombre;

  /// Ver `TipoCuenta`.
  String tipoCuenta;
  String? entidad;
  String? nroCuenta;

  /// 'S' exenta de 4x1000, 'N' paga 4x1000.
  String exentaImpuesto;
  String? descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  /// Suma de los saldos de todos sus portafolios (solo en consultas).
  int saldo;

  /// Portafolio donde se registran los movimientos de la cuenta.
  int? idPortafolioPrincipal;

  /// Cantidad de portafolios activos (incluye el principal).
  int cantidadPortafolios;

  CuentaDto({
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
    this.saldo = 0,
    this.idPortafolioPrincipal,
    this.cantidadPortafolios = 0,
  });
}
