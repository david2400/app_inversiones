import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

export 'package:inversiones/page/movimientos/tipoTransaccion/states/admin_transaccion_page_state.dart';
import 'package:inversiones/page/movimientos/tipoTransaccion/states/admin_transaccion_page_state.dart';

/// Alta o edición de un tipo de transacción. Con [idTipoTransaccion] edita
/// ese tipo; su naturaleza queda fija si es del sistema o tiene movimientos.
class AdminTipoTransaccionPage extends StatefulWidget {
  final int? idTipoTransaccion;

  const AdminTipoTransaccionPage({super.key, this.idTipoTransaccion});

  @override
  State<AdminTipoTransaccionPage> createState() =>
      _AdminTipoTransaccionPageState();
}

class _AdminTipoTransaccionPageState extends State<AdminTipoTransaccionPage> {
  late AdminTipoTransaccionPageState _model;

  /// Cambia al terminar de cargar para reconstruir el desplegable.
  int _version = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminTipoTransaccionPageState());
    if (widget.idTipoTransaccion != null) _cargar(widget.idTipoTransaccion!);
  }

  Future<void> _cargar(int id) async {
    try {
      await _model.cargar(id);
      if (!mounted) return;
      setState(() {
        _version++;
      });
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    String t(String clave) => textos.getText(clave);
    final editando = widget.idTipoTransaccion != null;
    final tipo = _model.tipoEditado;
    final ayudaNaturaleza = tipo == null
        ? t('atrx_tipo_fuente_ayuda')
        : tipo.esSistema
            ? t('atrx_naturaleza_sistema')
            : tipo.cantidadMovimientos > 0
                ? t('atrx_naturaleza_en_uso')
                : t('atrx_tipo_fuente_ayuda');
    return FormularioCatalogo(
      titulo: t(editando ? 'atrx_editar' : 'atrx_titulo'),
      ayuda: t('atrx_ayuda'),
      mensajeExito: t('atrx_guardado'),
      hayCambios: _model.hayCambios,
      onGuardar: () => _model.guardar(),
      campos: [
        CampoTexto(
          controller: _model.nombreController,
          focusNode: _model.nombreFocus,
          etiqueta: t('form_nombre'),
          validator: validarTextoObligatorio(t('form_nombre_requerido')),
        ),
        CampoSeleccion<String>(
          key: ValueKey('fuente-$_version'),
          etiqueta: t('atrx_tipo_fuente'),
          ayuda: ayudaNaturaleza,
          valorInicial: _model.tipoFuente,
          habilitado: !_model.naturalezaBloqueada,
          opciones: [
            OpcionSeleccion(TipoFuente.ingreso, t('atrx_fuente_ingreso')),
            OpcionSeleccion(TipoFuente.egreso, t('atrx_fuente_egreso')),
            OpcionSeleccion(
                TipoFuente.transferencia, t('atrx_fuente_transferencia')),
          ],
          onChanged: (valor) => _model.tipoFuente = valor,
          validator:
              validarSeleccionObligatoria<String>(t('form_seleccion_requerida')),
        ),
        CampoTexto(
          controller: _model.descripcionController,
          focusNode: _model.descripcionFocus,
          etiqueta: t('form_descripcion'),
          ayuda: t('form_opcional'),
          maxLineas: 3,
        ),
      ],
    );
  }
}
