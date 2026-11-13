/// Plantilla de un movimiento que se repite cada mes (arriendo, salario,
/// servicios...). Los movimientos registrados desde ella guardan su id.
class Recurrente {
  int? idRecurrente;
  String nombre;
  int tipoTransferenciaId;
  int portafolioId;
  int? destinoCuenta;
  String? destinoAlternativo;
  int? motivoId;
  int? terceroId;
  int valor;

  /// Día del mes en que se espera (1–31; en meses cortos, el último día).
  int diaMes;
  bool activo;

  /// La app lo registra sola cuando llega su día (cuota de manejo).
  bool automatico;
  String? descripcion;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  Recurrente({
    this.idRecurrente,
    required this.nombre,
    required this.tipoTransferenciaId,
    required this.portafolioId,
    this.destinoCuenta,
    this.destinoAlternativo,
    this.motivoId,
    this.terceroId,
    required this.valor,
    required this.diaMes,
    this.activo = true,
    this.automatico = false,
    this.descripcion,
    this.createdAt,
    this.updatedAt,
    this.deleteAt,
  });

  factory Recurrente.fromJson(Map<String, dynamic> json) => Recurrente(
        idRecurrente: json["id_recurrente"],
        nombre: json["nombre"],
        tipoTransferenciaId: json["tipo_transferencia_id"],
        portafolioId: json["portafolio_id"],
        destinoCuenta: json["destino_cuenta"],
        destinoAlternativo: json["destino_alternativo"],
        motivoId: json["motivo_id"],
        terceroId: json["tercero_id"],
        valor: json["valor"],
        diaMes: json["dia_mes"],
        activo: json["activo"] == 1,
        automatico: json["automatico"] == 1,
        descripcion: json["descripcion"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_recurrente": idRecurrente,
        "nombre": nombre,
        "tipo_transferencia_id": tipoTransferenciaId,
        "portafolio_id": portafolioId,
        "destino_cuenta": destinoCuenta,
        "destino_alternativo": destinoAlternativo,
        "motivo_id": motivoId,
        "tercero_id": terceroId,
        "valor": valor,
        "dia_mes": diaMes,
        "activo": activo ? 1 : 0,
        "automatico": automatico ? 1 : 0,
        "descripcion": descripcion,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
