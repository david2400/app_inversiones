import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inversiones/page/cuentas/dto/cuenta_dto.dart';
import 'package:inversiones/page/gestion/portafolio/dto/portafolio_dto.dart';
import 'package:inversiones/page/gestion/portafolio/states/aporte_state.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

/// Abre el diálogo para aportar dinero a [portafolio]. Devuelve `true` si
/// el aporte quedó registrado (y ya mostró el mensaje de confirmación).
Future<bool> mostrarDialogoAporte(
    BuildContext context, PortafolioDto portafolio) async {
  final registrado = await showDialog<bool>(
    context: context,
    builder: (_) => DialogoAporte(portafolio: portafolio),
  );
  if (registrado == true && context.mounted) {
    mostrarMensaje(
        context, FFLocalizations.of(context).getText('trx_aporte_hecho'));
  }
  return registrado == true;
}

/// Pide valor y nota del aporte y muestra de qué cuenta sale. Es dueño de
/// sus controladores y guarda antes de cerrarse.
class DialogoAporte extends StatefulWidget {
  final PortafolioDto portafolio;
  final AporteState? state;

  const DialogoAporte({super.key, required this.portafolio, this.state});

  @override
  State<DialogoAporte> createState() => _DialogoAporteState();
}

class _DialogoAporteState extends State<DialogoAporte> {
  late final AporteState _state = widget.state ?? AporteState();
  final _valor = TextEditingController();
  final _descripcion = TextEditingController();
  late final Future<CuentaDto> _origen = _state.cuentaOrigen(widget.portafolio);
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _valor.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  Future<void> _guardar() async {
    if (_guardando) return;
    final valor = int.tryParse(_valor.text.trim()) ?? 0;
    if (valor <= 0) {
      setState(() {
        _error = _t('trx_valor_requerido');
      });
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await _state.registrar(widget.portafolio.idPortafolio!, valor,
          descripcion: _descripcion.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final sinCuenta = AporteState.saleDeEfectivo(widget.portafolio);
    return AlertDialog(
      title: Text('${_t('trx_aportar')} · ${widget.portafolio.nombre}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<CuentaDto>(
              future: _origen,
              builder: (context, snapshot) => Row(
                children: [
                  Icon(Icons.north_east_rounded,
                      size: 18, color: tema.secondaryText),
                  const SizedBox(width: Espacio.s),
                  Expanded(
                    child: Text(
                      '${_t('apo_sale_de')} '
                      '${snapshot.data?.nombre ?? '…'}',
                      style: tema.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Espacio.xs),
            Text(
              _t(sinCuenta ? 'apo_ayuda_efectivo' : 'apo_ayuda_cuenta'),
              style: tema.bodySmall.copyWith(color: tema.secondaryText),
            ),
            const SizedBox(height: Espacio.m),
            TextField(
              controller: _valor,
              autofocus: true,
              enabled: !_guardando,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: _t('trx_valor'),
                prefixText: '\$ ',
                errorText: _error,
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: Espacio.m),
            TextField(
              controller: _descripcion,
              enabled: !_guardando,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _guardar(),
              decoration: InputDecoration(
                labelText: _t('form_descripcion'),
                helperText: _t('form_opcional'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: Text(_t('mov_cancelar')),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_t('trx_registrar_btn')),
        ),
      ],
    );
  }
}
