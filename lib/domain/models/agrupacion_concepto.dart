/// Cómo agrupar ingresos/egresos en los reportes.
enum AgrupacionConcepto {
  /// Por motivo (categoría): Salario, Mercado, Servicios...
  motivo,

  /// Por contraparte: el tercero; si no hay, la cuenta externa o el motivo.
  /// Responde "¿de dónde vino?" (ingresos) y "¿a dónde se fue?" (egresos).
  contraparte,
}
