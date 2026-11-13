/// Condiciones de una deuda (tarjeta de crédito o préstamo). Va 1 a 1 con
/// su cuenta: [idCuenta] es a la vez llave primaria y foránea.
class CondicionesCredito {
  int idCuenta;

  /// Tarjeta: cupo total. Préstamo: monto desembolsado.
  int? cupo;

  /// Tasa de interés mensual (E.M.) en milésimas de punto porcentual:
  /// 1,85 % = 1850. Ver `CalculadoraCredito.escalaTasa`.
  int tasaMensual;

  /// Tarjeta: cuota de manejo mensual.
  int? cuotaManejo;

  /// Tarjeta: día de corte (1–31).
  int? diaCorte;

  /// Día límite de pago (1–31).
  int? diaPago;

  /// Préstamo: plazo total en meses.
  int? plazoMeses;

  /// Préstamo: fecha del desembolso (`yyyy-MM-dd`).
  String? fechaDesembolso;

  /// Tarjeta: movimiento fijo automático de la cuota de manejo.
  int? recurrenteManejoId;
  String? createdAt;
  String? updatedAt;
  String? deleteAt;

  CondicionesCredito({
    required this.idCuenta,
    this.cupo,
    this.tasaMensual = 0,
    this.cuotaManejo,
    this.diaCorte,
    this.diaPago,
    this.plazoMeses,
    this.fechaDesembolso,
    this.recurrenteManejoId,
    this.createdAt,
    this.updatedAt,
    this.deleteAt,
  });

  factory CondicionesCredito.fromJson(Map<String, dynamic> json) =>
      CondicionesCredito(
        idCuenta: json["id_cuenta"],
        cupo: json["cupo"],
        tasaMensual: json["tasa_mensual"] ?? 0,
        cuotaManejo: json["cuota_manejo"],
        diaCorte: json["dia_corte"],
        diaPago: json["dia_pago"],
        plazoMeses: json["plazo_meses"],
        fechaDesembolso: json["fecha_desembolso"],
        recurrenteManejoId: json["recurrente_manejo_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deleteAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id_cuenta": idCuenta,
        "cupo": cupo,
        "tasa_mensual": tasaMensual,
        "cuota_manejo": cuotaManejo,
        "dia_corte": diaCorte,
        "dia_pago": diaPago,
        "plazo_meses": plazoMeses,
        "fecha_desembolso": fechaDesembolso,
        "recurrente_manejo_id": recurrenteManejoId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deleteAt,
      };
}
