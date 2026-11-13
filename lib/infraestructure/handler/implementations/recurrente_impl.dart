import 'package:inversiones/config/database_config.dart';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:inversiones/config/registro.dart';
import 'package:inversiones/domain/entity/recurrente_entity.dart';
import 'package:inversiones/domain/mappers/recurrente_mapper.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/schema/recurrente_schema.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/implementations/transaccion_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/recurrente_interface.dart';
import 'package:inversiones/infraestructure/handler/interfaces/transaccion_interface.dart';
import 'package:inversiones/page/movimientos/transacciones/dto/transaccion_dto.dart';
import 'package:inversiones/page/recurrentes/dto/recurrente_dto.dart';

class RecurrenteHandler implements IRecurrente {
  static const diaMinimo = 1;
  static const diaMaximo = 31;

  final RecurrenteSchema _recurrenteSchema;
  final ITransaccion _transaccionHandler;

  RecurrenteHandler(
      {RecurrenteSchema? recurrenteSchema, ITransaccion? transaccionHandler})
      : _recurrenteSchema = recurrenteSchema ?? RecurrenteSchema(),
        _transaccionHandler = transaccionHandler ?? TransaccionHandler();

  static final _formatoDia = DateFormat('yyyy-MM-dd');

  /// Fecha del [dia] en el mes de [referencia]; en meses cortos, el último.
  static DateTime fechaEnMes(DateTime referencia, int dia) {
    final ultimoDia = DateTime(referencia.year, referencia.month + 1, 0).day;
    return DateTime(referencia.year, referencia.month, min(dia, ultimoDia));
  }

  @override
  Future<List<RecurrenteDto>> listar({DateTime? fecha}) async {
    try {
      final hoy = fecha ?? DateTime.now();
      final detalle = await _recurrenteSchema.obtenerDetalle(
        desde: _formatoDia.format(DateTime(hoy.year, hoy.month, 1)),
        hasta: _formatoDia.format(DateTime(hoy.year, hoy.month + 1, 1)),
      );
      final mappr = RecurrenteMapprImpl();
      return detalle.map((d) {
        final dto = mappr.fromDetalle(d);
        dto.fechaProgramada = fechaEnMes(hoy, d.diaMes);
        return dto;
      }).toList();
    } catch (e, pila) {
      Registro.error('RecurrenteHandler: error en consulta', e, pila);
      rethrow;
    }
  }

  @override
  Future<List<RecurrenteDto>> pendientesDelMes({DateTime? fecha}) async =>
      (await listar(fecha: fecha)).where((r) => r.pendiente).toList();

  @override
  Future<int> registrarMovimientoFijo(TransaccionDto movimiento,
          {required String nombre, required int diaMes}) =>
      DatabaseHelper().enTransaccion(() async {
        final idTransaccion =
            await _transaccionHandler.createTransaccion(movimiento);
        await crearDesdeMovimiento(movimiento,
            idTransaccion: idTransaccion, nombre: nombre, diaMes: diaMes);
        return idTransaccion;
      });

  @override
  Future<int> crearDesdeMovimiento(TransaccionDto movimiento,
          {required int idTransaccion,
          required String nombre,
          required int diaMes}) =>
      DatabaseHelper().enTransaccion(() => _crearDesdeMovimiento(movimiento,
          idTransaccion: idTransaccion, nombre: nombre, diaMes: diaMes));

