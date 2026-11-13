/// Genera texto CSV compatible con Excel en español.
///
/// - Separador `;` (Excel en configuración regional es-CO usa coma decimal).
/// - Marca BOM UTF-8 para que Excel muestre bien tildes y eñes.
/// - Escapa comillas, separadores y saltos de línea según RFC 4180.
class GeneradorCsv {
  static const separador = ';';
  static const finDeLinea = '\r\n';
  static const bomUtf8 = '﻿';

  GeneradorCsv._();

  static String generar(List<String> encabezados, List<List<Object?>> filas) {
    final buffer = StringBuffer(bomUtf8)
      ..write(_linea(encabezados))
      ..write(finDeLinea);
    for (final fila in filas) {
      buffer
        ..write(_linea(fila))
        ..write(finDeLinea);
    }
    return buffer.toString();
  }

  static String _linea(List<Object?> celdas) =>
      celdas.map(_celda).join(separador);

  static String _celda(Object? valor) {
    final texto = valor?.toString() ?? '';
    final requiereComillas = texto.contains(separador) ||
        texto.contains('"') ||
        texto.contains('\n') ||
        texto.contains('\r');
    return requiereComillas ? '"${texto.replaceAll('"', '""')}"' : texto;
  }
}
