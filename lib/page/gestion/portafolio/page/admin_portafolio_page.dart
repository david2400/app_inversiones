import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inversiones/domain/models/periodicidad.dart';
import 'package:inversiones/page/gestion/portafolio/states/admin_portafolio_page_state.dart';
import 'package:inversiones/ui/models/drop_down_button_model.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';


/// Formulario de alta de un portafolio dentro de un proyecto, o de edición
/// de un portafolio existente cuando llega [idPortafolio].
class AdminPortafolioPage extends StatefulWidget {
  final int? idProyecto;
  final int? idPortafolio;

  const AdminPortafolioPage({super.key, this.idProyecto, this.idPortafolio});

  @override
  State<AdminPortafolioPage> createState() => _AdminPortafolioPageState();
}

class _AdminPortafolioPageState extends State<AdminPortafolioPage> {
  /// Valores "sin selección" que el State espera (igual que antes).
  static const _sinTipoRenta = '';

  /// Códigos de tipo de renta que guarda el portafolio.
  static const _rentaFija = 'F';
  static const _rentaVariable = 'V';

  static const _lineasDescripcion = 4;

  late AdminPortafolioPageState _model;

  final _formKey = GlobalKey<FormState>();


  List<DropDownButtonModel> _listaCuentas = [];

  bool _cargandoCatalogos = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    _model = createModel(context, () => AdminPortafolioPageState());

    _model.nombreFocus ??= FocusNode();
    _model.nombreController ??= TextEditingController();

    _model.nroCuentaFocus ??= FocusNode();
    _model.nroCuentaController ??= TextEditingController();

    _model.descripcionFocus ??= FocusNode();
    _model.descripcionController ??= TextEditingController();

    _model.interesFocus ??= FocusNode();
    _model.interesController ??= TextEditingController();

    _model.tipoRenta ??= _sinTipoRenta;
    _model.exentaImpuesto ??= false;

