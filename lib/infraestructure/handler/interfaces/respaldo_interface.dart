/// Copias de seguridad del archivo de base de datos.
abstract class IRespaldo {
  /// Copia la base de datos en [directorio] y retorna la ruta del archivo.
  Future<String> exportar(String directorio);

  /// Reemplaza la base de datos actual por el respaldo en [archivo]. Antes
  /// guarda una copia de seguridad de los datos actuales junto al original.
  Future<void> restaurar(String archivo);
}
