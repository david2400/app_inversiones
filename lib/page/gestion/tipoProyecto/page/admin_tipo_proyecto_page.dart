import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/perfil_inversion.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

export 'package:inversiones/page/gestion/tipoProyecto/states/admin_tipo_proyecto_page_state.dart';
import 'package:inversiones/page/gestion/tipoProyecto/states/admin_tipo_proyecto_page_state.dart';

/// Alta o edición de un tipo de proyecto: nombre, descripción y nivel de
/// riesgo. Con [idTipoProyecto] edita ese tipo.
class AdminTipoProyectoPage extends StatefulWidget {
  final int? idTipoProyecto;

  const AdminTipoProyectoPage({super.key, this.idTipoProyecto});

  @override
  State<AdminTipoProyectoPage> createState() => _AdminTipoProyectoPageState();
}

class _AdminTipoProyectoPageState extends State<AdminTipoProyectoPage> {
  /// Valor del desplegable para "sin definir".
  static const _sinDefinir = '';

  late AdminTipoProyectoPageState _model;

  /// Cambia al terminar de cargar para reconstruir los desplegables con el
  /// valor guardado.
  int _version = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminTipoProyectoPageState());
    if (widget.idTipoProyecto != null) _cargar(widget.idTipoProyecto!);
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
    final editando = widget.idTipoProyecto != null;
    final cantidad = _model.tipoEditado?.cantidadProyectos ?? 0;
    return FormularioCatalogo(
      titulo: t(editando ? 'atproy_editar' : 'atproy_titulo'),
      ayuda: editando && cantidad > 0
          ? '${t('atproy_ayuda')} ${t('atproy_en_uso')} $cantidad.'
          : t('atproy_ayuda'),
      mensajeExito: t('atproy_guardado'),
      hayCambios: _model.hayCambios,
      onGuardar: () => _model.guardar(),
      campos: [
        CampoTexto(
          controller: _model.nombreController,
          focusNode: _model.nombreFocus,
          etiqueta: t('form_nombre'),
          validator: validarTextoObligatorio(t('form_nombre_requerido')),
        ),
        CampoTexto(
          controller: _model.descripcionController,
          focusNode: _model.descripcionFocus,
          etiqueta: t('form_descripcion'),
          ayuda: t('form_opcional'),
          maxLineas: 3,
        ),
        CampoSeleccion<String>(
          key: ValueKey('riesgo-$_version'),
          etiqueta: t('atproy_riesgo'),
          ayuda: t('atproy_riesgo_ayuda'),
          valorInicial: _model.riesgo ?? _sinDefinir,
          opciones: [
            OpcionSeleccion(_sinDefinir, t('riesgo_sin_definir')),
            for (final codigo in NivelRiesgo.valores)
              OpcionSeleccion(codigo, t(NivelRiesgo.clave(codigo))),
          ],
          onChanged: (valor) => _model.riesgo =
              (valor == null || valor == _sinDefinir) ? null : valor,
        ),
      ],
    );
  }
}
