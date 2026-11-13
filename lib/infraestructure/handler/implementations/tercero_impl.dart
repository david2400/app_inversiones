import 'package:inversiones/config/registro.dart';
import 'package:inversiones/domain/mappers/tercero_mapper.dart';
import 'package:inversiones/domain/schema/tercero_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/tercero_interface.dart';
import 'package:inversiones/page/terceros/dto/tercero_dto.dart';

class TerceroHandler implements ITercero {
  static const longitudMaximaNombre = 80;

  final TerceroSchema _terceroSchema;
  final TransferenciaShema _transferenciaShema;

  TerceroHandler(
      {TerceroSchema? terceroSchema, TransferenciaShema? transferenciaShema})
      : _terceroSchema = terceroSchema ?? TerceroSchema(),
        _transferenciaShema = transferenciaShema ?? TransferenciaShema();

  @override
  Future<List<TerceroDto>> listarTerceros() async {
    try {
      final mappr = TerceroMapprImpl();
      final terceros = await _terceroSchema.getAll();
      return terceros.map(mappr.fromDto).toList();
    } catch (e, pila) {
      Registro.error('TerceroHandler: error en consulta', e, pila);
      rethrow;
    }
  }

  @override
  Future<int> guardarTercero(TerceroDto terceroDto) async {
    try {
      final nombre = terceroDto.nombre.trim();
      if (nombre.isEmpty) {
        throw Exception('El nombre del tercero es obligatorio');
      }
      if (nombre.length > longitudMaximaNombre) {
        throw Exception(
            'El nombre no puede superar $longitudMaximaNombre caracteres');
      }
      final existente = await _terceroSchema.getByNombre(nombre);
      if (existente != null && existente.idTercero != terceroDto.idTercero) {
        throw Exception('Ya existe un tercero llamado "$nombre"');
      }

      terceroDto.nombre = nombre;
      final descripcion = terceroDto.descripcion?.trim();
      terceroDto.descripcion =
          (descripcion == null || descripcion.isEmpty) ? null : descripcion;

      final tercero = TerceroMapprImpl().fromModel(terceroDto);
      if (terceroDto.idTercero == null) {
        return await _terceroSchema.insert(tercero);
      }
      final actualizados = await _terceroSchema.update(tercero);
      if (actualizados == 0) throw Exception('El tercero no existe');
      return terceroDto.idTercero!;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> eliminarTercero(int id) async {
    try {
      final usos = await _transferenciaShema.contarActivosPor(
          TransferenciaShema.terceroId, id);
      if (usos > 0) {
        throw Exception(
            'No se puede eliminar: el tercero tiene $usos movimientos asociados');
      }
      final result = await _terceroSchema.deleteById(id);
      if (result != 1) throw Exception('No se encontró el tercero');
    } catch (e) {
      rethrow;
    }
  }
}
