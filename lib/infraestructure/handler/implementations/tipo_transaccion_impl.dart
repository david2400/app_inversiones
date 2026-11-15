import 'package:inversiones/domain/entity/tipo_transaccion_entity.dart';
import 'package:inversiones/domain/mappers/tipo_transaccion_mapper.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_transaccion_interface.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/dto/tipo_transaccion_dto.dart';

class TipoTransaccionHandler implements ITipoTransaccion {
  static const largoMaximoNombre = 60;

  final TipoTransaccionSchema _schema;
  final TransferenciaShema _transferencias;

  TipoTransaccionHandler(
      {TipoTransaccionSchema? schema, TransferenciaShema? transferencias})
      : _schema = schema ?? TipoTransaccionSchema(),
        _transferencias = transferencias ?? TransferenciaShema();

  @override
  Future<List<TipoTransaccionDto>> listarTipoTransaccion() async {
    final filas = await _schema.listarConUso();
    return filas.map((f) => TipoTransaccionDto.fromJson(f)).toList();
  }

  @override
  Future<List<TipoTransaccionDto>> listarActivos() async {
    final mappr = TipoTransaccionMapprImpl();
    return (await _schema.getActivos()).map(mappr.fromDto).toList();
  }

  @override
  Future<TipoTransaccionDto> obtenerTipoTransaccion(int id) async {
    final fila = (await listarTipoTransaccion())
        .where((t) => t.idTipoTransaccion == id);
    if (fila.isEmpty) throw Exception('El tipo de transacción no existe');
    return fila.first;
  }

  @override
  Future<int> guardarTipoTransaccion(TipoTransaccionDto dto) async {
    final nombre = dto.nombre.trim();
    if (nombre.isEmpty) throw Exception('El nombre es obligatorio');
    if (nombre.length > largoMaximoNombre) {
      throw Exception(
          'El nombre no puede tener más de $largoMaximoNombre caracteres');
    }
    if (!TipoFuente.esValido(dto.tipoFuente)) {
      throw Exception('La naturaleza no es válida');
    }
    if (await _schema.existeNombre(nombre,
        exceptoId: dto.idTipoTransaccion)) {
      throw Exception('Ya existe un tipo de transacción llamado "$nombre"');
    }

    final id = dto.idTipoTransaccion;
    if (id == null) {
      final nuevo = await _schema.insert(TipoTransaccion(
        nombre: nombre,
        descripcion: dto.descripcion.trim(),
        tipoFuente: dto.tipoFuente,
        activo: dto.activo,
      ));
      if (nuevo == 0) throw Exception('No se pudo realizar el registro');
      return nuevo;
    }

    final actual = await _obtener(id);
    if (actual.tipoFuente != dto.tipoFuente) {
      if (actual.esSistema) {
        throw Exception(
            'La naturaleza de un tipo del sistema no se puede cambiar');
      }
      final usos = await _usos(id);
      if (usos > 0) {
        throw Exception('No se puede cambiar la naturaleza: el tipo tiene '
            '$usos movimientos o fijos y sus saldos cambiarían');
      }
    }
    actual
      ..nombre = nombre
      ..descripcion = dto.descripcion.trim()
      ..tipoFuente = dto.tipoFuente;
    final resultado = await _schema.update(actual);
    if (resultado != 1) throw Exception('No se pudo actualizar');
    return id;
  }

  @override
  Future<void> cambiarActivo(int id, bool activo) async {
    final actual = await _obtener(id);
    if (!activo && actual.esSistema) {
      throw Exception('Un tipo del sistema no se puede desactivar');
    }
    actual.activo = activo;
    await _schema.update(actual);
  }

  @override
  Future<int> deleteTipoTransaccion(int id) async {
    final actual = await _obtener(id);
    if (actual.esSistema) {
      throw Exception('Un tipo del sistema no se puede eliminar');
    }
    final usos = await _usos(id);
    if (usos > 0) {
      throw Exception('No se puede eliminar: tiene $usos movimientos o '
          'fijos. Desactívalo para ocultarlo sin perder su historial');
    }
    final result = await _schema.deleteById(id);
    if (result != 1) throw Exception('El tipo de transacción no existe');
    return result;
  }

  Future<TipoTransaccion> _obtener(int id) async {
    final tipo = await _schema.getById(id);
    if (tipo == null) throw Exception('El tipo de transacción no existe');
    return tipo;
  }

  /// Movimientos activos + fijos activos que usan el tipo.
  Future<int> _usos(int id) async =>
      await _transferencias.contarActivosPor(
          TransferenciaShema.tipoTransferencia, id) +
      await _schema.contarFijos(id);
}
