// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'condiciones_credito_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class CondicionesCreditoMapprImpl extends CondicionesCreditoMappr {
  CondicionesCreditoMapprImpl() : super();

  @override
  CondicionesCredito fromModel(CondicionesCreditoDto model) {
    final condicionescredito = CondicionesCredito(
      idCuenta: model.idCuenta!,
      cupo: model.cupo,
      tasaMensual: model.tasaMensual,
      cuotaManejo: model.cuotaManejo,
      diaCorte: model.diaCorte,
      diaPago: model.diaPago,
      plazoMeses: model.plazoMeses,
      fechaDesembolso: model.fechaDesembolso,
      recurrenteManejoId: model.recurrenteManejoId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return condicionescredito;
  }

  @override
  CondicionesCreditoDto fromDto(CondicionesCredito model) {
    final condicionescreditodto = CondicionesCreditoDto(
      idCuenta: model.idCuenta,
      cupo: model.cupo,
      tasaMensual: model.tasaMensual,
      cuotaManejo: model.cuotaManejo,
      diaCorte: model.diaCorte,
      diaPago: model.diaPago,
      plazoMeses: model.plazoMeses,
      fechaDesembolso: model.fechaDesembolso,
      recurrenteManejoId: model.recurrenteManejoId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return condicionescreditodto;
  }
}
