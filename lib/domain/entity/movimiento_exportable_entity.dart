/// Movimiento con sus nombres resueltos, listo para exportar.
class MovimientoExportable {
  int idTransferencia;
  String fecha;
  String tipo;
  String tipoFuente;
  String origen;
  String? destino;
  String? destinoAlternativo;
  String? motivo;
  int valor;
  int impuesto;
  String? descripcion;

  MovimientoExportable({
    required this.idTransferencia,
    required this.fecha,
    required this.tipo,
    required this.tipoFuente,
    required this.origen,
    this.destino,
    this.destinoAlternativo,
    this.motivo,
    required this.valor,
    required this.impuesto,
    this.descripcion,
  });

  factory MovimientoExportable.fromJson(Map<String, dynamic> json) =>
      MovimientoExportable(
        idTransferencia: json["id_transferencia"],
        fecha: json["created_at"],
        tipo: json["tipo"],
        tipoFuente: json["tipo_fuente"],
        origen: json["origen"],
        destino: json["destino"],
        destinoAlternativo: json["destino_alternativo"],
        motivo: json["motivo"],
        valor: json["valor"],
        impuesto: json["impuesto"] ?? 0,
        descripcion: json["descripcion"],
      );
}
