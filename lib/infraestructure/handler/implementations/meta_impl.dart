import 'dart:math';

import 'package:intl/intl.dart';
import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/config/registro.dart';
import 'package:inversiones/domain/entity/meta_entity.dart';
import 'package:inversiones/domain/entity/portafolio_entity.dart';
import 'package:inversiones/domain/mappers/meta_mapper.dart';
import 'package:inversiones/domain/models/calculadora_meta.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/domain/schema/meta_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/schema/recurrente_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/recurrente_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/meta_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/recurrente_interface.dart';
import 'package:inversiones/page/gestion/portafolio/dto/aporte_programado_dto.dart';
import 'package:inversiones/page/metas/dto/meta_dto.dart';

class MetaHandler implements IMeta {
  final MetaSchema _metas;
  final MetaPortafolioSchema _vinculos;
  final IRecurrente _recurrentes;
  static const _mapper = MetaMapper();

  /// Largo máximo del nombre de una meta.
  static const largoMaximoNombre = 60;

  static final _formatoDia = DateFormat('yyyy-MM-dd');

  MetaHandler(
      {MetaSchema? metas,
      MetaPortafolioSchema? vinculos,
      IRecurrente? recurrentes})
      : _metas = metas ?? MetaSchema(),
        _vinculos = vinculos ?? MetaPortafolioSchema(),
        _recurrentes = recurrentes ?? RecurrenteHandler();

  // ---------------------------------------------------------------- consultas

  @override
  Future<List<AvanceMetaDto>> listar({DateTime? hoy}) async {
    try {
      final contexto = await _Contexto.cargar();
      final vinculos = await _vinculos.portafoliosPorMeta();
      final metas = await _metas.getAll();
      return [
        for (final meta in metas)
          _avance(meta, vinculos[meta.idMeta] ?? const [], contexto,
              hoy ?? DateTime.now()),
      ];
    } catch (e, pila) {
      Registro.error('MetaHandler: error al listar metas', e, pila);
      rethrow;
    }
  }

  @override
  Future<AvanceMetaDto> obtenerAvance(int idMeta, {DateTime? hoy}) async {
    try {
      final meta = await _buscar(idMeta);
      return _avance(meta, await _vinculos.portafoliosDe(idMeta),
          await _Contexto.cargar(), hoy ?? DateTime.now());
    } catch (e, pila) {
      Registro.error('MetaHandler: error al consultar la meta', e, pila);
      rethrow;
    }
  }

  @override
  Future<MetaDto> obtenerMeta(int idMeta) async {
    final meta = await _buscar(idMeta);
    return _mapper.aDto(meta, await _vinculos.portafoliosDe(idMeta));
  }

  @override
  Future<ResumenMetasDto> resumen({DateTime? hoy, int maximo = 3}) async {
    final activas = (await listar(hoy: hoy)).where((m) => m.activo).toList();
    // Destacadas: primero las que necesitan atención, luego las más cercanas.
    int prioridad(AvanceMetaDto m) => switch (m.estado) {
          EstadoMeta.vencida => 0,
          EstadoMeta.atrasada => 1,
          EstadoMeta.alDia => 2,
          EstadoMeta.sinFecha => 3,
          _ => 4,
        };
    final destacadas = [...activas]..sort((a, b) {
        final p = prioridad(a).compareTo(prioridad(b));
        if (p != 0) return p;
        return (a.mesesRestantes ?? 1 << 30)
            .compareTo(b.mesesRestantes ?? 1 << 30);
      });
    return ResumenMetasDto(
      cantidad: activas.length,
      completadas: activas.where((m) => m.completada).length,
      atrasadas: activas
          .where((m) =>
              m.estado == EstadoMeta.atrasada || m.estado == EstadoMeta.vencida)
          .length,
      objetivoTotal: activas.fold(0, (s, m) => s + m.montoObjetivo),
      ahorradoTotal:
          activas.fold(0, (s, m) => s + min(m.ahorrado, m.montoObjetivo)),
      destacadas: destacadas.take(maximo).toList(),
    );
  }

