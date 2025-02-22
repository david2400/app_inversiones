// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portafolio_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class PortafolioMapprImpl extends PortafolioMappr {
  PortafolioMapprImpl() : super();

  @override
  Portafolio fromModel(PortafolioDto model) {
    final portafolio = Portafolio(
      idPortafolio: model.idPortafolio,
      nombre: model.nombre,
      nroCuenta: model.nroCuenta,
      tipoRenta: model.tipoRenta,
      proyectoId: model.proyectoId,
      tipoPortafolioId: model.tipoPortafolioId,
      interes: model.interes,
      total: model.total,
      exentaImpuesto: model.exentaImpuesto,
      frecuenciaPagoId: model.frecuenciaPagoId,
      descripcion: model.descripcion,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return portafolio;
  }

  @override
  PortafolioDto fromDto(Portafolio model) {
    final portafoliodto = PortafolioDto(
      idPortafolio: model.idPortafolio,
      nombre: model.nombre,
      nroCuenta: model.nroCuenta,
      tipoRenta: model.tipoRenta,
      proyectoId: model.proyectoId,
      tipoPortafolioId: model.tipoPortafolioId,
      interes: model.interes,
      total: model.total,
      exentaImpuesto: model.exentaImpuesto,
      frecuenciaPagoId: model.frecuenciaPagoId,
      descripcion: model.descripcion,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return portafoliodto;
  }
}
