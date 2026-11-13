import 'package:inversiones/page/presupuestos/dto/presupuesto_dto.dart';

abstract class IPresupuesto {
  /// Presupuestos activos con lo gastado en el mes de [fecha] (hoy si es
  /// `null`), ordenados de mayor a menor porcentaje usado.
  Future<List<EjecucionPresupuestoDto>> ejecucionDelMes({DateTime? fecha});

  /// Crea o actualiza el presupuesto mensual del motivo. Con [cuentaId]
  /// el presupuesto solo cuenta lo que sale de esa cuenta; sin ella, el de
  /// todas las cuentas.
  Future<void> guardar(
      {required int motivoId, required int montoMensual, int? cuentaId});

  Future<void> eliminar(int idPresupuesto);
}
