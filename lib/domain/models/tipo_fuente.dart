/// Naturaleza contable de un tipo de transacción (columna `tipo_fuente`).
class TipoFuente {
  /// El dinero entra al portafolio.
  static const ingreso = 'I';

  /// El dinero sale del portafolio hacia un tercero.
  static const egreso = 'E';

  /// El dinero se mueve del portafolio origen a un portafolio destino
  /// (o a una cuenta externa indicada en `destino_alternativo`).
  static const transferencia = 'M';

  static const valores = [ingreso, egreso, transferencia];

  TipoFuente._();

  static bool esValido(String? valor) => valores.contains(valor);

  /// Indica si el movimiento debita (resta) del portafolio origen.
  static bool debitaOrigen(String tipoFuente) => tipoFuente != ingreso;
}
