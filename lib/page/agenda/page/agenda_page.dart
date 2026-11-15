import 'package:flutter/material.dart';
import 'package:inversiones/page/agenda/dto/agenda_dto.dart';
import 'package:inversiones/page/agenda/page/agenda_widgets.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

export 'package:inversiones/page/agenda/states/agenda_page_state.dart';
import 'package:inversiones/page/agenda/states/agenda_page_state.dart';

/// Agenda de los próximos 3 meses agrupada por día, con el saldo
/// disponible proyectado al cierre de cada día.
class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late AgendaPageState _model;
  late Future<AgendaDto> _agenda;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgendaPageState());
    _agenda = _model.cargar();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _agenda = _model.cargar();
    });
  }

  /// Cada evento lleva a donde se gestiona.
  Future<void> _abrir(EventoAgendaDto evento) async {
    switch (evento.tipo) {
      case TipoEventoAgenda.ingreso:
      case TipoEventoAgenda.gasto:
      case TipoEventoAgenda.transferencia:
        await _registrar(evento);
      case TipoEventoAgenda.deuda:
        await context.pushNamed('deuda_detalle', queryParameters: {
          'idCuenta': serializeParam(evento.idCuenta, ParamType.int),
        }.withoutNulls);
        _recargar();
      case TipoEventoAgenda.vencimiento:
        await context.pushNamed('transactions', queryParameters: {
          'idPortafolio': serializeParam(evento.idPortafolio, ParamType.int),
        }.withoutNulls);
        _recargar();
      case TipoEventoAgenda.meta:
        context.goNamed('metas');
    }
  }

  /// Solo se registran los fijos del mes actual (o atrasados); los de
  /// meses siguientes se registran cuando llegue su mes.
  Future<void> _registrar(EventoAgendaDto evento) async {
    final hoy = DateTime.now();
    final esteMes =
        evento.fecha.year == hoy.year && evento.fecha.month == hoy.month;
    if (!esteMes && !evento.atrasado) {
      mostrarMensaje(context, _t('agenda_registrar_despues'));
      return;
    }
    final confirmado = await confirmarAccion(
      context,
      titulo: _t('agenda_registrar_titulo'),
      mensaje:
          '${evento.titulo} · ${FormatoMoneda.cop(evento.valor)}',
      textoConfirmar: _t('agenda_registrar'),
      textoCancelar: _t('mov_cancelar'),
    );
    if (!confirmado) return;
    try {
      await _model.registrarFijo(evento);
      if (mounted) mostrarMensaje(context, _t('agenda_registrado'));
    } catch (e) {
      if (mounted) mostrarMensaje(context, e);
    }
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return PantallaBase(
      titulo: _t('agenda_titulo'),
      cuerpo: ContenidoAsincrono<AgendaDto>(
        future: _agenda,
        mensajeError: _t('agenda_error'),
        textoReintentar: _t('tproy_reintentar'),
        onReintentar: _recargar,
        builder: (context, agenda) => RefreshIndicator(
          onRefresh: () async => _recargar(),
          child: ListView(
            padding: Espacio.pantalla,
            children: [
              ResumenFlujo(agenda: agenda),
              const SizedBox(height: Espacio.s),
              Text(_t('agenda_ayuda'),
                  style: tema.bodySmall.copyWith(color: tema.secondaryText)),
              if (agenda.dias.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: Espacio.xl),
                  child: EstadoVacio(
                    icono: Icons.event_note_outlined,
                    mensaje: _t('agenda_vacia'),
                  ),
                ),
              for (final dia in agenda.dias) ...[
                EncabezadoSeccion(
                  titulo: textoDiaAgenda(context, dia.fecha, agenda.desde),
                  accion: Text(
                    '${_t('agenda_saldo')} ${FormatoMoneda.cop(dia.saldo)}',
                    style: tema.bodySmall.copyWith(
                        color:
                            dia.saldo < 0 ? tema.error : tema.secondaryText),
                  ),
                ),
                Tarjeta(
                  padding: const EdgeInsets.symmetric(horizontal: Espacio.l),
                  child: Column(children: [
                    for (final e in dia.eventos)
                      FilaEventoAgenda(evento: e, onTap: () => _abrir(e)),
                  ]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
