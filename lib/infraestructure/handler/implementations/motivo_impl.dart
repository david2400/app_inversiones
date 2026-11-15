import 'package:inversiones/config/registro.dart';
import 'package:inversiones/domain/entity/motivos_entity.dart';
import 'package:inversiones/domain/mappers/motivos_mapper.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/motivo_interface.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';

class MotivoHandler implements IMotivo {
  static const largoMaximoNombre = 60;

  /// Naturalezas válidas de un motivo (nula = ambas).
  static const naturalezas = [TipoFuente.ingreso, TipoFuente.egreso];

  final MotivosSchema _schema;

  MotivoHandler({MotivosSchema? schema}) : _schema = schema ?? MotivosSchema();

  @override
  Future<List<MotivosDto>> listarMotivos() => listarActivos();

  @override
  Future<List<MotivosDto>> listarActivos({String? naturaleza}) async {
    try {
      final mappr = MotivoMapprImpl();
      final filtro = naturalezas.contains(naturaleza) ? naturaleza : null;
      return (await _schema.getActivos(soloNaturaleza: filtro))
          .map(mappr.fromDto)
          .toList();
    } catch (e, pila) {
      Registro.error('MotivoHandler: error en consulta', e, pila);
      rethrow;
    }
  }

  @override
  Future<List<MotivosDto>> listarConUso() async {
    final filas = await _schema.listarConUso();
    return filas.map((f) => MotivosDto.fromJson(f)).toList();
  }

  @override
  Future<MotivosDto> obtenerMotivo(int id) async {
    final encontrado =
        (await listarConUso()).where((m) => m.idMotivo == id);
    if (encontrado.isEmpty) throw Exception('El motivo no existe');
    return encontrado.first;
  }

  @override
  Future<int> guardarMotivo(MotivosDto dto) async {
    final nombre = dto.nombre.trim();
    if (nombre.isEmpty) throw Exception('El nombre es obligatorio');
    if (nombre.length > largoMaximoNombre) {
      throw Exception(
          'El nombre no puede tener más de $largoMaximoNombre caracteres');
    }
    final naturaleza = (dto.naturaleza ?? '').trim();
    if (naturaleza.isNotEmpty && !naturalezas.contains(naturaleza)) {
      throw Exception('La naturaleza no es válida');
    }
    if (await _schema.existeNombre(nombre, exceptoId: dto.idMotivo)) {
      throw Exception('Ya existe un motivo llamado "$nombre"');
    }

    final id = dto.idMotivo;
    if (id == null) {
      final nuevo = await _schema.insert(Motivos(
        nombre: nombre,
        descripcion: dto.descripcion.trim(),
        naturaleza: naturaleza.isEmpty ? null : naturaleza,
        activo: dto.activo,
      ));
      if (nuevo == 0) throw Exception('No se pudo realizar el registro');
      return nuevo;
    }
    final actual = await _obtener(id);
    actual
      ..nombre = nombre
      ..descripcion = dto.descripcion.trim()
      ..naturaleza = naturaleza.isEmpty ? null : naturaleza;
    final resultado = await _schema.update(actual);
    if (resultado != 1) throw Exception('No se pudo actualizar');
    return id;
  }

  @override
  Future<void> cambiarActivo(int id, bool activo) async {
    final actual = await _obtener(id);
    actual.activo = activo;
    await _schema.update(actual);
  }

  @override
  Future<int> deleteMotivo(int id) async {
    await _obtener(id);
    final usos = await _schema.contarUsos(id);
    if (usos > 0) {
      throw Exception('No se puede eliminar: tiene $usos movimientos, fijos '
          'o presupuestos. Desactívalo para ocultarlo sin perder su historial');
    }
    final result = await _schema.deleteById(id);
    if (result != 1) throw Exception('El motivo no existe');
    return result;
  }

  Future<Motivos> _obtener(int id) async {
    final motivo = await _schema.getById(id);
    if (motivo == null) throw Exception('El motivo no existe');
    return motivo;
  }
}
