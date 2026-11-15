/// Nivel de riesgo de un tipo de inversión.
class NivelRiesgo {
  NivelRiesgo._();

  static const bajo = 'B';
  static const medio = 'M';
  static const alto = 'A';

  static const valores = [bajo, medio, alto];

  static bool esValido(String? codigo) => valores.contains(codigo);

  /// Clave de traducción del nombre.
  static String clave(String codigo) => switch (codigo) {
        bajo => 'riesgo_bajo',
        medio => 'riesgo_medio',
        alto => 'riesgo_alto',
        _ => 'riesgo_sin_definir',
      };
}
