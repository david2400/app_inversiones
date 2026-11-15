import 'package:flutter/material.dart';
import 'package:inversiones/page/cuentas/page/campo_numero.dart';
import 'package:inversiones/page/cuentas/states/admin_deuda_page_state.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

/// Crear o editar una tarjeta de crédito con sus condiciones.
class AdminTarjetaPage extends StatefulWidget {
  final int? idCuenta;

  const AdminTarjetaPage({super.key, this.idCuenta});

  @override
  State<AdminTarjetaPage> createState() => _AdminTarjetaPageState();
}

class _AdminTarjetaPageState extends State<AdminTarjetaPage> {
  late AdminDeudaPageState _model;
  late Future<void> _carga;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminDeudaPageState());
    _carga = widget.idCuenta == null
        ? Future.value()
        : _model.cargarTarjeta(widget.idCuenta!);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  String? _obligatorio(String? valor) =>
      (CampoNumero.entero(valor ?? '') ?? 0) <= 0
          ? _t('deu_valor_requerido')
          : null;

  String? _dia(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    final dia = CampoNumero.entero(valor) ?? 0;
    return (dia < 1 || dia > 31) ? _t('deu_dia_invalido') : null;
  }

  @override
  Widget build(BuildContext context) {
    final titulo =
        _t(widget.idCuenta == null ? 'deu_nueva_tarjeta' : 'deu_editar_tarjeta');
    return FutureBuilder<void>(
      future: _carga,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return PantallaBase(
              titulo: titulo, conMenu: false, cuerpo: const EstadoCargando());
        }
        if (snapshot.hasError) {
          return PantallaBase(
            titulo: titulo,
            conMenu: false,
            cuerpo: EstadoError(
              mensaje: _t('cta_error'),
              textoReintentar: _t('cta_reintentar'),
              onReintentar: () => setState(() {
                _carga = _model.cargarTarjeta(widget.idCuenta!);
              }),
            ),
          );
        }
        return FormularioCatalogo(
          titulo: titulo,
          ayuda: _t('deu_tarjeta_ayuda'),
          mensajeExito: _t('deu_guardada'),
          hayCambios: () => _model.hayCambios,
          onGuardar: () => _model.guardarTarjeta(),
          campos: [
            CampoTexto(
              controller: _model.nombreController,
              etiqueta: _t('deu_nombre_tarjeta'),
              validator: validarTextoObligatorio(_t('form_nombre_requerido')),
            ),
            CampoTexto(
              controller: _model.entidadController,
              etiqueta: _t('cta_entidad'),
              ayuda: _t('form_opcional'),
            ),
            CampoNumero(
              controller: _model.nroController,
              etiqueta: _t('deu_ultimos_digitos'),
              ayuda: _t('form_opcional'),
            ),
            CampoNumero(
              controller: _model.montoController,
              etiqueta: _t('deu_cupo'),
              prefijo: '\$ ',
              validator: _obligatorio,
            ),
            CampoNumero(
              controller: _model.tasaController,
              etiqueta: _t('deu_tasa'),
              ayuda: _t('deu_tasa_ayuda'),
              sufijo: '% E.M.',
              decimal: true,
            ),
            CampoNumero(
              controller: _model.cuotaManejoController,
              etiqueta: _t('deu_cuota_manejo'),
              ayuda: _t('deu_cuota_manejo_ayuda'),
              prefijo: '\$ ',
            ),
            CampoNumero(
              controller: _model.diaCorteController,
              etiqueta: _t('deu_dia_corte'),
              validator: _dia,
            ),
            CampoNumero(
              controller: _model.diaPagoController,
              etiqueta: _t('deu_dia_pago'),
              validator: _dia,
            ),
          ],
        );
      },
    );
  }
}
