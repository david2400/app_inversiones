/// Transferencias agrupadas por recorrido: cuenta origen → destino.
class FlujoEntreCuentas {
  String origen;

  /// Portafolio destino, tercero o cuenta externa.
  String? destino;

  /// `true` si el destino no es un portafolio propio.
  bool externo;
  int total;
  int impuestos;
  int cantidad;

  FlujoEntreCuentas({
    required this.origen,
    this.destino,
    required this.externo,
    required this.total,
    required this.impuestos,
    required this.cantidad,
  });

  factory FlujoEntreCuentas.fromJson(Map<String, dynamic> json) =>
      FlujoEntreCuentas(
        origen: json["origen"],
        destino: json["destino"],
        externo: json["externo"] == 1,
        total: json["total"] ?? 0,
        impuestos: json["impuestos"] ?? 0,
        cantidad: json["cantidad"] ?? 0,
      );
}
