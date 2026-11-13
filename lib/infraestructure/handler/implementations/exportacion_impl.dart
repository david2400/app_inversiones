import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:inversiones/config/registro.dart';
import 'package:inversiones/domain/entity/movimiento_exportable_entity.dart';
import 'package:inversiones/domain/models/generador_csv.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:inversiones/domain/schema/transferencia_schema.dart';
import 'package:inversiones/infraestructure/handler/interfaces/exportacion_interface.dart';
import 'package:path/path.dart';

class ExportacionHandler implements IExportacion {
  static const prefijoArchivo = 'movimientos_';
  static const extensionArchivo = '.csv';
  static const formatoMarca = 'yyyyMMdd_HHmmss';

  static const encabezados = [
    'ID',
    'Fecha',
    'Naturaleza',
    'Tipo',
    'Portafolio origen',
    'Destino',
    'Motivo',
    'Valor',
    'GMF 4x1000',
    'Total debitado',
    'Descripción',
  ];

  static const _naturaleza = {
    TipoFuente.ingreso: 'Ingreso',
    TipoFuente.egreso: 'Egreso',
    TipoFuente.transferencia: 'Transferencia',
  };

  final TransferenciaShema _transferenciaShema;

  ExportacionHandler({TransferenciaShema? transferenciaShema})
      : _transferenciaShema = transferenciaShema ?? TransferenciaShema();

  @override
  Future<String> exportarMovimientosCsv(
      {required String directorio,
      PeriodoExportacion periodo = PeriodoExportacion.todo,
      DateTime? fecha}) async {
    try {
      final hoy = fecha ?? DateTime.now();
      final (desde, hasta) = _rango(periodo, hoy);

      final movimientos = await _transferenciaShema
          .obtenerMovimientosParaExportar(desde: desde, hasta: hasta);
      final contenido =
          GeneradorCsv.generar(encabezados, movimientos.map(_fila).toList());

      final ruta = join(directorio,
          '$prefijoArchivo${DateFormat(formatoMarca).format(DateTime.now())}$extensionArchivo');
      await File(ruta).writeAsString(contenido, encoding: utf8);
      Registro.info('Exportados ${movimientos.length} movimientos a $ruta');
      return ruta;
    } catch (e, pila) {
      Registro.error('ExportacionHandler: error al exportar', e, pila);
      rethrow;
    }
  }

  List<Object?> _fila(MovimientoExportable m) {
    final debita = TipoFuente.debitaOrigen(m.tipoFuente);
    return [
      m.idTransferencia,
      m.fecha,
      _naturaleza[m.tipoFuente] ?? m.tipoFuente,
      m.tipo,
      m.origen,
      m.destino ?? m.destinoAlternativo,
      m.motivo,
      m.valor,
      m.impuesto,
      debita ? m.valor + m.impuesto : 0,
      m.descripcion,
    ];
  }

  static (String?, String?) _rango(PeriodoExportacion periodo, DateTime hoy) {
    switch (periodo) {
      case PeriodoExportacion.mesActual:
        return (
          _fecha(DateTime(hoy.year, hoy.month, 1)),
          _fecha(DateTime(hoy.year, hoy.month + 1, 1))
        );
      case PeriodoExportacion.anioActual:
        return (
          _fecha(DateTime(hoy.year, 1, 1)),
          _fecha(DateTime(hoy.year + 1, 1, 1))
        );
      case PeriodoExportacion.todo:
        return (null, null);
    }
  }

  static String _fecha(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
}