  Future<int> _crearDesdeMovimiento(TransaccionDto movimiento,
      {required int idTransaccion,
      required String nombre,
      required int diaMes}) async {
    try {
      _validar(nombre: nombre, valor: movimiento.valor, diaMes: diaMes);
      final id = await _recurrenteSchema.insert(Recurrente(
        nombre: nombre.trim(),
        tipoTransferenciaId: movimiento.tipoTransferenciaId,
        portafolioId: movimiento.portafolioId,
        destinoCuenta: movimiento.destinoCuenta,
        destinoAlternativo: movimiento.destinoAlternativo,
        motivoId: movimiento.motivoId,
        terceroId: movimiento.terceroId,
        valor: movimiento.valor,
        diaMes: diaMes,
        descripcion: movimiento.descripcion,
      ));
      await TransferenciaShema().asignarRecurrente(idTransaccion, id);
      return id;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> actualizar(int idRecurrente,
      {String? nombre, int? valor, int? diaMes, bool? activo}) async {
    try {
      final recurrente = await _obtener(idRecurrente);
      recurrente.nombre = nombre?.trim() ?? recurrente.nombre;
      recurrente.valor = valor ?? recurrente.valor;
      recurrente.diaMes = diaMes ?? recurrente.diaMes;
      recurrente.activo = activo ?? recurrente.activo;
      _validar(
          nombre: recurrente.nombre,
          valor: recurrente.valor,
          diaMes: recurrente.diaMes);
      await _recurrenteSchema.update(recurrente);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> eliminar(int idRecurrente) async {
    try {
      final result = await _recurrenteSchema.deleteById(idRecurrente);
      if (result != 1) throw Exception('No se encontró el movimiento fijo');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> registrar(int idRecurrente, {DateTime? fecha, int? valor}) async {
    try {
      final recurrente = await _obtener(idRecurrente);
      final dia = fecha ?? DateTime.now();
      final estado = (await listar(fecha: dia))
          .where((r) => r.idRecurrente == idRecurrente);
      if (estado.isNotEmpty && estado.first.registradoEnMes) {
        throw Exception('"${recurrente.nombre}" ya se registró este mes');
      }

      final ahora = DateTime.now();
      final fechaHora = DateTime(
          dia.year, dia.month, dia.day, ahora.hour, ahora.minute, ahora.second);
      return await _transaccionHandler.createTransaccion(TransaccionDto(
        valor: valor ?? recurrente.valor,
        tipoTransferenciaId: recurrente.tipoTransferenciaId,
        portafolioId: recurrente.portafolioId,
        destinoCuenta: recurrente.destinoCuenta,
        destinoAlternativo: recurrente.destinoAlternativo,
        motivoId: recurrente.motivoId,
        terceroId: recurrente.terceroId,
        recurrenteId: idRecurrente,
        descripcion: recurrente.descripcion ?? recurrente.nombre,
        createdAt: DateFormat(Auditoria.formatoFecha).format(fechaHora),
      ));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<int>> registrarAutomaticos({DateTime? fecha}) async {
    final hoy = fecha ?? DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final creados = <int>[];
    for (final pendiente in await pendientesDelMes(fecha: hoy)) {
      final recurrente =
          await _recurrenteSchema.getById(pendiente.idRecurrente);
      if (recurrente == null || !recurrente.automatico) continue;
      final programada = fechaEnMes(hoy, recurrente.diaMes);
      if (programada.isAfter(inicioHoy)) continue;
      try {
        creados.add(await registrar(recurrente.idRecurrente!, fecha: programada));
      } catch (e, pila) {
        // Un fijo que no se pudo registrar (p. ej. sin cupo) no frena a los demás.
        Registro.error('RecurrenteHandler: fijo automático no registrado', e, pila);
      }
    }
    return creados;
  }

  Future<Recurrente> _obtener(int idRecurrente) async {
    final recurrente = await _recurrenteSchema.getById(idRecurrente);
    if (recurrente == null) throw Exception('El movimiento fijo no existe');
    return recurrente;
  }

  void _validar(
      {required String nombre, required int valor, required int diaMes}) {
    if (nombre.trim().isEmpty) {
      throw Exception('El nombre del movimiento fijo es obligatorio');
    }
    if (valor <= 0) throw Exception('El valor debe ser mayor a cero');
    if (diaMes < diaMinimo || diaMes > diaMaximo) {
      throw Exception('El día debe estar entre $diaMinimo y $diaMaximo');
    }
  }
}
