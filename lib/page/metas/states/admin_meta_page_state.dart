import 'package:flutter/material.dart';
import 'package:inversiones/infraestructure/handler/implementations/meta_impl.dart';
import 'package:inversiones/infraestructure/handler/interfaces/meta_interface.dart';
import 'package:inversiones/page/metas/dto/meta_dto.dart';
import 'package:inversiones/page/metas/page/admin_meta_page.dart';
import 'package:inversiones/ui/utils/flutter_flow_util.dart';

/// Orquesta el alta y la edición de una meta de ahorro.
class AdminMetaPageState extends FlutterFlowModel<AdminMetaPage> {
  final IMeta _metaHandler = MetaHandler();

  final nombreFocus = FocusNode();
  final nombreController = TextEditingController();
  final descripcionFocus = FocusNode();
  final descripcionController = TextEditingController();
  final montoController = TextEditingController();

  DateTime? fechaObjetivo;
  Set<int> portafolios = {};

  /// Portafolios que se pueden elegir (sin los de otras metas).
  List<PortafolioMetaDto> disponibles = [];

  /// Meta que se está editando (`null` al crear).
  MetaDto? metaEditada;

  bool get editando => metaEditada != null;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nombreFocus.dispose();
    nombreController.dispose();
    descripcionFocus.dispose();
    descripcionController.dispose();
    montoController.dispose();
  }

  /// Carga los portafolios disponibles y, con [idMeta], la meta a editar.
  Future<void> cargar(int? idMeta) async {
    try {
      disponibles = await _metaHandler.portafoliosDisponibles(idMeta: idMeta);
      if (idMeta == null) return;
      final meta = await _metaHandler.obtenerMeta(idMeta);
      metaEditada = meta;
      nombreController.text = meta.nombre;
      descripcionController.text = meta.descripcion ?? '';
      montoController.text = '${meta.montoObjetivo}';
      fechaObjetivo = DateTime.tryParse(meta.fechaObjetivo ?? '');
      portafolios = meta.portafolioIds.toSet();
    } catch (e) {
      rethrow;
    }
  }

  int? get monto => int.tryParse(montoController.text.trim());

  /// Suma de los saldos de los portafolios elegidos (avance inicial).
  int get ahorradoSeleccion => disponibles
      .where((p) => portafolios.contains(p.idPortafolio))
      .fold(0, (s, p) => s + p.saldo);

  String? get _fechaTexto =>
      fechaObjetivo == null ? null : MetaHandler.formatoFecha(fechaObjetivo!);

  bool hayCambios() {
    final original = metaEditada;
    if (original == null) {
      return nombreController.text.trim().isNotEmpty ||
          descripcionController.text.trim().isNotEmpty ||
          montoController.text.trim().isNotEmpty ||
          fechaObjetivo != null ||
          portafolios.isNotEmpty;
    }
    return nombreController.text.trim() != original.nombre ||
        descripcionController.text.trim() != (original.descripcion ?? '') ||
        monto != original.montoObjetivo ||
        _fechaTexto != original.fechaObjetivo ||
        !portafolios.containsAll(original.portafolioIds) ||
        portafolios.length != original.portafolioIds.length;
  }

  /// Crea o actualiza la meta. Retorna su id.
  Future<int> guardar() async {
    try {
      return await _metaHandler.guardar(MetaDto(
        idMeta: metaEditada?.idMeta,
        nombre: nombreController.text,
        descripcion: descripcionController.text,
        montoObjetivo: monto ?? 0,
        fechaObjetivo: _fechaTexto,
        portafolioIds: portafolios.toList(),
        activo: metaEditada?.activo ?? true,
      ));
    } catch (e) {
      rethrow;
    }
  }
}
