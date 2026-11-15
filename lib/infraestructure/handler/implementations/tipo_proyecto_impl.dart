import 'package:inversiones/domain/entity/tipo_proyecto_entity.dart';
import 'package:inversiones/domain/mappers/tipo_proyecto_mapper.dart';
import 'package:inversiones/domain/models/perfil_inversion.dart';
import 'package:inversiones/domain/schema/tipo_proyecto_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tipo_proyecto_interface.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';

class TipoProyectoHandler implements ITipoProyecto {
  static const largoMaximoNombre = 60;

  final TipoProyectoSchema _schema;

  TipoProyectoHandler({TipoProyectoSchema? schema})
      : _schema = schema ?? TipoProyectoSchema();

  @override
  Future<List<TipoProyectoDto>> listarTipoProyecto() async {
    final filas = await _schema.listarConUso();
    return filas.map((f) => TipoProyectoDto.fromJson(f)).toList();
  }

  @override
  Future<TipoProyectoDto> obtenerTipoProyecto(int id) async {
    final tipo = await _schema.getById(id);
    if (tipo == null) throw Exception('El tipo de proyecto no existe');
    return TipoProyectoMapprImpl().fromDto(tipo)
      ..cantidadProyectos = await _schema.contarProyectos(id);
  }

  @override
  Future<int> guardarTipoProyecto(TipoProyectoDto dto) async {
    final nombre = dto.nombre.trim();
    if (nombre.isEmpty) throw Exception('El nombre es obligatorio');
    if (nombre.length > largoMaximoNombre) {
      throw Exception(
          'El nombre no puede tener más de $largoMaximoNombre caracteres');
    }
    final riesgo = _codigo(dto.riesgo);
    if (riesgo != null && !NivelRiesgo.esValido(riesgo)) {
      throw Exception('El nivel de riesgo no es válido');
    }
    if (await _schema.existeNombre(nombre, exceptoId: dto.idTipoProyecto)) {
      throw Exception('Ya existe un tipo de proyecto llamado "$nombre"');
    }

    final id = dto.idTipoProyecto;
    if (id == null) {
      final nuevo = await _schema.insert(TipoProyecto(
        nombre: nombre,
        descripcion: dto.descripcion.trim(),
        riesgo: riesgo,
      ));
      if (nuevo == 0) throw Exception('No se pudo realizar el registro');
      return nuevo;
    }
    final actual = await _schema.getById(id);
    if (actual == null) throw Exception('El tipo de proyecto no existe');
    actual
      ..nombre = nombre
      ..descripcion = dto.descripcion.trim()
      ..riesgo = riesgo;
    final resultado = await _schema.update(actual);
    if (resultado != 1) throw Exception('No se pudo actualizar');
    return id;
  }

  @override
  Future<int> deleteTipoProyecto(int id) async {
    final enUso = await _schema.contarProyectos(id);
    if (enUso > 0) {
      throw Exception(
          'No se puede eliminar: $enUso proyectos usan este tipo. Cámbiales el tipo primero');
    }
    final result = await _schema.deleteById(id);
    if (result != 1) throw Exception('El tipo de proyecto no existe');
    return result;
  }

  /// Los formularios usan '' como "sin selección".
  static String? _codigo(String? valor) {
    final limpio = valor?.trim() ?? '';
    return limpio.isEmpty ? null : limpio;
  }
}
