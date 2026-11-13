// Patrón común de los formularios de alta de catálogos (motivos, tipos de
// transacción, proyectos, tipos de proyecto, frecuencias de pago).
// Resuelve en un solo lugar: estructura de pantalla, validación, botón de
// guardar con estado de carga (sin doble envío), mensaje de resultado y
// confirmación antes de descartar datos escritos.
import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

/// Validador de texto obligatorio (ignora espacios en blanco).
FormFieldValidator<String> validarTextoObligatorio(String mensaje) =>
    (valor) => (valor == null || valor.trim().isEmpty) ? mensaje : null;

/// Validador de selección obligatoria.
FormFieldValidator<T> validarSeleccionObligatoria<T>(String mensaje) =>
    (valor) => valor == null ? mensaje : null;

/// Pantalla de formulario de catálogo.
///
/// [onGuardar] ejecuta el guardado y lanza una excepción si falla. Al
/// terminar bien se muestra [mensajeExito] y se cierra la pantalla
/// devolviendo `true`, como esperan las pantallas de listado.
class FormularioCatalogo extends StatefulWidget {
  final String titulo;
  final String? ayuda;
  final List<Widget> campos;
  final Future<void> Function() onGuardar;
  final String mensajeExito;

  /// Indica si el usuario escribió algo; si es así, salir pide confirmación.
  final bool Function() hayCambios;

  const FormularioCatalogo({
    super.key,
    required this.titulo,
    required this.campos,
    required this.onGuardar,
    required this.mensajeExito,
    required this.hayCambios,
    this.ayuda,
  });

  @override
  State<FormularioCatalogo> createState() => _FormularioCatalogoState();
}

class _FormularioCatalogoState extends State<FormularioCatalogo> {
  final _claveFormulario = GlobalKey<FormState>();
  bool _guardando = false;
  AutovalidateMode _modoValidacion = AutovalidateMode.disabled;

  Future<void> _guardar() async {
    if (_guardando) return;
    FocusScope.of(context).unfocus();
    final valido = _claveFormulario.currentState?.validate() ?? false;
    if (!valido) {
      // Tras el primer intento fallido, los errores se actualizan al escribir.
      setState(() => _modoValidacion = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() => _guardando = true);
    try {
      await widget.onGuardar();
      if (!mounted) return;
      mostrarMensaje(context, widget.mensajeExito);
      // Se mantiene `_guardando` en true mientras la pantalla se cierra.
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      mostrarMensaje(context, e);
    }
  }

  Future<void> _salir() async {
    if (_guardando) return;
    if (widget.hayCambios()) {
      final textos = FFLocalizations.of(context);
      final descartar = await confirmarAccion(
        context,
        titulo: textos.getText('form_descartar_titulo'),
        mensaje: textos.getText('form_descartar_mensaje'),
        textoConfirmar: textos.getText('form_descartar'),
        textoCancelar: textos.getText('form_seguir_editando'),
        destructiva: true,
      );
      if (!mounted) return;
      if (!descartar) return;
    }
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, resultado) {
        if (!didPop) _salir();
      },
      child: PantallaBase(
        titulo: widget.titulo,
        conMenu: false,
        cuerpo: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _claveFormulario,
            autovalidateMode: _modoValidacion,
            child: ListView(
              padding: Espacio.pantalla,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                if (widget.ayuda != null) ...[
                  Text(
                    widget.ayuda!,
                    style: tema.bodyMedium.copyWith(color: tema.secondaryText),
                  ),
                  const SizedBox(height: Espacio.l),
                ],
                Tarjeta(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < widget.campos.length; i++) ...[
                        if (i > 0) const SizedBox(height: Espacio.l),
                        widget.campos[i],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Espacio.xl),
                BotonPrincipal(
                  texto: textos.getText('form_guardar'),
                  icono: Icons.save_rounded,
                  cargando: _guardando,
                  onPressed: _guardar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Campo de texto con etiqueta; el estilo sale de `inputDecorationTheme`.
class CampoTexto extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String etiqueta;
  final String? ayuda;
  final FormFieldValidator<String>? validator;
  final int minLineas;
  final int maxLineas;
  final TextInputAction? accionTeclado;

  const CampoTexto({
    super.key,
    required this.controller,
    required this.etiqueta,
    this.focusNode,
    this.ayuda,
    this.validator,
    this.minLineas = 1,
    this.maxLineas = 1,
    this.accionTeclado,
  });

  @override
  Widget build(BuildContext context) {
    final multilinea = maxLineas > 1;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      minLines: minLineas,
      maxLines: maxLineas,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: multilinea ? TextInputType.multiline : TextInputType.text,
      textInputAction: accionTeclado ??
          (multilinea ? TextInputAction.newline : TextInputAction.next),
      style: FlutterFlowTheme.of(context).bodyMedium,
      decoration: InputDecoration(
        labelText: etiqueta,
        helperText: ayuda,
        alignLabelWithHint: multilinea,
      ),
    );
  }
}

/// Opción de un [CampoSeleccion].
class OpcionSeleccion<T> {
  final T valor;
  final String texto;

  const OpcionSeleccion(this.valor, this.texto);
}

/// Lista desplegable con etiqueta y validación, con el estilo del tema.
class CampoSeleccion<T> extends StatelessWidget {
  final String etiqueta;
  final List<OpcionSeleccion<T>> opciones;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;
  final String? ayuda;

  /// Valor seleccionado al abrir (por ejemplo, al editar).
  final T? valorInicial;

  const CampoSeleccion({
    super.key,
    required this.etiqueta,
    required this.opciones,
    required this.onChanged,
    this.validator,
    this.ayuda,
    this.valorInicial,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return DropdownButtonFormField<T>(
      initialValue: valorInicial,
      items: [
        for (final opcion in opciones)
          DropdownMenuItem<T>(
            value: opcion.valor,
            child: Text(opcion.texto, style: tema.bodyMedium),
          ),
      ],
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      dropdownColor: tema.secondaryBackground,
      borderRadius: BorderRadius.circular(Radios.m),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
    );
  }
}
