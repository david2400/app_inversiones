/// Criterios de búsqueda de movimientos. Todos son opcionales.
class FiltroMovimientos {
  /// Rango [desde, hasta) en formato `yyyy-MM-dd`.
  final String? desde;
  final String? hasta;

  /// `I`, `E` o `M` (ver `TipoFuente`).
  final String? tipoFuente;

  /// Movimientos que salen de o llegan a este portafolio.
  final int? idPortafolio;
  final int? idTercero;
  final int? idMotivo;

  /// Busca en descripción, tercero, motivo, cuentas y cuenta externa.
  final String? texto;

  /// Máximo de movimientos a traer (los totales sí cubren todo el filtro).
  final int limite;

  static const limitePorDefecto = 300;

  const FiltroMovimientos({
    this.desde,
    this.hasta,
    this.tipoFuente,
    this.idPortafolio,
    this.idTercero,
    this.idMotivo,
    this.texto,
    this.limite = limitePorDefecto,
  });
}