    _initParams();
  }

  Future<void> _initParams() async {
    try {
      final cuentas = await _model.listarCuentas();
      if (widget.idPortafolio != null) {
        await _model.cargarPortafolio(widget.idPortafolio!);
      }
      if (!mounted) return;
      setState(() {
        _listaCuentas = [
          for (final cuenta in cuentas)
            DropDownButtonModel(id: cuenta.idCuenta, value: cuenta.nombre),
        ];
        _cargandoCatalogos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargandoCatalogos = false;
      });
      mostrarMensaje(
          context,
          _model.editando || widget.idPortafolio == null
              ? FFLocalizations.of(context).getText('aport_error_catalogos')
              : e);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> onSubmitForm() async {
    if (_guardando) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final textos = FFLocalizations.of(context);
    setState(() => _guardando = true);
    try {
      if (widget.idPortafolio != null && !_model.editando) {
        throw Exception('No se pudo cargar el portafolio');
      }
      await _model.guardarPortafolio();
      if (!mounted) return;
      mostrarMensaje(context, textos.getText('aport_guardado'));
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      mostrarMensaje(context, e);
    }
  }

  /// Devuelve [valor] solo si está entre las opciones; si no, `null` (el
  /// desplegable muestra el texto de ayuda en vez de fallar).
  T? _valorValido<T>(T? valor, List<T> opciones) =>
      opciones.contains(valor) ? valor : null;

  /// Ids de las opciones del tipo esperado (descarta ids nulos).
  List<T> _idsDe<T>(List<DropDownButtonModel> opciones) =>
      opciones.map((o) => o.id).whereType<T>().toList();

  static final _formatoFechaVisible = DateFormat('dd/MM/yyyy');

  Future<DateTime?> _elegirFecha(DateTime? inicial) => showDatePicker(
        context: context,
        initialDate: inicial ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

  Widget _campoFecha({
    required String etiqueta,
    required DateTime? valor,
    required ValueChanged<DateTime?> alCambiar,
  }) {
    final tema = FlutterFlowTheme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(Radios.m),
      onTap: () async {
        final elegida = await _elegirFecha(valor);
        if (elegida != null) alCambiar(elegida);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          suffixIcon: valor == null
              ? const Icon(Icons.event_rounded)
              : IconButton(
                  tooltip: FFLocalizations.of(context).getText('aport_quitar_fecha'),
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => alCambiar(null),
                ),
        ),
        child: Text(
          valor == null ? '—' : _formatoFechaVisible.format(valor),
          style: tema.bodyMedium,
        ),
      ),
    );
  }

  List<Widget> _seccionPlazo(FlutterFlowTheme tema, FFLocalizations textos) {
    final capital = _model.editando
        ? _model.saldoActual
        : int.tryParse(_model.saldoInicialController.text.trim()) ?? 0;
    final estimado = _model.rendimientoEstimado(capital);
    return [
      EncabezadoSeccion(
        titulo: textos.getText('aport_seccion_plazo'),
        subtitulo: textos.getText('aport_seccion_plazo_ayuda'),
      ),
      Row(
        children: [
          Expanded(
            child: _campoFecha(
              etiqueta: textos.getText('aport_fecha_apertura'),
              valor: _model.fechaApertura,
              alCambiar: (fecha) => setState(() {
                _model.fechaApertura = fecha;
              }),
            ),
          ),
          const SizedBox(width: Espacio.m),
          Expanded(
            child: _campoFecha(
              etiqueta: textos.getText('aport_fecha_vencimiento'),
              valor: _model.fechaVencimiento,
              alCambiar: (fecha) => setState(() {
                _model.fechaVencimiento = fecha;
              }),
            ),
          ),
        ],
      ),
      if (estimado != null) ...[
        const SizedBox(height: Espacio.s),
        Text(
          '${textos.getText('aport_rendimiento_estimado')} '
          '${FormatoMoneda.cop(estimado)}',
          style: tema.bodySmall.copyWith(color: tema.secondaryText),
        ),
      ],
    ];
  }

  /// Opciones de periodo con su nombre traducido.
  List<DropDownButtonModel> _periodos(
          FFLocalizations textos, List<int> periodos) =>
      [
        for (final meses in periodos)
          DropDownButtonModel(
              id: meses, value: textos.getText(Periodicidad.clave(meses))),
      ];

  /// Nombre de la cuenta de donde saldrán los aportes.
  String _nombreCuentaAportes(FFLocalizations textos) {
    final id = _model.cuentaAportesId;
    for (final cuenta in _listaCuentas) {
      if (cuenta.id == id) return cuenta.value;
    }
    return textos.getText('aport_sin_cuenta');
  }

  List<Widget> _seccionAporteProgramado(
      FlutterFlowTheme tema, FFLocalizations textos) {
    final esPrincipal = _model.portafolioEditado?.esPrincipal ?? false;
    if (esPrincipal) return const [];
    final dia = int.tryParse(_model.aporteDiaController.text.trim());
    return [
      EncabezadoSeccion(
        titulo: textos.getText('aport_seccion_programado'),
        subtitulo: textos.getText('aport_seccion_programado_ayuda'),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(textos.getText('aport_programar'), style: tema.bodyMedium),
        value: _model.programarAporte,
        onChanged: (valor) => setState(() {
          _model.programarAporte = valor;
        }),
      ),
      if (_model.programarAporte) ...[
        const SizedBox(height: Espacio.s),
        TextFormField(
          controller: _model.aporteValorController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: textos.getText('aport_valor_aporte'),
            prefixText: '\$ ',
          ),
          style: tema.bodyMedium,
          validator: (_) =>
              (int.tryParse(_model.aporteValorController.text.trim()) ?? 0) > 0
                  ? null
                  : textos.getText('trx_valor_requerido'),
        ),
        const SizedBox(height: Espacio.l),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _Desplegable<int>(
                etiqueta: textos.getText('aport_cada'),
                ayuda: textos.getText('aport_seleccione'),
                valor: _model.aportePeriodo,
                opciones: _periodos(textos, Periodicidad.repetibles),
                onChanged: (val) => setState(() {
                  _model.aportePeriodo = val ?? Periodicidad.mensual;
                }),
              ),
            ),
            const SizedBox(width: Espacio.m),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _model.aporteDiaController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: InputDecoration(
                  labelText: textos.getText('aport_dia'),
                ),
                style: tema.bodyMedium,
                onChanged: (_) => setState(() {}),
                validator: (_) {
                  final d =
                      int.tryParse(_model.aporteDiaController.text.trim()) ?? 0;
                  return d >= 1 && d <= 31
                      ? null
                      : textos.getText('deu_dia_invalido');
                },
              ),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(textos.getText('aport_automatico'),
              style: tema.bodyMedium),
          subtitle: Text(
            textos.getText(_model.aporteAutomatico
                ? 'aport_automatico_ayuda'
                : 'aport_manual_ayuda'),
            style: tema.bodySmall.copyWith(color: tema.secondaryText),
          ),
          value: _model.aporteAutomatico,
          onChanged: (valor) => setState(() {
            _model.aporteAutomatico = valor;
          }),
        ),
        Tarjeta(
          child: Row(
            children: [
              Icon(Icons.event_repeat_rounded, color: tema.primary),
              const SizedBox(width: Espacio.m),
              Expanded(
                child: Text(
                  '${textos.getText('apo_sale_de')} ${_nombreCuentaAportes(textos)}'
                  ' · ${textos.getText(Periodicidad.clave(_model.aportePeriodo))}'
                  '${dia == null ? '' : ' · ${textos.getText('aport_el_dia')} $dia'}',
                  style: tema.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    ];
  }

  String? _validarNombre(String? valor) =>
      (valor == null || valor.trim().isEmpty)
          ? FFLocalizations.of(context).getText('aport_nombre_requerido')
          : null;

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);

    final rentas = <DropDownButtonModel>[
      DropDownButtonModel(
          id: _rentaFija, value: textos.getText('aptpkmd01' /* Renta fija */)),
      DropDownButtonModel(
          id: _rentaVariable,
          value: textos.getText('aptpkmd02' /* Renta variable */)),
    ];

    return PantallaBase(
      titulo: textos.getText(
          widget.idPortafolio != null ? 'aport_editar' : 'aport_titulo'),
      conMenu: false,
      cuerpo: Form(
        key: _formKey,
        child: ListView(
          padding: Espacio.pantalla,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            if (_cargandoCatalogos) const LinearProgressIndicator(),

            // Datos de la cuenta.
            EncabezadoSeccion(titulo: textos.getText('aport_seccion_cuenta')),
            TextFormField(
              controller: _model.nombreController,
              focusNode: _model.nombreFocus,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: textos.getText('aport_nombre'),
              ),
              style: tema.bodyMedium,
              validator: _validarNombre,
            ),
            const SizedBox(height: Espacio.l),
            TextFormField(
              controller: _model.nroCuentaController,
              focusNode: _model.nroCuentaFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: textos.getText('aport_nro_cuenta'),
              ),
              style: tema.bodyMedium,
            ),
            if (widget.idPortafolio == null) ...[
            const SizedBox(height: Espacio.l),
            TextFormField(
              controller: _model.saldoInicialController,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: textos.getText('por_saldo_inicial'),
                helperText: textos.getText('por_saldo_inicial_ayuda'),
                helperMaxLines: 2,
                prefixText: '\$ ',
              ),
              style: tema.bodyMedium,
            ),
            ],

            // Condiciones.
            EncabezadoSeccion(
              titulo: textos.getText('aport_seccion_condiciones'),
              subtitulo: textos.getText('aport_seccion_condiciones_ayuda'),
            ),
            _Desplegable<int>(
              etiqueta: textos.getText('aport_paga_rendimientos'),
              ayuda: textos.getText('aport_seleccione'),
              valor: _valorValido<int>(
                _model.periodicidadRendimientos,
                Periodicidad.deRendimientos,
              ),
              opciones: _periodos(textos, Periodicidad.deRendimientos),
              onChanged: (val) => setState(() {
                _model.periodicidadRendimientos = val;
              }),
            ),
            const SizedBox(height: Espacio.l),
            TextFormField(
              controller: _model.interesController,
              onChanged: (_) => setState(() {}),
              focusNode: _model.interesFocus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: textos.getText('aport_interes'),
                suffixText: '%',
              ),
              style: tema.bodyMedium,
            ),
            const SizedBox(height: Espacio.l),
            _Desplegable<String>(
              etiqueta: textos.getText('aport_tipo_renta'),
              ayuda: textos.getText('aport_seleccione'),
              valor: _valorValido<String>(
                _model.tipoRenta,
                _idsDe<String>(rentas),
              ),
              opciones: rentas,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _model.tipoRenta = val);
                }
              },
            ),
            const SizedBox(height: Espacio.s),
            if (!_model.esDeCuenta)
            CheckboxListTile(
              value: _model.exentaImpuesto ?? false,
              onChanged: (nuevo) =>
                  setState(() => _model.exentaImpuesto = nuevo ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(textos.getText('aport_exenta'),
                  style: tema.bodyMedium),
              subtitle: Text(
                textos.getText('aport_exenta_ayuda'),
                style: tema.bodySmall.copyWith(color: tema.secondaryText),
              ),
            ),

            // Plazo (CDT o inversión a término).
            ..._seccionPlazo(tema, textos),

            // Aportes y rendimientos.
            EncabezadoSeccion(
              titulo: textos.getText('aport_seccion_aportes'),
              subtitulo: textos.getText('aport_seccion_aportes_ayuda'),
            ),
            _Desplegable<int>(
              etiqueta: textos.getText('aport_cuenta_aportes'),
              ayuda: textos.getText('aport_sin_cuenta'),
              valor: _valorValido<int>(
                _model.cuentaAportesId,
                _idsDe<int>(_listaCuentas),
              ),
              opciones: _listaCuentas,
              onChanged: (val) => setState(() {
                _model.cuentaAportesId = val;
              }),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(textos.getText('aport_misma_cuenta'),
                  style: tema.bodyMedium),
              subtitle: Text(
                textos.getText('aport_misma_cuenta_ayuda'),
                style: tema.bodySmall.copyWith(color: tema.secondaryText),
              ),
              value: _model.mismaCuentaRendimientos,
              onChanged: (valor) => setState(() {
                _model.mismaCuentaRendimientos = valor;
              }),
            ),
            if (!_model.mismaCuentaRendimientos)
              _Desplegable<int>(
                etiqueta: textos.getText('aport_cuenta_rendimientos'),
                ayuda: textos.getText('aport_sin_cuenta'),
                valor: _valorValido<int>(
                  _model.cuentaRendimientosId,
                  _idsDe<int>(_listaCuentas),
                ),
                opciones: _listaCuentas,
                onChanged: (val) => setState(() {
                  _model.cuentaRendimientosId = val;
                }),
              ),

            // Aporte programado.
            ..._seccionAporteProgramado(tema, textos),

            // Notas.
            EncabezadoSeccion(titulo: textos.getText('aport_seccion_notas')),
            TextFormField(
              controller: _model.descripcionController,
              focusNode: _model.descripcionFocus,
              textCapitalization: TextCapitalization.sentences,
              minLines: 2,
              maxLines: _lineasDescripcion,
              decoration: InputDecoration(
                labelText: textos.getText('aport_descripcion'),
                alignLabelWithHint: true,
              ),
              style: tema.bodyMedium,
            ),
            const SizedBox(height: Espacio.xl),
            BotonPrincipal(
              texto: textos.getText('aport_guardar'),
              icono: Icons.save_rounded,
              cargando: _guardando,
              onPressed: onSubmitForm,
            ),
          ],
        ),
      ),
    );
  }
}

/// Desplegable con etiqueta visible; usa el estilo de campos del tema.
class _Desplegable<T> extends StatelessWidget {
  final String etiqueta;
  final String ayuda;
  final T? valor;
  final List<DropDownButtonModel> opciones;
  final ValueChanged<T?> onChanged;

  const _Desplegable({
    required this.etiqueta,
    required this.ayuda,
    required this.valor,
    required this.opciones,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return DropdownButtonFormField<T>(
      // La clave reconstruye el campo cuando llegan los datos a editar.
      key: ValueKey('$valor-${opciones.length}'),
      initialValue: valor,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      dropdownColor: tema.secondaryBackground,
      decoration: InputDecoration(labelText: etiqueta),
      hint: Text(ayuda,
          style: tema.bodyMedium.copyWith(color: tema.secondaryText)),
      style: tema.bodyMedium,
      items: [
        for (final opcion in opciones)
          if (opcion.id is T && opcion.id != null)
            DropdownMenuItem<T>(
              value: opcion.id as T,
              child: Text(opcion.value,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
      ],
      onChanged: opciones.isEmpty ? null : onChanged,
    );
  }
}
