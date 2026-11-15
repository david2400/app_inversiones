import 'package:flutter/material.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/formulario_catalogo.dart';

export 'package:inversiones/page/motivos/states/admin_motivos_page_state.dart';
import 'package:inversiones/page/motivos/states/admin_motivos_page_state.dart';

/// Alta o edición de un motivo: por qué entra o sale el dinero. Con
/// [idMotivo] edita ese motivo.
class AdminMotivosPage extends StatefulWidget {
  final int? idMotivo;

  const AdminMotivosPage({super.key, this.idMotivo});

  @override
  State<AdminMotivosPage> createState() => _AdminMotivosPageState();
}

class _AdminMotivosPageState extends State<AdminMotivosPage> {
  /// Valor del desplegable para "ingreso y gasto".
  static const _ambos = '';

  late AdminMotivosPageState _model;

  /// Cambia al terminar de cargar para reconstruir el desplegable.
  int _version = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminMotivosPageState());
    if (widget.idMotivo != null) _cargar(widget.idMotivo!);
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
    return FormularioCatalogo(
      titulo: t(widget.idMotivo != null ? 'amot_editar' : 'amot_titulo'),
      ayuda: t('amot_ayuda'),
      mensajeExito: t('amot_guardado'),
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
          key: ValueKey('naturaleza-$_version'),
          etiqueta: t('amot_naturaleza'),
          ayuda: t('amot_naturaleza_ayuda'),
          valorInicial: _model.naturaleza ?? _ambos,
          opciones: [
            OpcionSeleccion(_ambos, t('amot_ambos')),
            OpcionSeleccion(TipoFuente.ingreso, t('amot_ingreso')),
            OpcionSeleccion(TipoFuente.egreso, t('amot_gasto')),
          ],
          onChanged: (valor) => _model.naturaleza =
              (valor == null || valor == _ambos) ? null : valor,
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
