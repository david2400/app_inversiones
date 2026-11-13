// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saldo_portafolio_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class SaldoPortafolioMapprImpl extends SaldoPortafolioMappr {
  SaldoPortafolioMapprImpl() : super();

  @override
  SaldoPortafolioDto fromDto(SaldoPortafolio model) {
    final saldoportafoliodto = SaldoPortafolioDto(
      idPortafolio: model.idPortafolio,
      nombre: model.nombre,
      proyectoId: model.proyectoId,
      ingresos: model.ingresos,
      egresos: model.egresos,
      impuestos: model.impuestos,
      saldo: model.saldo,
    );
    return saldoportafoliodto;
  }
}
