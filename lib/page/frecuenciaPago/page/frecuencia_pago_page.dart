import 'package:flutter/material.dart';
import 'package:inversiones/page/frecuenciaPago/dto/frecuencia_pago_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

export 'package:inversiones/page/frecuenciaPago/states/frecuencia_pago_page_state.dart';
import 'package:inversiones/page/frecuenciaPago/states/frecuencia_pago_page_state.dart';

/// Listado de frecuencias de pago (cada N días, meses o años).
class FrecuenciaPagoPage extends StatefulWidget {
  const FrecuenciaPagoPage({super.key});

  @override
  State<FrecuenciaPagoPage> createState() => _FrecuenciaPagoPageState();
}

class _FrecuenciaPagoPageState extends State<FrecuenciaPagoPage> {
  static const _rutaNuevaFrecuencia = 'admin_frecuencia_pago';

  late FrecuenciaPagoPageState _model;

  /// Consulta guardada en el State: nunca se dispara desde `build`.
  late Future<List<FrecuenciaPagoDto>> _frecuencias;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FrecuenciaPagoPageState());
    _frecuencias = listarFrecuenciaPago();
  }

  /// Delega en el State de la página. Los errores se propagan para que la
  /// pantalla muestre el estado de error con "Reintentar".
  Future<List<FrecuenciaPagoDto>> listarFrecuenciaPago() =>
      _model.listarFrecuenciaPago();

  /// Vuelve a consultar los datos (al volver de crear o editar).
  void _recargarDatos() {
    if (!mounted) return;
    setState(() {
      _frecuencias = listarFrecuenciaPago();
    });
  }

  Future<void> _abrirNuevaFrecuencia() async {
    await context.pushNamed(
      _rutaNuevaFrecuencia,
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.bottomToTop,
          duration: Duration(milliseconds: 220),
        ),
      },
    );
    _recargarDatos();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = FFLocalizations.of(context);
    return PantallaBase(
      titulo: textos.getText('frec_titulo'),
      botonFlotante: FloatingActionButton.extended(
        onPressed: _abrirNuevaFrecuencia,
        tooltip: textos.getText('frec_agregar'),
        icon: const Icon(Icons.add_rounded),
        label: Text(textos.getText('frec_agregar')),
      ),
      cuerpo: GestureDetector(
        onTap: () => _model.unfocusNode.canRequestFocus
            ? FocusScope.of(context).requestFocus(_model.unfocusNode)
            : FocusScope.of(context).unfocus(),
        child: ContenidoAsincrono<List<FrecuenciaPagoDto>>(
          future: _frecuencias,
          mensajeError: textos.getText('frec_error'),
          textoReintentar: textos.getText('frec_reintentar'),
          onReintentar: _recargarDatos,
          esVacio: (frecuencias) => frecuencias.isEmpty,
          vacio: EstadoVacio(
            icono: Icons.event_repeat_rounded,
            mensaje: textos.getText('frec_vacio'),
            textoAccion: textos.getText('frec_agregar'),
            onAccion: _abrirNuevaFrecuencia,
          ),
          builder: (context, frecuencias) =>
              _ListaFrecuencias(frecuencias: frecuencias),
        ),
      ),
    );
  }
}

/// Lista perezosa: encabezado con el total y una fila por frecuencia.
class _ListaFrecuencias extends StatelessWidget {
  final List<FrecuenciaPagoDto> frecuencias;

  const _ListaFrecuencias({required this.frecuencias});

  /// Deja libre el final de la lista para que el botón flotante no tape la
  /// última fila.
  static const _espacioBotonFlotante = 88.0;

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    return ListView.separated(
      padding: Espacio.pantalla.copyWith(bottom: _espacioBotonFlotante),
      itemCount: frecuencias.length + 1,
      separatorBuilder: (context, indice) => indice == 0
          ? const SizedBox(height: Espacio.s)
          : Divider(height: 1, color: tema.alternate),
      itemBuilder: (context, indice) {
        if (indice == 0) {
          return EncabezadoSeccion(
            titulo: '${frecuencias.length} ${textos.getText('frec_total')}',
            subtitulo: textos.getText('frec_subtitulo'),
          );
        }
        return _FilaFrecuencia(frecuencia: frecuencias[indice - 1]);
      },
    );
  }
}

class _FilaFrecuencia extends StatelessWidget {
  final FrecuenciaPagoDto frecuencia;

  const _FilaFrecuencia({required this.frecuencia});

  /// Códigos de la columna `formato` (los mismos que guarda
  /// `AdminFrecuenciaPagoPage`).
  static const _formatoDias = 'D';
  static const _formatoMeses = 'M';
  static const _formatoAnios = 'Y';

  /// Clave de traducción de la unidad (singular o plural), o `null` si el
  /// código no es conocido.
  static String? _claveUnidad(String formato, bool singular) {
    switch (formato) {
      case _formatoDias:
        return singular ? 'frec_dia' : 'frec_dias';
      case _formatoMeses:
        return singular ? 'frec_mes' : 'frec_meses';
      case _formatoAnios:
        return singular ? 'frec_anio' : 'frec_anios';
      default:
        return null;
    }
  }

  static String? _claveDetalle(String formato) {
    switch (formato) {
      case _formatoDias:
        return 'frec_en_dias';
      case _formatoMeses:
        return 'frec_en_meses';
      case _formatoAnios:
        return 'frec_en_anios';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final formato = frecuencia.formato.trim().toUpperCase();
    final claveUnidad = _claveUnidad(formato, frecuencia.tiempo == 1);
    final unidad =
        claveUnidad == null ? frecuencia.formato : textos.getText(claveUnidad);
    final claveDetalle = _claveDetalle(formato);
    final detalle = claveDetalle == null
        ? textos.getText('frec_formato_desconocido')
        : textos.getText(claveDetalle);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: Espacio.m,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tema.accent1,
          borderRadius: BorderRadius.circular(Radios.s),
        ),
        child: Icon(Icons.event_repeat_rounded, size: 20, color: tema.primary),
      ),
      title: Text(
        '${textos.getText('frec_cada')} ${frecuencia.tiempo} $unidad',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tema.titleSmall,
      ),
      subtitle: Text(
        detalle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tema.bodySmall.copyWith(color: tema.secondaryText),
      ),
    );
  }
}