  @override
  Future<List<PortafolioMetaDto>> portafoliosDisponibles({int? idMeta}) async {
    try {
      final contexto = await _Contexto.cargar();
      final ocupados = <int>{};
      (await _vinculos.portafoliosPorMeta()).forEach((meta, ids) {
        if (meta != idMeta) ocupados.addAll(ids);
      });
      return [
        for (final p in contexto.portafolios.values)
          if (!ocupados.contains(p.idPortafolio) && !contexto.esDeuda(p))
            contexto.dto(p),
      ]..sort((a, b) =>
          a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    } catch (e, pila) {
      Registro.error('MetaHandler: error al listar portafolios', e, pila);
      rethrow;
    }
  }

  // ------------------------------------------------------------- operaciones

  @override
  Future<int> guardar(MetaDto dto) async {
    final ids = dto.portafolioIds.toSet().toList();
    await _validar(dto, ids);
    return DatabaseHelper().enTransaccion(() async {
      final entidad = _mapper.aEntidad(dto);
      int id;
      if (dto.idMeta == null) {
        id = await _metas.insert(entidad);
      } else {
        final actual = await _buscar(dto.idMeta!);
        entidad.createdAt = actual.createdAt;
        await _metas.update(entidad);
        id = dto.idMeta!;
      }
      await _vinculos.reemplazar(id, ids);
      return id;
    });
  }

  @override
  Future<void> cambiarActivo(int idMeta, bool activo) async {
    final meta = await _buscar(idMeta);
    meta.activo = activo;
    await _metas.update(meta);
  }

  @override
  Future<void> eliminar(int idMeta) async {
    await _buscar(idMeta);
    await DatabaseHelper().enTransaccion(() async {
      await _vinculos.quitarDeMeta(idMeta);
      await _metas.deleteById(idMeta);
    });
  }

  @override
  Future<void> programarAporte(int idMeta,
      {required int idPortafolio,
      int? valor,
      int diaMes = 1,
      bool automatico = false,
      DateTime? hoy}) async {
    final avance = await obtenerAvance(idMeta, hoy: hoy);
    if (!avance.portafolios.any((p) => p.idPortafolio == idPortafolio)) {
      throw Exception('El portafolio no pertenece a la meta');
    }
    // El aporte sale de la cuenta de aportes del portafolio (o Efectivo):
    // si esa cuenta también es de la meta, el total no crecería.
    final portafolio = await PortafolioSchema().getById(idPortafolio);
    final origen = await PortafolioSchema().getPrincipalDeCuenta(
        portafolio?.cuentaAportesId ?? CuentaSchema.idEfectivo);
    final ids = [for (final p in avance.portafolios) p.idPortafolio];
    if (origen != null && ids.contains(origen.idPortafolio)) {
      throw Exception(
          'El aporte saldría de una cuenta de la misma meta: elige otro portafolio o cambia su cuenta de aportes');
    }
    // La cuota sugerida descuenta lo que ya aportan los demás programados.
    final actual = await _recurrentes.obtenerAporteProgramado(idPortafolio);
    final contexto = await _Contexto.cargar();
    final otros = contexto.aporteExterno(ids, excepto: idPortafolio);
    final monto = valor ?? ((avance.cuotaSugerida ?? 0) - otros);
    if (monto <= 0) {
      throw Exception('La meta no necesita un aporte adicional');
    }
    await _recurrentes.guardarAporteProgramado(
      idPortafolio,
      AporteProgramadoDto(
        idRecurrente: actual?.idRecurrente,
        valor: monto,
        periodoMeses: 1,
        diaMes: diaMes,
        automatico: automatico,
        fechaInicio: actual?.fechaInicio,
      ),
      hoy: hoy,
    );
  }

  // ---------------------------------------------------------------- internos

  Future<Meta> _buscar(int idMeta) async {
    final meta = await _metas.getById(idMeta);
    if (meta == null) throw Exception('La meta no existe');
    return meta;
  }

  Future<void> _validar(MetaDto dto, List<int> ids) async {
    final nombre = dto.nombre.trim();
    if (nombre.isEmpty) throw Exception('El nombre es obligatorio');
    if (nombre.length > largoMaximoNombre) {
      throw Exception(
          'El nombre no puede superar $largoMaximoNombre caracteres');
    }
    if (dto.montoObjetivo <= 0) {
      throw Exception('El monto objetivo debe ser mayor a cero');
    }
    final fecha = dto.fechaObjetivo?.trim();
    if (fecha != null && fecha.isNotEmpty && DateTime.tryParse(fecha) == null) {
      throw Exception('La fecha objetivo no es válida');
    }
    if (ids.isEmpty) {
      throw Exception('Elige al menos un portafolio donde guardas el ahorro');
    }
    final disponibles = {
      for (final p in await portafoliosDisponibles(idMeta: dto.idMeta))
        p.idPortafolio
    };
    for (final id in ids) {
      if (!disponibles.contains(id)) {
        final otra = await _vinculos.metaDePortafolio(id);
        throw Exception(otra != null
            ? 'Uno de los portafolios ya pertenece a otra meta'
            : 'Uno de los portafolios no existe o no se puede usar');
      }
    }
  }

  AvanceMetaDto _avance(
      Meta meta, List<int> ids, _Contexto contexto, DateTime hoy) {
    final portafolios = [
      for (final id in ids)
        if (contexto.portafolios[id] != null)
          contexto.dto(contexto.portafolios[id]!),
    ];
    final ahorrado = max(0, portafolios.fold<int>(0, (s, p) => s + p.saldo));
    final tasa = CalculadoraMeta.tasaPonderada(
        [for (final p in portafolios) (saldo: p.saldo, tasaEa: p.tasaEa)]);
    // Solo suman los aportes que traen dinero de fuera de la meta: uno de
    // ahorros a un CDT de la misma meta no cambia el total.
    final aporteMensual = contexto.aporteExterno(ids);
    final fecha = DateTime.tryParse(meta.fechaObjetivo ?? '');
    final dia = DateTime(hoy.year, hoy.month, hoy.day);

    int? meses;
    int? cuota;
    int? proyeccion;
    if (fecha != null) {
      meses = CalculadoraMeta.mesesRestantes(dia, fecha);
      cuota = CalculadoraMeta.cuotaMensual(
          objetivo: meta.montoObjetivo,
          saldo: ahorrado,
          tasaEa: tasa,
          meses: meses);
      proyeccion = CalculadoraMeta.proyectar(
          saldo: ahorrado,
          aporteMensual: aporteMensual,
          tasaEa: tasa,
          meses: meses);
    }

    final EstadoMeta estado;
    if (!meta.activo) {
      estado = EstadoMeta.pausada;
    } else if (ahorrado >= meta.montoObjetivo) {
      estado = EstadoMeta.completada;
    } else if (fecha == null) {
      estado = EstadoMeta.sinFecha;
    } else if (!fecha.isAfter(dia)) {
      estado = EstadoMeta.vencida;
    } else if (proyeccion! >= meta.montoObjetivo) {
      estado = EstadoMeta.alDia;
    } else {
      estado = EstadoMeta.atrasada;
    }

    return AvanceMetaDto(
      idMeta: meta.idMeta!,
      nombre: meta.nombre,
      descripcion: meta.descripcion,
      montoObjetivo: meta.montoObjetivo,
      fechaObjetivo: fecha,
      activo: meta.activo,
      portafolios: portafolios,
      ahorrado: ahorrado,
      mesesRestantes: meses,
      tasaEa: tasa,
      cuotaSugerida: cuota,
      aporteProgramadoMensual: aporteMensual,
      proyeccion: proyeccion,
      estado: estado,
    );
  }

  /// Formato de fecha que se guarda (yyyy-MM-dd).
  static String formatoFecha(DateTime fecha) => _formatoDia.format(fecha);
}

/// Datos compartidos por el cálculo de varias metas: se cargan una vez.
class _Contexto {
  final Map<int, Portafolio> portafolios;
  final Map<int, int> saldos;
  /// Aportes programados activos por portafolio destino.
  final Map<int, List<({int origen, int mensual})>> aportesMensuales;
  final Set<int> cuentasDeuda;

