// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presupuesto_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class PresupuestoMapprImpl extends PresupuestoMappr {
  PresupuestoMapprImpl() : super();

  @override
  EjecucionPresupuestoDto fromEjecucion(EjecucionPresupuesto model) {
    final ejecucionpresupuestodto = EjecucionPresupuestoDto(
      idPresupuesto: model.idPresupuesto,
      motivoId: model.motivoId,
      motivo: model.motivo,
      montoMensual: model.montoMensual,
      gastado: model.gastado,
      cuentaId: model.cuentaId,
      cuenta: model.cuenta,
    );
    return ejecucionpresupuestodto;
  }
}
