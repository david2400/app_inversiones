import 'package:flutter/material.dart';
import 'package:inversiones/page/terceros/dto/tercero_dto.dart';
import 'package:inversiones/page/terceros/states/terceros_page_state.dart';
import 'package:inversiones/ui/utils/flutter_flow_theme.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';
import 'package:inversiones/ui/widgets/drawer_widget.dart';

/// Catálogo de terceros: de quién recibes dinero y a quién le pagas.
class TercerosPage extends StatefulWidget {
  const TercerosPage({super.key});

  @override
  State<TercerosPage> createState() => _TercerosPageState();
}

class _TercerosPageState extends State<TercerosPage> {
  late TercerosPageState _model;
  late Future<List<TerceroDto>> _terceros;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TercerosPageState());
    _terceros = _model.listar();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String _t(String clave) => FFLocalizations.of(context).getText(clave);

  void _recargar() => setState(() => _terceros = _model.listar());

  void _mensaje(Object texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(texto.toString().replaceFirst('Exception: ', ''))));
  }

  Future<void> _editar([TerceroDto? tercero]) async {
    final nombre = TextEditingController(text: tercero?.nombre);
    final descripcion = TextEditingController(text: tercero?.descripcion);
    final guardado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t(tercero == null ? 'ter_nuevo' : 'ter_editar')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombre,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: _t('ter_nombre')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descripcion,
              decoration: InputDecoration(labelText: _t('ter_descripcion')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(_t('mov_cancelar')),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _model.guardar(TerceroDto(
                  idTercero: tercero?.idTercero,
                  nombre: nombre.text,
                  descripcion: descripcion.text,
                  createdAt: tercero?.createdAt,
                ));
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } catch (e) {
                _mensaje(e);
              }
            },
            child: Text(_t('ter_guardar')),
          ),
        ],
      ),
    );
    nombre.dispose();
    descripcion.dispose();
    if (guardado == true) _recargar();
  }

  Future<void> _eliminar(TerceroDto tercero) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_t('ter_eliminar_titulo')),
        content: Text(tercero.nombre),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(_t('mov_cancelar')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(_t('ter_eliminar')),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      await _model.eliminar(tercero.idTercero!);
      _recargar();
    } catch (e) {
      _mensaje(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('ter_titulo')),
        backgroundColor: tema.primaryBackground,
      ),
      drawer: const DrawerWidget(),
      backgroundColor: tema.primaryBackground,
      floatingActionButton: FloatingActionButton(
        tooltip: _t('ter_nuevo'),
        onPressed: () => _editar(),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: SafeArea(
        child: FutureBuilder<List<TerceroDto>>(
          future: _terceros,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(_t('dash_error')));
            }
            final terceros = snapshot.data ?? [];
            if (terceros.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_t('ter_vacio'),
                      textAlign: TextAlign.center, style: tema.bodyMedium),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              itemCount: terceros.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: tema.alternate),
              itemBuilder: (context, i) {
                final tercero = terceros[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: tema.secondaryBackground,
                    child: Text(tercero.nombre.characters.first.toUpperCase(),
                        style: tema.titleSmall),
                  ),
                  title: Text(tercero.nombre, style: tema.bodyLarge),
                  subtitle: tercero.descripcion == null
                      ? null
                      : Text(tercero.descripcion!,
                          style: tema.bodySmall
                              .copyWith(color: tema.secondaryText)),
                  onTap: () => _editar(tercero),
                  trailing: IconButton(
                    tooltip: _t('ter_eliminar'),
                    icon: Icon(Icons.delete_outline_rounded,
                        color: tema.secondaryText),
                    onPressed: () => _eliminar(tercero),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
