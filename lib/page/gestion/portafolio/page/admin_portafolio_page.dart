import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inversiones/page/frecuenciaPago/dto/frecuencia_pago_dto.dart';
import 'package:inversiones/page/frecuenciaPago/states/frecuencia_pago_page_state.dart';
import 'package:inversiones/page/gestion/portafolio/states/admin_portafolio_page_state.dart';
import 'package:inversiones/page/gestion/tipoProyecto/dto/tipo_proyecto_dto.dart';
import 'package:inversiones/ui/models/drop_down_button_model.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

export 'package:inversiones/page/gestion/tipoProyecto/states/tipo_proyecto_page_state.dart';
import 'package:inversiones/page/gestion/tipoProyecto/states/tipo_proyecto_page_state.dart';

/// Formulario de alta de un portafolio (cuenta) dentro de un proyecto.
class AdminPortafolioPage extends StatefulWidget {
  final int idProyecto;

  const AdminPortafolioPage({super.key, required this.idProyecto});

  @override
  State<AdminPortafolioPage> createState() => _AdminPortafolioPageState();
}

class _AdminPortafolioPageState extends State<AdminPortafolioPage> {
  /// Valores "sin selección" que el State espera (igual que antes).
  static const _sinTipoPortafolio = 0;
  static const _sinFrecuencia = 0;
  static const _sinTipoRenta = '';

  /// Códigos de tipo de renta que guarda el portafolio.
  static const _rentaFija = 'F';
  static const _rentaVariable = 'V';

  static const _lineasDescripcion = 4;

  late AdminPortafolioPageState _model;

  final _formKey = GlobalKey<FormState>();

  late TipoProyectoPageState _modelTipoProyecto;
  late FrecuenciaPagoPageState _modelFrecuenciaPago;

  List<DropDownButtonModel> _listaFrecuenciaPago = [];
  List<DropDownButtonModel> _listaTipoPortafolio = [];
  List<DropDownButtonModel> _listaCuentas = [];

  bool _cargandoCatalogos = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    _model = createModel(context, () => AdminPortafolioPageState());
    _modelTipoProyecto = createModel(context, () => TipoProyectoPageState());
    _modelFrecuenciaPago =
        createModel(context, () => FrecuenciaPagoPageState());

    _model.nombreFocus ??= FocusNode();
    _model.nombreController ??= TextEditingController();

    _model.nroCuentaFocus ??= FocusNode();
    _model.nroCuentaController ??= TextEditingController();

    _model.descripcionFocus ??= FocusNode();
    _model.descripcionController ??= TextEditingController();

    _model.interesFocus ??= FocusNode();
    _model.interesController ??= TextEditingController();

    _model.tipoPortafolioId ??= _sinTipoPortafolio;
    _model.frecuenciaPagoId ??= _sinFrecuencia;
    _model.tipoRenta ??= _sinTipoRenta;
    _model.exentaImpuesto ??= false;

    _initParams();
  }

  Future<void> _initParams() async {
    try {
      final lista = await listarFrecuenciaPago();
      final listaTipoProyecto = await listarTipoProyecto();
      final cuentas = await _model.listarCuentas();
      if (!mounted) return;
      setState(() {
        _listaFrecuenciaPago = lista;
        _listaTipoPortafolio = listaTipoProyecto;
        _listaCuentas = [
          for (final cuenta in cuentas)
            DropDownButtonModel(id: cuenta.idCuenta, value: cuenta.nombre),
        ];
        _cargandoCatalogos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoCatalogos = false);
      mostrarMensaje(
          context, FFLocalizations.of(context).getText('aport_error_catalogos'));
    }
  }

  Future<List<DropDownButtonModel>> listarFrecuenciaPago() async {
    List<FrecuenciaPagoDto> list =
        await _modelFrecuenciaPago.listarFrecuenciaPago();

    return [
      for (final element in list)
        DropDownButtonModel(
            id: element.idFrecuenciaPago,
            value: '${element.tiempo} ${element.formato}'),
    ];
  }

  Future<List<DropDownButtonModel>> listarTipoProyecto() async {
    List<TipoProyectoDto> list = await _modelTipoProyecto.listarTipoProyectos();

    return [
      for (final element in list)
        DropDownButtonModel(id: element.idTipoProyecto, value: element.nombre),
    ];
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
      await _model.insertPortafolio();
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
      titulo: textos.getText('aport_titulo'),
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
            const SizedBox(height: Espacio.l),
            TextFormField(
              controller: _model.saldoInicialController,
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

            // Condiciones.
            EncabezadoSeccion(
              titulo: textos.getText('aport_seccion_condiciones'),
              subtitulo: textos.getText('aport_seccion_condiciones_ayuda'),
            ),
            _Desplegable<int>(
              etiqueta: textos.getText('aport_tipo_cuenta'),
              ayuda: textos.getText('aport_seleccione'),
              valor: _valorValido<int>(
                _model.tipoPortafolioId,
                _idsDe<int>(_listaTipoPortafolio),
              ),
              opciones: _listaTipoPortafolio,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _model.tipoPortafolioId = val);
                }
              },
            ),
            const SizedBox(height: Espacio.l),
            _Desplegable<int>(
              etiqueta: textos.getText('aport_frecuencia'),
              ayuda: textos.getText('aport_seleccione'),
              valor: _valorValido<int>(
                _model.frecuenciaPagoId,
                _idsDe<int>(_listaFrecuenciaPago),
              ),
              opciones: _listaFrecuenciaPago,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _model.frecuenciaPagoId = val);
                }
              },
            ),
            const SizedBox(height: Espacio.l),
            TextFormField(
              controller: _model.interesController,
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
