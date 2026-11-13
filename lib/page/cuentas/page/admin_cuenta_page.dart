import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inversiones/domain/models/tipo_cuenta.dart';
import 'package:inversiones/page/cuentas/page/tipo_cuenta_ui.dart';
import 'package:inversiones/page/cuentas/states/admin_cuenta_page_state.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

/// Crear o editar una cuenta. Sin [idCuenta] crea una nueva.
class AdminCuentaPage extends StatefulWidget {
  final int? idCuenta;

  const AdminCuentaPage({super.key, this.idCuenta});

  @override
  State<AdminCuentaPage> createState() => _AdminCuentaPageState();
}

class _AdminCuentaPageState extends State<AdminCuentaPage> {
  late AdminCuentaPageState _model;
  late Future<void> _carga;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminCuentaPageState());
    _carga = widget.idCuenta == null
        ? Future.value()
        : _model.cargar(widget.idCuenta!);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  bool get _esNueva => widget.idCuenta == null;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _carga,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return PantallaBase(
              titulo: _t('cta_editar_titulo'),
              conMenu: false,
              cuerpo: const EstadoCargando());
        }
        if (snapshot.hasError) {
          return PantallaBase(
            titulo: _t('cta_editar_titulo'),
            conMenu: false,
            cuerpo: EstadoError(
              mensaje: _t('cta_error'),
              textoReintentar: _t('cta_reintentar'),
              onReintentar: () => setState(() {
                _carga = _model.cargar(widget.idCuenta!);
              }),
            ),
          );
        }
        return _formulario(context);
      },
    );
  }

  Widget _formulario(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final esEfectivo = _model.tipoCuenta == TipoCuenta.efectivo;
    return FormularioCatalogo(
      titulo: _t(_esNueva ? 'cta_nueva' : 'cta_editar_titulo'),
      ayuda: _t('cta_ayuda'),
      mensajeExito: _t('cta_guardada'),
      hayCambios: () => _model.hayCambios,
      onGuardar: () => _model.guardar(),
      campos: [
        CampoTexto(
          controller: _model.nombreController,
          etiqueta: _t('cta_nombre'),
          validator:
              validarTextoObligatorio(_t('form_nombre_requerido')),
        ),
        CampoSeleccion<String>(
          etiqueta: _t('cta_tipo'),
          valorInicial: _model.tipoCuenta,
          opciones: [
            for (final tipo in TipoCuenta.deActivo)
              OpcionSeleccion(tipo, TipoCuentaUi.nombre(context, tipo)),
          ],
          validator: validarSeleccionObligatoria(_t('cta_tipo_requerido')),
          onChanged: (valor) => setState(() => _model.tipoCuenta = valor),
        ),
        CampoTexto(
          controller: _model.entidadController,
          etiqueta: _t('cta_entidad'),
          ayuda: _t('form_opcional'),
        ),
        CampoTexto(
          controller: _model.nroCuentaController,
          etiqueta: _t('cta_nro'),
          ayuda: _t('form_opcional'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_t('cta_exenta'), style: tema.bodyLarge),
          subtitle: Text(
            _t(esEfectivo ? 'cta_efectivo_sin_gmf' : 'cta_exenta_ayuda'),
            style: tema.bodySmall.copyWith(color: tema.secondaryText),
          ),
          value: esEfectivo || _model.exenta,
          onChanged: esEfectivo
              ? null
              : (valor) => setState(() => _model.exenta = valor),
        ),
        if (_esNueva)
          TextFormField(
            controller: _model.saldoInicialController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: tema.bodyMedium,
            decoration: InputDecoration(
              labelText: _t('cta_saldo_inicial'),
              helperText: _t('cta_saldo_inicial_ayuda'),
              prefixText: '\$ ',
            ),
          ),
        CampoTexto(
          controller: _model.descripcionController,
          etiqueta: _t('form_descripcion'),
          ayuda: _t('form_opcional'),
          maxLineas: 3,
        ),
      ],
    );
  }
}
