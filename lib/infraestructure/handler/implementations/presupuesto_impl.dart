import 'package:intl/intl.dart';
import 'package:inversiones/config/registro.dart';
import 'package:inversiones/domain/entity/presupuesto_entity.dart';
import 'package:inversiones/domain/mappers/presupuesto_mapper.dart';
import 'package:inversiones/domain/schema/cuenta_schema.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/domain/schema/presupuesto_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/presupuesto_interface.dart';
import 'package:inversiones/page/presupuestos/dto/presupuesto_dto.dart';

class PresupuestoHandler implements IPresupuesto {
  final PresupuestoSchema _presupuestoSchema;

  PresupuestoHandler({PresupuestoSchema? presupuestoSchema})
      : _presupuestoSchema = presupuestoSchema ?? PresupuestoSchema();

  static final _formatoDia = DateFormat('yyyy-MM-dd');

  @override
  Future<List<EjecucionPresupuestoDto>> ejecucionDelMes(
      {DateTime? fecha}) async {
    try {
      final hoy = fecha ?? DateTime.now();
      final ejecucion = await _presupuestoSchema.obtenerEjecucion(
        desde: _formatoDia.format(DateTime(hoy.year, hoy.month, 1)),
        hasta: _formatoDia.format(DateTime(hoy.year, hoy.month + 1, 1)),
      );
      final mappr = PresupuestoMapprImpl();
      return ejecucion.map(mappr.fromEjecucion).toList()
        ..sort((a, b) => b.porcentaje.compareTo(a.porcentaje));
    } catch (e, pila) {
      Registro.error('PresupuestoHandler: error en consulta', e, pila);
      rethrow;
    }
  }

  @override
  Future<void> guardar(
      {required int motivoId, required int montoMensual, int? cuentaId}) async {
    try {
      if (montoMensual <= 0) {
        throw Exception('El presupuesto debe ser mayor a cero');
      }
      if (await MotivosSchema().getById(motivoId) == null) {
        throw Exception('El motivo no existe');
      }
      if (cuentaId != null && await CuentaSchema().getById(cuentaId) == null) {
        throw Exception('La cuenta no existe');
      }
      final existente =
          await _presupuestoSchema.getByMotivo(motivoId, idCuenta: cuentaId);
      if (existente == null) {
        await _presupuestoSchema.insert(Presupuesto(
            motivoId: motivoId, montoMensual: montoMensual, cuentaId: cuentaId));
      } else {
        existente.montoMensual = montoMensual;
        await _presupuestoSchema.update(existente);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> eliminar(int idPresupuesto) async {
    try {
      final result = await _presupuestoSchema.deleteById(idPresupuesto);
      if (result != 1) throw Exception('No se encontró el presupuesto');
    } catch (e) {
      rethrow;
    }
  }
}