  _Contexto(this.portafolios, this.saldos, this.aportesMensuales,
      this.cuentasDeuda);

  static Future<_Contexto> cargar() async {
    final portafolios = {
      for (final p in await PortafolioSchema().getAll())
        p.idPortafolio!: p,
    };
    final saldos = {
      for (final s in await TransferenciaShema().obtenerSaldos())
        s.idPortafolio: s.saldo,
    };
    final aportes = <int, List<({int origen, int mensual})>>{};
    for (final r in await RecurrenteSchema().getAll()) {
      final id = r.aportePortafolioId;
      if (id == null || !r.activo || r.periodoMeses <= 0) continue;
      aportes.putIfAbsent(id, () => []).add((
        origen: r.portafolioId,
        mensual: (r.valor / r.periodoMeses).round(),
      ));
    }
    final deudas = {
      for (final c in await CuentaSchema().getAll())
        if (TipoCuenta.esPasivo(c.tipoCuenta) && c.idCuenta != null)
          c.idCuenta!,
    };
    return _Contexto(portafolios, saldos, aportes, deudas);
  }

  bool esDeuda(Portafolio p) =>
      p.cuentaId != null && cuentasDeuda.contains(p.cuentaId);

  PortafolioMetaDto dto(Portafolio p) => PortafolioMetaDto(
        idPortafolio: p.idPortafolio!,
        nombre: p.nombre,
        saldo: saldos[p.idPortafolio] ?? 0,
        tasaEa: p.interes ?? 0,
        aporteMensual: aportes(p.idPortafolio!),
      );

  /// Aporte mensual programado hacia el portafolio (de cualquier origen).
  int aportes(int idPortafolio) => (aportesMensuales[idPortafolio] ?? const [])
      .fold(0, (s, a) => s + a.mensual);

  /// Aporte mensual que llega a los portafolios [ids] desde fuera de ellos,
  /// sin contar el del portafolio [excepto].
  int aporteExterno(List<int> ids, {int? excepto}) {
    var total = 0;
    for (final id in ids) {
      if (id == excepto) continue;
      for (final a in aportesMensuales[id] ?? const []) {
        if (!ids.contains(a.origen)) total += a.mensual;
      }
    }
    return total;
  }
}
