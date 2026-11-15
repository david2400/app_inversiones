import 'package:flutter/material.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/cuentas/page/campo_numero.dart';
import 'package:inversiones/page/cuentas/states/admin_deuda_page_state.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

/// Registrar un préstamo: condiciones y cuenta donde llegó el desembolso.
class AdminPrestamoPage extends StatefulWidget {
  const AdminPrestamoPage({super.key});

  @override
  State<AdminPrestamoPage> createState() => _AdminPrestamoPageState();
}

class _AdminPrestamoPageState extends State<AdminPrestamoPage> {
  late AdminDeudaPageState _model;
  late Future<List<CuentaDto>> _cuentas;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminDeudaPageState());
    _cuentas = _model.cuentasDeActivo();
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

  void _refrescarCuota(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return FutureBuilder<List<CuentaDto>>(
      future: _cuentas,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return PantallaBase(
              titulo: _t('deu_nuevo_prestamo'),
              conMenu: false,
              cuerpo: const EstadoCargando());
        }
        final cuentas = snapshot.data ?? const <CuentaDto>[];
        final cuota = _model.cuotaEstimada;
        return FormularioCatalogo(
          titulo: _t('deu_nuevo_prestamo'),
          ayuda: _t('deu_prestamo_ayuda'),
          mensajeExito: _t('deu_guardado_prestamo'),
          hayCambios: () => _model.hayCambios,
          onGuardar: () => _model.crearPrestamo(),
          campos: [
            CampoTexto(
              controller: _model.nombreController,
              etiqueta: _t('deu_nombre_prestamo'),
              validator: validarTextoObligatorio(_t('form_nombre_requerido')),
            ),
            CampoTexto(
              controller: _model.entidadController,
              etiqueta: _t('cta_entidad'),
              ayuda: _t('form_opcional'),
            ),
            CampoNumero(
              controller: _model.montoController,
              etiqueta: _t('deu_monto'),
              prefijo: '\$ ',
              validator: _obligatorio,
              onChanged: _refrescarCuota,
            ),
            CampoNumero(
              controller: _model.tasaController,
              etiqueta: _t('deu_tasa'),
              ayuda: _t('deu_tasa_ayuda'),
              sufijo: '% E.M.',
              decimal: true,
              onChanged: _refrescarCuota,
            ),
            CampoNumero(
              controller: _model.plazoController,
              etiqueta: _t('deu_plazo'),
              sufijo: _t('deu_meses'),
              validator: _obligatorio,
              onChanged: _refrescarCuota,
            ),
            CampoNumero(
              controller: _model.diaPagoController,
              etiqueta: _t('deu_dia_pago'),
              ayuda: _t('form_opcional'),
            ),
            CampoSeleccion<int>(
              etiqueta: _t('deu_cuenta_desembolso'),
              ayuda: _t('deu_cuenta_desembolso_ayuda'),
              opciones: [
                for (final c in cuentas)
                  OpcionSeleccion(c.idCuenta!, c.nombre),
              ],
              validator: validarSeleccionObligatoria(_t('deu_cuenta_requerida')),
              onChanged: (valor) => _model.idCuentaDesembolso = valor,
            ),
            if (cuota > 0)
              Text(
                '${_t('deu_cuota_estimada')}: ${FormatoMoneda.cop(cuota)}',
                style: tema.titleSmall,
              ),
          ],
        );
      },
    );
  }
}
