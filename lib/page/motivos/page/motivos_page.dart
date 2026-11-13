import 'package:flutter/material.dart';
import 'package:inversiones/page/motivos/dto/motivos_dto.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/componentes.dart';

export 'package:inversiones/page/motivos/states/motivos_page_state.dart';
import 'package:inversiones/page/motivos/states/motivos_page_state.dart';

/// Listado de motivos: por qué entra o sale el dinero.
class MotivosPage extends StatefulWidget {
  const MotivosPage({super.key});

  @override
  State<MotivosPage> createState() => _MotivosPageState();
}

class _MotivosPageState extends State<MotivosPage> {
  static const _rutaNuevoMotivo = 'admin_motivos';

  late MotivosPageState _model;

  /// Consulta guardada en el State: nunca se dispara desde `build`.
  late Future<List<MotivosDto>> _motivos;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MotivosPageState());
    _motivos = listarMotivos();
  }

  /// Delega en el State de la página. Los errores se propagan para que la
  /// pantalla muestre el estado de error con "Reintentar" en lugar de una
  /// lista vacía engañosa.
  Future<List<MotivosDto>> listarMotivos() => _model.listarMotivos();

  /// Vuelve a consultar los datos (al volver de crear o editar).
  void _recargarDatos() {
    if (!mounted) return;
    setState(() {
      _motivos = listarMotivos();
    });
  }

  Future<void> _abrirNuevoMotivo() async {
    await context.pushNamed(
      _rutaNuevoMotivo,
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
      titulo: textos.getText('mot_titulo'),
      botonFlotante: FloatingActionButton.extended(
        onPressed: _abrirNuevoMotivo,
        tooltip: textos.getText('mot_agregar'),
        icon: const Icon(Icons.add_rounded),
        label: Text(textos.getText('mot_agregar')),
      ),
      cuerpo: GestureDetector(
        onTap: () => _model.unfocusNode.canRequestFocus
            ? FocusScope.of(context).requestFocus(_model.unfocusNode)
            : FocusScope.of(context).unfocus(),
        child: ContenidoAsincrono<List<MotivosDto>>(
          future: _motivos,
          mensajeError: textos.getText('mot_error'),
          textoReintentar: textos.getText('mot_reintentar'),
          onReintentar: _recargarDatos,
          esVacio: (motivos) => motivos.isEmpty,
          vacio: EstadoVacio(
            icono: Icons.label_outline_rounded,
            mensaje: textos.getText('mot_vacio'),
            textoAccion: textos.getText('mot_agregar'),
            onAccion: _abrirNuevoMotivo,
          ),
          builder: (context, motivos) => _ListaMotivos(motivos: motivos),
        ),
      ),
    );
  }
}

/// Lista perezosa: encabezado con el total y una fila por motivo.
class _ListaMotivos extends StatelessWidget {
  final List<MotivosDto> motivos;

  const _ListaMotivos({required this.motivos});

  /// Deja libre el final de la lista para que el botón flotante no tape la
  /// última fila.
  static const _espacioBotonFlotante = 88.0;

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    return ListView.separated(
      padding: Espacio.pantalla.copyWith(bottom: _espacioBotonFlotante),
      itemCount: motivos.length + 1,
      separatorBuilder: (context, indice) => indice == 0
          ? const SizedBox(height: Espacio.s)
          : Divider(height: 1, color: tema.alternate),
      itemBuilder: (context, indice) {
        if (indice == 0) {
          return EncabezadoSeccion(
            titulo: '${motivos.length} ${textos.getText('mot_total')}',
            subtitulo: textos.getText('mot_subtitulo'),
          );
        }
        return _FilaMotivo(motivo: motivos[indice - 1]);
      },
    );
  }
}

class _FilaMotivo extends StatelessWidget {
  final MotivosDto motivo;

  const _FilaMotivo({required this.motivo});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final textos = FFLocalizations.of(context);
    final descripcion = motivo.descripcion.trim();
    final tieneDescripcion = descripcion.isNotEmpty;
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
        child: Icon(Icons.label_rounded, size: 20, color: tema.primary),
      ),
      title: Text(
        motivo.nombre,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tema.titleSmall,
      ),
      subtitle: Text(
        tieneDescripcion ? descripcion : textos.getText('mot_sin_descripcion'),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: tema.bodySmall.copyWith(
          color: tema.secondaryText,
          fontStyle: tieneDescripcion ? FontStyle.normal : FontStyle.italic,
        ),
      ),
    );
  }
}
