import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/entity/proyecto_entity.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_dto.dart';
import 'package:inversiones/domain/mappers/proyecto_mapper.dart';
import 'package:inversiones/domain/schema/proyecto_schema.dart';
import 'package:inversiones/domain/mappers/tipo_proyecto_mapper.dart';
import 'package:inversiones/domain/schema/tipo_proyecto_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/portafolio_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/proyecto_interface.dart';
import 'package:inversiones/page/gestion/proyecto/dto/proyecto_resumen_dto.dart';


class ProyectoHandler implements IProyecto {
  @override
  Future<int> createProyecto(ProyectoDto proyectoDto) async {
    proyectoDto.nombre = proyectoDto.nombre.trim();
    if (proyectoDto.nombre.isEmpty) {
      throw Exception('El nombre es obligatorio');
    }
    proyectoDto.descripcion = proyectoDto.descripcion.trim();
    proyectoDto.tipoProyectoId = await _tipoValido(proyectoDto.tipoProyectoId);
    ProyectoSchema proyectoSchema = ProyectoSchema();
    final mappr = ProyectoMapprImpl();
    Proyecto proyecto = mappr.fromModel(proyectoDto);
    int resultInsert = await proyectoSchema.insert(proyecto);

    if (resultInsert == 0) {
      throw Exception('No se pudo realizar el registro');
    }

    return resultInsert;
  }

  @override
  Future<ProyectoDto> obtenerProyecto(int id) async {
    final proyecto = await ProyectoSchema().getById(id);
    if (proyecto == null) throw Exception('El proyecto no existe');
    return ProyectoMapprImpl().fromDto(proyecto);
  }

  @override
  Future<int> actualizarProyecto(ProyectoDto proyectoDto) async {
    final id = proyectoDto.idProyecto;
    if (id == null) throw Exception('Falta el proyecto a editar');
    final nombre = proyectoDto.nombre.trim();
    if (nombre.isEmpty) throw Exception('El nombre es obligatorio');
    final schema = ProyectoSchema();
    final actual = await schema.getById(id);
    if (actual == null) throw Exception('El proyecto no existe');
    actual
      ..nombre = nombre
      ..descripcion = proyectoDto.descripcion.trim()
      ..tipoProyectoId = await _tipoValido(proyectoDto.tipoProyectoId);
    final resultado = await schema.update(actual);
    if (resultado != 1) throw Exception('No se pudo actualizar');
    return resultado;
  }

  @override
  Future<List<ProyectoResumenDto>> listarResumen() async {
    final proyectos = await ProyectoSchema().getAll();
    final mappr = TipoProyectoMapprImpl();
    final tipos = {
      for (final t in await TipoProyectoSchema().getAll())
        t.idTipoProyecto: mappr.fromDto(t),
    };
    final saldos = <int, int>{};
    final cantidades = <int, int>{};
    for (final s in await PortafolioHandler().listarSaldos()) {
      final idProyecto = s.proyectoId;
      if (idProyecto == null) continue;
      saldos[idProyecto] = (saldos[idProyecto] ?? 0) + s.saldo;
      cantidades[idProyecto] = (cantidades[idProyecto] ?? 0) + 1;
    }
    final mapprProyecto = ProyectoMapprImpl();
    return [
      for (final p in proyectos)
        ProyectoResumenDto(
          proyecto: mapprProyecto.fromDto(p),
          tipo: tipos[p.tipoProyectoId],
          saldo: saldos[p.idProyecto] ?? 0,
          cantidadPortafolios: cantidades[p.idProyecto] ?? 0,
        ),
    ];
  }

  /// [id] si es un tipo de proyecto activo; nulo si viene vacío (0).
  static Future<int?> _tipoValido(int? id) async {
    if (id == null || id <= 0) return null;
    if (await TipoProyectoSchema().getById(id) == null) {
      throw Exception('El tipo de proyecto no existe');
    }
    return id;
  }

  @override
  Future<int> deleteProyecto(int id) async {
    ProyectoSchema proyectoSchema = ProyectoSchema();

    final portafolios = await PortafolioSchema().getByIdProyecto(id);
    if (portafolios.isNotEmpty) {
      throw Exception(
          'No se puede eliminar: el proyecto tiene ${portafolios.length} portafolios activos');
    }

    var result = await proyectoSchema.deleteById(id);
    if (result != 1) {
      throw Exception('No se encontro el registro');
    }

    return result;
  }

  @override
  Future<List<ProyectoDto>> listarProyecto() async {
    try {
      final mappr = ProyectoMapprImpl();
      ProyectoSchema proyectoSchema = ProyectoSchema();
      List<Proyecto> listProyecto = await proyectoSchema.getAll();

      // List<ProyectoDto> listProyectoDto = mappr.convertList<Proyecto,ProyectoDto>(listProyecto);
      List<ProyectoDto> listaProyectoDto = listProyecto
          .map((proyecto) => mappr.fromDto(proyecto))
          .toList();

      return listaProyectoDto;
    } catch (e) {
      rethrow;
    }
  }
}
