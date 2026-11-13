// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cuenta_mapper.dart';

// **************************************************************************
// MapperGenerator
// **************************************************************************

class CuentaMapprImpl extends CuentaMappr {
  CuentaMapprImpl() : super();

  @override
  Cuenta fromModel(CuentaDto model) {
    final cuenta = Cuenta(
      idCuenta: model.idCuenta,
      nombre: model.nombre,
      tipoCuenta: model.tipoCuenta,
      entidad: model.entidad,
      nroCuenta: model.nroCuenta,
      exentaImpuesto: model.exentaImpuesto,
      descripcion: model.descripcion,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return cuenta;
  }

  @override
  CuentaDto fromDto(Cuenta model) {
    final cuentadto = CuentaDto(
      idCuenta: model.idCuenta,
      nombre: model.nombre,
      tipoCuenta: model.tipoCuenta,
      entidad: model.entidad,
      nroCuenta: model.nroCuenta,
      exentaImpuesto: model.exentaImpuesto,
      descripcion: model.descripcion,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      deleteAt: model.deleteAt,
    );
    return cuentadto;
  }
}
