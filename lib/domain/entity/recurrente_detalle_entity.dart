/// Movimiento fijo con nombres resueltos y su estado en un mes.
class RecurrenteDetalle {
  int idRecurrente;
  String nombre;
  String tipo;
  String tipoFuente;
  String origen;
  String? destino;
  String? motivo;
  String? tercero;
  int valor;
  int diaMes;
  bool activo;

  /// `true` si ya hay un movimiento activo de este fijo en el mes consultado.
  bool registradoEnMes;

  RecurrenteDetalle({
    required this.idRecurrente,
    required this.nombre,
    required this.tipo,
    required this.tipoFuente,
    required this.origen,
    this.destino,
    this.motivo,
    this.tercero,
    required this.valor,
    required this.diaMes,
    required this.activo,
    required this.registradoEnMes,
  });

  factory RecurrenteDetalle.fromJson(Map<String, dynamic> json) =>
      RecurrenteDetalle(
        idRecurrente: json["id_recurrente"],
        nombre: json["nombre"],
        tipo: json["tipo"],
        tipoFuente: json["tipo_fuente"],
        origen: json["origen"],
        destino: json["destino"],
        motivo: json["motivo"],
        tercero: json["tercero"],
        valor: json["valor"],
        diaMes: json["dia_mes"],
        activo: json["activo"] == 1,
        registradoEnMes: json["registrado"] == 1,
      );
}
