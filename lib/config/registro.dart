import 'dart:developer' as developer;

/// Registro centralizado de eventos y errores (reemplaza `print`).
///
/// Usa `dart:developer`, que aparece en la consola de depuración y en
/// DevTools y no imprime nada en builds de release.
class Registro {
  static const _nombreApp = 'inversiones';
  static const _nivelInfo = 800;
  static const _nivelError = 1000;

  Registro._();

  static void info(String mensaje) =>
      developer.log(mensaje, name: _nombreApp, level: _nivelInfo);

  static void error(String mensaje, Object error, [StackTrace? pila]) =>
      developer.log(mensaje,
          name: _nombreApp, level: _nivelError, error: error, stackTrace: pila);
}
