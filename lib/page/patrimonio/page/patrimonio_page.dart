import 'package:flutter/material.dart';
import 'package:inversiones/page/home/dto/patrimonio_dto.dart';
import 'package:inversiones/page/patrimonio/page/patrimonio_widgets.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/utils/formato_moneda.dart';
import 'package:inversiones/ui/widgets/componentes.dart';
import 'package:inversiones/ui/widgets/finanzas_widgets.dart';

export 'package:inversiones/page/patrimonio/states/patrimonio_page_state.dart';
import 'package:inversiones/page/patrimonio/states/patrimonio_page_state.dart';

/// Patrimonio neto (lo que tienes menos lo que debes), su evolución y la
/// rentabilidad de tus inversiones por tipo de proyecto y por proyecto.
class PatrimonioPage extends StatefulWidget {
  const PatrimonioPage({super.key});

  @override
  State<PatrimonioPage> createState() => _PatrimonioPageState();
}

class _PatrimonioPageState extends State<PatrimonioPage> {
  late PatrimonioPageState _model;
  late Future<PatrimonioDto> _datos;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PatrimonioPageState());
    _datos = _model.cargar();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  Future<void> _recargar() async {
    final nuevos = _model.cargar();
    setState(() {
      _datos = nuevos;
    });
    try {
      await nuevos;
    } catch (_) {
      // El error lo muestra ContenidoAsincrono.
    }
  }

  void _abrirProyecto(RentabilidadDto proyecto) {
    context.pushNamed(
      'portafolio',
      queryParameters: {
        'idProyecto': serializeParam(proyecto.id, ParamType.int),
      }.withoutNulls,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      titulo: _t('pat_titulo'),
      cuerpo: ContenidoAsincrono<PatrimonioDto>(
        future: _datos,
        mensajeError: _t('pat_error'),
        textoReintentar: _t('dash_reintentar'),
        onReintentar: _recargar,
        builder: (context, datos) => RefreshIndicator(
          onRefresh: _recargar,
          child: _contenido(datos),
        ),
      ),
    );
  }

  Widget _contenido(PatrimonioDto datos) {
    final tema = FlutterFlowTheme.of(context);
    final total = datos.totalInversiones;
    final mesesCortos = DateFormat.MMM(FFLocalizations.of(context).languageCode);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: Espacio.pantalla,
      children: [
        TarjetaPatrimonio(patrimonio: datos),
        EncabezadoSeccion(
          titulo: _t('pat_evolucion'),
          subtitulo: _t('pat_evolucion_ayuda'),
        ),
        GraficoSaldo(
          saldos: [for (final p in datos.evolucion) p.patrimonio],
          etiquetaMes: (i) {
            if (i < 0 || i >= datos.evolucion.length) return '';
            final fecha = DateTime.tryParse('${datos.evolucion[i].periodo}-01');
            return fecha == null ? '' : mesesCortos.format(fecha);
          },
        ),
        EncabezadoSeccion(
          titulo: _t('pat_rentabilidad'),
          subtitulo: _t('pat_rentabilidad_ayuda'),
        ),
        if (datos.porProyecto.isEmpty)
          Text(_t('pat_sin_inversiones'),
              style: tema.bodyMedium.copyWith(color: tema.secondaryText))
        else ...[
          Row(
            children: [
              Expanded(
                child: IndicadorKpi(
                  titulo: _t('pat_aportado'),
                  valor: FormatoMoneda.cop(total.aportado),
                  icono: Icons.input_rounded,
                ),
              ),
              const SizedBox(width: Espacio.m),
              Expanded(
                child: IndicadorKpi(
                  titulo: _t('pat_ganancia'),
                  valor: total.porcentaje == null
                      ? FormatoMoneda.cop(total.ganancia)
                      : '${FormatoMoneda.cop(total.ganancia)} '
                          '(${textoPorcentaje(total.porcentaje!)})',
                  icono: Icons.trending_up_rounded,
                  colorIcono: colorGanancia(total.ganancia, tema),
                  colorValor: colorGanancia(total.ganancia, tema),
                ),
              ),
            ],
          ),
          EncabezadoSeccion(titulo: _t('pat_por_tipo')),
          ..._filas(datos.porTipo, _t('proy_sin_tipo')),
          EncabezadoSeccion(titulo: _t('pat_por_proyecto')),
          ..._filas(datos.porProyecto, '', onTap: _abrirProyecto),
        ],
        const SizedBox(height: Espacio.xl),
      ],
    );
  }

  List<Widget> _filas(List<RentabilidadDto> datos, String sinNombre,
      {ValueChanged<RentabilidadDto>? onTap}) {
    final tema = FlutterFlowTheme.of(context);
    return [
      for (var i = 0; i < datos.length; i++) ...[
        if (i > 0) Divider(height: 1, color: tema.alternate),
        FilaRentabilidad(
          dato: datos[i],
          nombreSinDato: sinNombre,
          onTap: onTap == null ? null : () => onTap(datos[i]),
        ),
      ],
    ];
  }
}
