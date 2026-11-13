// Componentes base del sistema de diseño de Inversiones.
// Copiado por la skill inversiones-ui-pro. Las pantallas deben armarse con
// estas piezas en lugar de repetir Container/Padding/estilos a mano.
import 'package:flutter/material.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/widgets/drawer_widget.dart';

/// Escala de espaciado (múltiplos de 4). Usar siempre estos valores.
class Espacio {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Margen lateral de las pantallas.
  static const pantalla = EdgeInsets.fromLTRB(l, s, l, xl);

  Espacio._();
}

/// Radios de borde.
class Radios {
  static const s = 8.0;
  static const m = 12.0;

  Radios._();
}

/// Alto mínimo de un objetivo táctil (accesibilidad).
const double altoMinimoTactil = 48;

/// Estructura común de pantalla: AppBar plano, menú lateral opcional y
/// contenido dentro de SafeArea.
class PantallaBase extends StatelessWidget {
  final String titulo;
  final Widget cuerpo;
  final List<Widget>? acciones;
  final Widget? botonFlotante;
  final bool conMenu;

  const PantallaBase({
    super.key,
    required this.titulo,
    required this.cuerpo,
    this.acciones,
    this.botonFlotante,
    this.conMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: tema.primaryBackground,
      appBar: AppBar(
        backgroundColor: tema.primaryBackground,
        foregroundColor: tema.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(titulo, style: tema.titleLarge),
        actions: acciones,
      ),
      drawer: conMenu ? const DrawerWidget() : null,
      floatingActionButton: botonFlotante,
      body: SafeArea(child: cuerpo),
    );
  }
}

/// Superficie elevada sin sombra: fondo secundario y borde sutil.
class Tarjeta extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const Tarjeta({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Espacio.l),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Material(
      color: tema.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radios.m),
        side: BorderSide(color: tema.alternate),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Título de sección con ayuda opcional y acción a la derecha.
class EncabezadoSeccion extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final Widget? accion;

  const EncabezadoSeccion(
      {super.key, required this.titulo, this.subtitulo, this.accion});

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Espacio.xl, bottom: Espacio.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: tema.titleMedium),
                if (subtitulo != null)
                  Text(subtitulo!,
                      style: tema.bodySmall.copyWith(color: tema.secondaryText)),
              ],
            ),
          ),
          if (accion != null) accion!,
        ],
      ),
    );
  }
}

class EstadoCargando extends StatelessWidget {
  const EstadoCargando({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// Estado vacío: ícono, explicación y, si aplica, la acción para salir de él.
class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String mensaje;
  final String? textoAccion;
  final VoidCallback? onAccion;

  const EstadoVacio({
    super.key,
    required this.icono,
    required this.mensaje,
    this.textoAccion,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Espacio.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 48, color: tema.secondaryText),
            const SizedBox(height: Espacio.l),
            Text(mensaje,
                textAlign: TextAlign.center,
                style: tema.bodyMedium.copyWith(color: tema.secondaryText)),
            if (textoAccion != null && onAccion != null) ...[
              const SizedBox(height: Espacio.l),
              FilledButton(onPressed: onAccion, child: Text(textoAccion!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de error con opción de reintentar.
class EstadoError extends StatelessWidget {
  final String mensaje;
  final String textoReintentar;
  final VoidCallback? onReintentar;

  const EstadoError({
    super.key,
    required this.mensaje,
    required this.textoReintentar,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) => EstadoVacio(
        icono: Icons.error_outline_rounded,
        mensaje: mensaje,
        textoAccion: onReintentar == null ? null : textoReintentar,
        onAccion: onReintentar,
      );
}

/// FutureBuilder con los tres estados resueltos (cargando, error, vacío).
/// [future] debe venir de un campo del State, nunca de una llamada en build.
class ContenidoAsincrono<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T datos) builder;
  final bool Function(T datos)? esVacio;
  final Widget? vacio;
  final String mensajeError;
  final String textoReintentar;
  final VoidCallback? onReintentar;

  const ContenidoAsincrono({
    super.key,
    required this.future,
    required this.builder,
    required this.mensajeError,
    required this.textoReintentar,
    this.esVacio,
    this.vacio,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const EstadoCargando();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return EstadoError(
            mensaje: mensajeError,
            textoReintentar: textoReintentar,
            onReintentar: onReintentar,
          );
        }
        final datos = snapshot.data as T;
        if (vacio != null && esVacio != null && esVacio!(datos)) return vacio!;
        return builder(context, datos);
      },
    );
  }
}

/// Indicador numérico (KPI): etiqueta, valor destacado e ícono de identidad.
class IndicadorKpi extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData? icono;
  final Color? colorIcono;
  final Color? colorValor;

  const IndicadorKpi({
    super.key,
    required this.titulo,
    required this.valor,
    this.icono,
    this.colorIcono,
    this.colorValor,
  });

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Tarjeta(
      padding: const EdgeInsets.all(Espacio.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            if (icono != null) ...[
              Icon(icono, size: 18, color: colorIcono ?? tema.secondaryText),
              const SizedBox(width: Espacio.s),
            ],
            Expanded(
              child: Text(titulo,
                  overflow: TextOverflow.ellipsis,
                  style: tema.bodySmall.copyWith(color: tema.secondaryText)),
            ),
          ]),
          const SizedBox(height: Espacio.s),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valor,
                style: tema.titleLarge
                    .copyWith(color: colorValor ?? tema.primaryText)),
          ),
        ],
      ),
    );
  }
}

/// Botón principal de un formulario: ancho completo, 48 px, con estado de
/// carga que evita el doble envío.
class BotonPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;
  final IconData? icono;

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: cargando ? null : onPressed,
      style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(altoMinimoTactil)),
      icon: cargando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icono ?? Icons.check_rounded),
      label: Text(texto),
    );
  }
}

/// Diálogo de confirmación. Para acciones destructivas el botón usa el color
/// de error. Retorna `true` si el usuario confirma.
Future<bool> confirmarAccion(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String textoConfirmar,
  required String textoCancelar,
  bool destructiva = false,
}) async {
  final tema = FlutterFlowTheme.of(context);
  final resultado = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(textoCancelar),
        ),
        FilledButton(
          style: destructiva
              ? FilledButton.styleFrom(backgroundColor: tema.error)
              : null,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(textoConfirmar),
        ),
      ],
    ),
  );
  return resultado ?? false;
}

/// Mensaje breve en la parte inferior. Quita el prefijo técnico
/// "Exception: " de los errores de negocio.
void mostrarMensaje(BuildContext context, Object mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    content: Text(mensaje.toString().replaceFirst('Exception: ', '')),
  ));
}
