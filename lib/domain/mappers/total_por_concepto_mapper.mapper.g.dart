// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'total_por_concepto_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class TotalPorConceptoMapprImpl extends TotalPorConceptoMappr {
  TotalPorConceptoMapprImpl() : super();

  @override
  TotalPorConceptoDto fromDto(TotalPorConcepto model) {
    final totalporconceptodto = TotalPorConceptoDto(
      nombre: model.nombre,
      total: model.total,
      cantidad: model.cantidad,
    );
    return totalporconceptodto;
  }

  @override
  FlujoEntreCuentasDto fromFlujo(FlujoEntreCuentas model) {
    final flujoentrecuentasdto = FlujoEntreCuentasDto(
      origen: model.origen,
      destino: model.destino,
      externo: model.externo,
      total: model.total,
      impuestos: model.impuestos,
      cantidad: model.cantidad,
    );
    return flujoentrecuentasdto;
  }
}
