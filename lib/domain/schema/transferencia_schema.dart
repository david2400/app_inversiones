import 'package:inversiones/config/database_config.dart';
import 'package:inversiones/domain/models/table_abstract.dart';
import 'package:inversiones/domain/models/auditoria.dart';
import 'package:inversiones/domain/schema/motivos_schema.dart';
import 'package:inversiones/domain/schema/portafolio_schema.dart';
import 'package:inversiones/domain/entity/saldo_portafolio_entity.dart';
import 'package:inversiones/domain/entity/movimiento_exportable_entity.dart';
import 'package:inversiones/domain/entity/total_mensual_entity.dart';
import 'package:inversiones/domain/entity/flujo_entre_cuentas_entity.dart';
import 'package:inversiones/domain/entity/total_por_concepto_entity.dart';
import 'package:inversiones/domain/models/agrupacion_concepto.dart';
import 'package:inversiones/domain/models/filtro_movimientos.dart';
import 'package:inversiones/domain/models/tipo_fuente.dart';
import 'package:sqflite/sqflite.dart';
import 'package:inversiones/domain/schema/tercero_schema.dart';
import 'package:inversiones/domain/schema/tipo_transaccion_schema.dart';
import 'package:inversiones/domain/consultas/transaccion_balance_dto.dart';
import 'package:inversiones/domain/consultas/transaccion_portafolio_dto.dart';
import 'package:inversiones/domain/consultas/transacciones_details_dto.dart';
import 'package:inversiones/domain/entity/transferencia_entity.dart';

class TransferenciaShema implements TableAbstract {
  static const table = 'transferencias';

  static const idTransferencia = "id_transferencia";
  static const valor = "valor";
  static const impuesto = "impuesto";
  static const tipoTransferencia = "tipo_transferencia_id";
  static const motivo = "motivo_id";
  static const portafolioId = "portafolio_id";
  static const destino = "destino_cuenta";
  static const destinoAlternativo = "destino_alternativo";
  static const terceroId = "tercero_id";
  static const recurrenteId = "recurrente_id";

  /// Número de cuotas de una compra con tarjeta de crédito (nulo = 1).
  static const numeroCuotas = "numero_cuotas";
  static const descripcion = "descripcion";
  static const createdAt = "created_at";
  static const updatedAt = "updated_at";
  static const deletedAt = "deleted_at";

  final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  final intType = 'INTEGER NOT NULL';
  final intTypeNull = 'INTEGER NULL';
  final textType = 'TEXT NOT NULL';
  final textTypeNull = 'TEXT NULL';
  final doubleType = 'REAL NOT NULL';

  @override
  String createTableQuery() {
    return "CREATE TABLE $table ("
        "$idTransferencia $idType,"
        "$valor $intType,"
        "$impuesto $intTypeNull,"
        "$tipoTransferencia $intType,"
        "$motivo $intTypeNull,"
        "$portafolioId $intType,"
        "$destino $intTypeNull,"
        "$destinoAlternativo $textTypeNull,"
        "$descripcion $textTypeNull,"
        "$createdAt $textType,"
        "$updatedAt $textTypeNull,"
        "$deletedAt $textTypeNull,"
        "$terceroId $intTypeNull,"
        "$recurrenteId $intTypeNull,"
        "$numeroCuotas $intTypeNull,"
        "FOREIGN KEY ($tipoTransferencia) REFERENCES ${TipoTransaccionSchema.table} (${TipoTransaccionSchema.idTipoTransaccion}),"
        "FOREIGN KEY ($motivo) REFERENCES ${MotivosSchema.table} (${MotivosSchema.idMotivo}),"
        "FOREIGN KEY ($portafolioId) REFERENCES ${PortafolioSchema.table} (${PortafolioSchema.idPortafolio}),"
        "FOREIGN KEY ($destino) REFERENCES ${PortafolioSchema.table} (${PortafolioSchema.idPortafolio}),"
        "FOREIGN KEY ($terceroId) REFERENCES ${TerceroSchema.table} (${TerceroSchema.idTercero}),"
        "FOREIGN KEY ($recurrenteId) REFERENCES recurrentes (id_recurrente)"
      ")";
  }

  @override
  Future<int> deleteAll() async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawDelete('''
      DELETE FROM $table
    ''');
    return result;
  }

  @override
  String dropTableQuery() {
    return "DROP TABLE IF EXISTS $table";
  }

  @override
  Future<List<Transaccion>> getAll() async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table, where: Auditoria.filtroActivo);

    return result.isNotEmpty
        ? result.map((e) => Transaccion.fromJson(e)).toList()
        : [];
  }

  @override
  Future<Transaccion?> getById(int idT) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table, where: "$idTransferencia = ? AND ${Auditoria.filtroActivo}", whereArgs: [idT]);
    return result.isNotEmpty ? Transaccion.fromJson(result.first) : null;
  }

  /// SELECT + JOINs comunes para listar movimientos con sus nombres.
  static const _columnasDetalle = '''
        tr.id_transferencia, tr.valor, tr.impuesto, tr.destino_cuenta AS destino_cuenta_id, pr.nombre AS destino_cuenta,
        tr.tipo_transferencia_id, tt.nombre AS tipo_transaccion, tr.motivo_id, mo.nombre  AS motivo,
        tt.tipo_fuente, tr.destino_alternativo, tr.descripcion, tr.created_at, tr.updated_at, tr.deleted_at,
        tr.portafolio_id AS origen_id, po.nombre AS origen, tr.tercero_id, te.nombre AS tercero''';

  static const _fromDetalle = '''
        FROM ${TransferenciaShema.table} AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS po ON tr.portafolio_id = po.id_portafolio
        LEFT JOIN ${MotivosSchema.table} AS mo ON tr.motivo_id = mo.id_motivo
        LEFT JOIN ${PortafolioSchema.table} AS pr ON tr.destino_cuenta = pr.id_portafolio
        LEFT JOIN ${TerceroSchema.table} AS te ON tr.tercero_id = te.id_tercero''';

  static const _selectDetallePortafolio =
      'SELECT $_columnasDetalle $_fromDetalle';

  /// Columnas comunes para las consultas de balance.
  static const _columnasBalance = '''
        tr.id_transferencia, tr.valor, tr.impuesto, tr.portafolio_id,
        p.proyecto_id, tr.destino_cuenta, tt.tipo_fuente, tr.destino_alternativo''';

  /// [inicio del mes, inicio del mes siguiente) como texto `yyyy-MM-dd`,
  /// para filtrar con el índice de `created_at` (strftime no lo usa).
  static List<String> _rangoMes(int anio, int mes) {
    String dia(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-01';
    return [dia(DateTime(anio, mes, 1)), dia(DateTime(anio, mes + 1, 1))];
  }

  Future<List<TransaccionBalanceDto>> getTransaccionesByMesAndAnio(
      String year, String month) async {
    try {
      final db = await DatabaseHelper().ejecutor;
      final result = await db.rawQuery('''
        SELECT $_columnasBalance
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS p ON tr.portafolio_id = p.id_portafolio
        WHERE tr.deleted_at IS NULL
          AND tr.created_at >= ? AND tr.created_at < ?
      ''', _rangoMes(int.parse(year), int.parse(month)));
      return result.isNotEmpty
          ? result.map((e) => TransaccionBalanceDto.fromJson(e)).toList()
          : [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Transaccion>> getByPortafolioId(int idT) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table,
        where: "$portafolioId = ? AND ${Auditoria.filtroActivo}",
        whereArgs: [idT]);

    return result.isNotEmpty
        ? result.map((e) => Transaccion.fromJson(e)).toList()
        : [];
  }

  /// Compras a varias cuotas hechas desde el portafolio [idPortafolio]
  /// (tarjeta de crédito), de la más reciente a la más antigua.
  Future<List<Transaccion>> comprasACuotas(int idPortafolio) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.query(table,
        where: "$portafolioId = ? AND $numeroCuotas > 1 "
            "AND ${Auditoria.filtroActivo}",
        whereArgs: [idPortafolio],
        orderBy: '$createdAt DESC');
    return result.map((e) => Transaccion.fromJson(e)).toList();
  }

  /// Movimientos que salen de, o llegan a, algún portafolio del proyecto.
  /// `proyecto_id` corresponde siempre al proyecto del portafolio origen.
  Future<List<TransaccionBalanceDto>> getBalanceByProyectoId(
      int proyectoId) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawQuery('''
        SELECT $_columnasBalance
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS p ON tr.portafolio_id = p.id_portafolio
        LEFT JOIN ${PortafolioSchema.table} AS pd ON tr.destino_cuenta = pd.id_portafolio
        WHERE tr.deleted_at IS NULL
          AND (p.proyecto_id = ? OR pd.proyecto_id = ?)
    ''', [proyectoId, proyectoId]);
    return result.isNotEmpty
        ? result.map((e) => TransaccionBalanceDto.fromJson(e)).toList()
        : [];
  }

  Future<List<TransaccionPortafolioDto>> getTransaccionByPortafolioId(
      int portafolioId) async {
    try {
      final db = await DatabaseHelper().ejecutor;
      final result = await db.rawQuery('''
            $_selectDetallePortafolio
            WHERE tr.deleted_at IS NULL
              AND (tr.portafolio_id = ? OR tr.destino_cuenta = ?)
            ORDER BY tr.created_at DESC, tr.id_transferencia DESC
            LIMIT ?
          ''', [portafolioId, portafolioId, FiltroMovimientos.limiteListaPortafolio]);
      return result.isNotEmpty
          ? result.map((e) => TransaccionPortafolioDto.fromJson(e)).toList()
          : [];
    } catch (e) {
      rethrow;
    }
  }

  Future<TransaccionDetailsDto?> getTransaccionDetails(
      int transaccionId) async {
    try {
      final db = await DatabaseHelper().ejecutor;
      final result = await db.rawQuery('''
          $_selectDetallePortafolio
          WHERE tr.id_transferencia = ? AND tr.deleted_at IS NULL
      ''', [transaccionId]);
      return result.isNotEmpty
          ? TransaccionDetailsDto.fromJson(result.first)
          : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Saldo de cada portafolio activo calculado desde los movimientos:
  /// ingresos (+), egresos y transferencias salientes (−valor −GMF) y
  /// transferencias entrantes (+valor). Si se indica [idPortafolio] retorna
  /// solo ese portafolio.
  Future<List<SaldoPortafolio>> obtenerSaldos({int? idPortafolio}) async {
    final db = await DatabaseHelper().ejecutor;
    const ingreso = TipoFuente.ingreso;
    const transferencia = TipoFuente.transferencia;
    final filtroPortafolio =
        idPortafolio == null ? '' : 'AND p.id_portafolio = ?';

    final result = await db.rawQuery('''
        SELECT p.id_portafolio, p.nombre, p.proyecto_id, p.cuenta_id,
          COALESCE(SUM(m.ingreso), 0) AS ingresos,
          COALESCE(SUM(m.egreso), 0) AS egresos,
          COALESCE(SUM(m.impuesto), 0) AS impuestos,
          COALESCE(SUM(m.ingreso - m.egreso - m.impuesto), 0) AS saldo
        FROM ${PortafolioSchema.table} AS p
        LEFT JOIN (
          SELECT tr.portafolio_id AS id_portafolio,
            CASE WHEN tt.tipo_fuente = '$ingreso' THEN tr.valor ELSE 0 END AS ingreso,
            CASE WHEN tt.tipo_fuente = '$ingreso' THEN 0 ELSE tr.valor END AS egreso,
            CASE WHEN tt.tipo_fuente = '$ingreso' THEN 0 ELSE COALESCE(tr.impuesto, 0) END AS impuesto
          FROM $table AS tr
          JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
          WHERE tr.deleted_at IS NULL
          UNION ALL
          SELECT tr.destino_cuenta, tr.valor, 0, 0
          FROM $table AS tr
          JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
          WHERE tr.deleted_at IS NULL
            AND tt.tipo_fuente = '$transferencia'
            AND tr.destino_cuenta IS NOT NULL
        ) AS m ON m.id_portafolio = p.id_portafolio
        WHERE p.deleted_at IS NULL $filtroPortafolio
        GROUP BY p.id_portafolio, p.nombre, p.proyecto_id, p.cuenta_id
        ORDER BY p.nombre
    ''', idPortafolio == null ? [] : [idPortafolio]);

    return result.map((e) => SaldoPortafolio.fromJson(e)).toList();
  }

  /// Vincula un movimiento ya registrado con su movimiento fijo.
  Future<int> asignarRecurrente(int idTransaccion, int idRecurrente) async {
    final db = await DatabaseHelper().ejecutor;
    return db.update(table, {recurrenteId: idRecurrente},
        where: '$idTransferencia = ?', whereArgs: [idTransaccion]);
  }

  /// Cuenta movimientos activos que referencian [id] en [columna].
  /// Se usa para impedir borrar catálogos que están en uso.
  Future<int> contarActivosPor(String columna, int id) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM $table '
      'WHERE $columna = ? AND ${Auditoria.filtroActivo}',
      [id],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Totales por mes en el rango [desde, hasta) (fechas `yyyy-MM-dd`).
  /// Ingreso: tipo ingreso. Egreso: tipo egreso o transferencia a cuenta
  /// externa. Las transferencias entre portafolios propios no cuentan.
  Future<List<TotalMensual>> obtenerTotalesMensuales(
      {required String desde, required String hasta}) async {
    final db = await DatabaseHelper().ejecutor;
    const ingreso = TipoFuente.ingreso;
    const egreso = TipoFuente.egreso;
    const transferencia = TipoFuente.transferencia;

    final result = await db.rawQuery('''
        SELECT strftime('%Y-%m', tr.created_at) AS periodo,
          SUM(CASE WHEN tt.tipo_fuente = '$ingreso' THEN tr.valor ELSE 0 END) AS ingresos,
          SUM(CASE WHEN tt.tipo_fuente = '$egreso'
                     OR (tt.tipo_fuente = '$transferencia' AND tr.destino_cuenta IS NULL)
                   THEN tr.valor ELSE 0 END) AS egresos,
          SUM(CASE WHEN tt.tipo_fuente = '$ingreso' THEN 0
                   ELSE COALESCE(tr.impuesto, 0) END) AS impuestos
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        WHERE tr.deleted_at IS NULL
          AND tr.created_at >= ? AND tr.created_at < ?
        GROUP BY periodo
        ORDER BY periodo
    ''', [desde, hasta]);

    return result.map((e) => TotalMensual.fromJson(e)).toList();
  }

  // Reglas de un proyecto (?1 = id del proyecto). Ingreso: ingresos a sus
  // portafolios y transferencias que llegan desde fuera del proyecto.
  // Egreso: egresos y transferencias que salen del proyecto (o a cuentas
  // externas). GMF: el pagado por sus portafolios.
  static const _ingresoProyecto = '''
      (tt.tipo_fuente = '${TipoFuente.ingreso}' AND po.proyecto_id = ?1)
      OR (tt.tipo_fuente = '${TipoFuente.transferencia}' AND pd.proyecto_id = ?1
          AND po.proyecto_id <> ?1)''';
  static const _egresoProyecto = '''
      po.proyecto_id = ?1 AND (tt.tipo_fuente = '${TipoFuente.egreso}'
        OR (tt.tipo_fuente = '${TipoFuente.transferencia}'
            AND (pd.proyecto_id IS NULL OR pd.proyecto_id <> ?1)))''';
  static const _gmfProyecto = '''
      po.proyecto_id = ?1 AND tt.tipo_fuente <> '${TipoFuente.ingreso}' ''';

  Future<List<TotalMensual>> _consultarTotalesProyecto(int idProyecto,
      {String? desde, String? hasta, bool porMes = false}) async {
    final db = await DatabaseHelper().ejecutor;
    final periodo = porMes ? "strftime('%Y-%m', tr.created_at)" : "''";
    final rango = desde != null && hasta != null
        ? 'AND tr.created_at >= ?2 AND tr.created_at < ?3'
        : '';

    final result = await db.rawQuery('''
        SELECT $periodo AS periodo,
          COALESCE(SUM(CASE WHEN $_ingresoProyecto THEN tr.valor ELSE 0 END), 0) AS ingresos,
          COALESCE(SUM(CASE WHEN $_egresoProyecto THEN tr.valor ELSE 0 END), 0) AS egresos,
          COALESCE(SUM(CASE WHEN $_gmfProyecto THEN COALESCE(tr.impuesto, 0) ELSE 0 END), 0) AS impuestos
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS po ON tr.portafolio_id = po.id_portafolio
        LEFT JOIN ${PortafolioSchema.table} AS pd ON tr.destino_cuenta = pd.id_portafolio
        WHERE tr.deleted_at IS NULL
          AND (po.proyecto_id = ?1 OR pd.proyecto_id = ?1)
          $rango
        ${porMes ? 'GROUP BY periodo ORDER BY periodo' : ''}
    ''', [idProyecto, if (rango.isNotEmpty) ...[desde, hasta]]);

    return result.map((e) => TotalMensual.fromJson(e)).toList();
  }

  /// Totales históricos de un proyecto (ver reglas en [_ingresoProyecto]).
  Future<TotalMensual> obtenerTotalesProyecto(int idProyecto) async =>
      (await _consultarTotalesProyecto(idProyecto)).first;

  /// Fecha mínima para consultar "todo lo anterior a".
  static const fechaInicioHistorico = '0000-01-01';

  /// Totales de un proyecto de todo lo anterior a [hasta].
  Future<TotalMensual> obtenerTotalesProyectoHasta(int idProyecto,
          {required String hasta}) async =>
      (await _consultarTotalesProyecto(idProyecto,
              desde: fechaInicioHistorico, hasta: hasta))
          .first;

  /// Totales de un proyecto por mes en el rango [desde, hasta).
  Future<List<TotalMensual>> obtenerTotalesMensualesProyecto(int idProyecto,
          {required String desde, required String hasta}) =>
      _consultarTotalesProyecto(idProyecto,
          desde: desde, hasta: hasta, porMes: true);

  static const _expresionConcepto = {
    AgrupacionConcepto.motivo: 'mo.nombre',
    AgrupacionConcepto.contraparte:
        'COALESCE(te.nombre, tr.destino_alternativo, mo.nombre)',
  };

  /// Ingresos ([ingresos] = true) o egresos agrupados por [agrupacion] en el
  /// rango [desde, hasta), de mayor a menor. Los egresos incluyen
  /// transferencias a cuentas externas; las internas no cuentan. Con
  /// [idProyecto] solo considera los portafolios de ese proyecto.
  Future<List<TotalPorConcepto>> obtenerTotalesPorConcepto({
    required String desde,
    required String hasta,
    required bool ingresos,
    required AgrupacionConcepto agrupacion,
    int? idProyecto,
  }) async {
    final db = await DatabaseHelper().ejecutor;
    final expresion = _expresionConcepto[agrupacion]!;
    final naturaleza = ingresos
        ? "tt.tipo_fuente = '${TipoFuente.ingreso}'"
        : "(tt.tipo_fuente = '${TipoFuente.egreso}' "
            "OR (tt.tipo_fuente = '${TipoFuente.transferencia}' "
            "AND tr.destino_cuenta IS NULL))";
    final filtroProyecto = idProyecto == null ? '' : 'AND po.proyecto_id = ?';

    final result = await db.rawQuery('''
        SELECT $expresion AS nombre, SUM(tr.valor) AS total, COUNT(*) AS cantidad
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS po ON tr.portafolio_id = po.id_portafolio
        LEFT JOIN ${MotivosSchema.table} AS mo ON tr.motivo_id = mo.id_motivo
        LEFT JOIN ${TerceroSchema.table} AS te ON tr.tercero_id = te.id_tercero
        WHERE tr.deleted_at IS NULL
          AND $naturaleza
          AND tr.created_at >= ? AND tr.created_at < ?
          $filtroProyecto
        GROUP BY $expresion
        ORDER BY total DESC
    ''', [desde, hasta, if (idProyecto != null) idProyecto]);

    return result.map((e) => TotalPorConcepto.fromJson(e)).toList();
  }

  /// Transferencias en el rango [desde, hasta) agrupadas por recorrido:
  /// cuenta origen → portafolio destino o cuenta externa. Con [idProyecto]
  /// solo las que salen de o llegan a ese proyecto.
  Future<List<FlujoEntreCuentas>> obtenerFlujosEntreCuentas(
      {required String desde, required String hasta, int? idProyecto}) async {
    final db = await DatabaseHelper().ejecutor;
    final filtroProyecto = idProyecto == null
        ? ''
        : 'AND (po.proyecto_id = ?3 OR pd.proyecto_id = ?3)';

    final result = await db.rawQuery('''
        SELECT po.nombre AS origen,
          COALESCE(pd.nombre, te.nombre, tr.destino_alternativo) AS destino,
          CASE WHEN tr.destino_cuenta IS NULL THEN 1 ELSE 0 END AS externo,
          SUM(tr.valor) AS total,
          SUM(COALESCE(tr.impuesto, 0)) AS impuestos,
          COUNT(*) AS cantidad
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS po ON tr.portafolio_id = po.id_portafolio
        LEFT JOIN ${PortafolioSchema.table} AS pd ON tr.destino_cuenta = pd.id_portafolio
        LEFT JOIN ${TerceroSchema.table} AS te ON tr.tercero_id = te.id_tercero
        WHERE tr.deleted_at IS NULL
          AND tt.tipo_fuente = '${TipoFuente.transferencia}'
          AND tr.created_at >= ?1 AND tr.created_at < ?2
          $filtroProyecto
        GROUP BY tr.portafolio_id, po.nombre, destino, externo
        ORDER BY total DESC
    ''', [desde, hasta, if (idProyecto != null) idProyecto]);

    return result.map((e) => FlujoEntreCuentas.fromJson(e)).toList();
  }

  /// Movimientos activos con nombres resueltos, en orden cronológico.
  /// Si se indican, filtra por el rango [desde, hasta) (`yyyy-MM-dd`).
  Future<List<MovimientoExportable>> obtenerMovimientosParaExportar(
      {String? desde, String? hasta}) async {
    final db = await DatabaseHelper().ejecutor;
    final filtros = <String>['tr.deleted_at IS NULL'];
    final argumentos = <Object>[];
    if (desde != null) {
      filtros.add('tr.created_at >= ?');
      argumentos.add(desde);
    }
    if (hasta != null) {
      filtros.add('tr.created_at < ?');
      argumentos.add(hasta);
    }

    final result = await db.rawQuery('''
        SELECT tr.id_transferencia, tr.created_at, tt.nombre AS tipo, tt.tipo_fuente,
          po.nombre AS origen, pd.nombre AS destino, tr.destino_alternativo,
          mo.nombre AS motivo, te.nombre AS tercero, tr.valor,
          COALESCE(tr.impuesto, 0) AS impuesto, tr.descripcion
        FROM $table AS tr
        JOIN ${TipoTransaccionSchema.table} AS tt ON tr.tipo_transferencia_id = tt.id_tipo_transaccion
        JOIN ${PortafolioSchema.table} AS po ON tr.portafolio_id = po.id_portafolio
        LEFT JOIN ${PortafolioSchema.table} AS pd ON tr.destino_cuenta = pd.id_portafolio
        LEFT JOIN ${MotivosSchema.table} AS mo ON tr.motivo_id = mo.id_motivo
        LEFT JOIN ${TerceroSchema.table} AS te ON tr.tercero_id = te.id_tercero
        WHERE ${filtros.join(' AND ')}
        ORDER BY tr.created_at, tr.id_transferencia
    ''', argumentos);

    return result.map((e) => MovimientoExportable.fromJson(e)).toList();
  }

  /// Construye el WHERE de [FiltroMovimientos] sobre los alias de
  /// [_fromDetalle]. Retorna la condición y sus argumentos.
  static (String, List<Object?>) _condicionFiltro(FiltroMovimientos f) {
    final condiciones = <String>['tr.deleted_at IS NULL'];
    final argumentos = <Object?>[];
    void agregar(String condicion, List<Object?> valores) {
      condiciones.add(condicion);
      argumentos.addAll(valores);
    }

    if (f.desde != null) agregar('tr.created_at >= ?', [f.desde]);
    if (f.hasta != null) agregar('tr.created_at < ?', [f.hasta]);
    if (f.tipoFuente != null) agregar('tt.tipo_fuente = ?', [f.tipoFuente]);
    if (f.idPortafolio != null) {
      agregar('(tr.portafolio_id = ? OR tr.destino_cuenta = ?)',
          [f.idPortafolio, f.idPortafolio]);
    }
    if (f.idTercero != null) agregar('tr.tercero_id = ?', [f.idTercero]);
    if (f.idMotivo != null) agregar('tr.motivo_id = ?', [f.idMotivo]);
    final texto = f.texto?.trim() ?? '';
    if (texto.isNotEmpty) {
      final patron = '%$texto%';
      agregar(
          '(tr.descripcion LIKE ? OR te.nombre LIKE ? OR mo.nombre LIKE ? '
          'OR tr.destino_alternativo LIKE ? OR po.nombre LIKE ? OR pr.nombre LIKE ?)',
          List.filled(6, patron));
    }
    return (condiciones.join(' AND '), argumentos);
  }

  /// Movimientos que cumplen [filtro], del más reciente al más antiguo.
  Future<List<TransaccionPortafolioDto>> buscarMovimientos(
      FiltroMovimientos filtro) async {
    final db = await DatabaseHelper().ejecutor;
    final (condicion, argumentos) = _condicionFiltro(filtro);
    final result = await db.rawQuery('''
        $_selectDetallePortafolio
        WHERE $condicion
        ORDER BY tr.created_at DESC, tr.id_transferencia DESC
        LIMIT ?
    ''', [...argumentos, filtro.limite]);
    return result.map((e) => TransaccionPortafolioDto.fromJson(e)).toList();
  }

  /// Totales de todos los movimientos que cumplen [filtro]. Las
  /// transferencias entre cuentas propias no son ingreso ni egreso.
  Future<TotalMensual> totalizarMovimientos(FiltroMovimientos filtro) async {
    final db = await DatabaseHelper().ejecutor;
    final (condicion, argumentos) = _condicionFiltro(filtro);
    final result = await db.rawQuery('''
        SELECT '' AS periodo,
          COALESCE(SUM(CASE WHEN tt.tipo_fuente = '${TipoFuente.ingreso}'
            THEN tr.valor ELSE 0 END), 0) AS ingresos,
          COALESCE(SUM(CASE WHEN tt.tipo_fuente = '${TipoFuente.egreso}'
            OR (tt.tipo_fuente = '${TipoFuente.transferencia}' AND tr.destino_cuenta IS NULL)
            THEN tr.valor ELSE 0 END), 0) AS egresos,
          COALESCE(SUM(CASE WHEN tt.tipo_fuente <> '${TipoFuente.ingreso}'
            THEN COALESCE(tr.impuesto, 0) ELSE 0 END), 0) AS impuestos,
          COUNT(*) AS cantidad
        $_fromDetalle
        WHERE $condicion
    ''', argumentos);
    final fila = result.first;
    return TotalMensual.fromJson(fila)..cantidad = fila['cantidad'] as int? ?? 0;
  }

  /// Últimos movimientos activos de todos los portafolios.
  Future<List<TransaccionPortafolioDto>> obtenerUltimosMovimientos(
      int limite) async {
    final db = await DatabaseHelper().ejecutor;
    final result = await db.rawQuery('''
        $_selectDetallePortafolio
        WHERE tr.deleted_at IS NULL
        ORDER BY tr.created_at DESC, tr.id_transferencia DESC
        LIMIT ?
    ''', [limite]);
    return result.map((e) => TransaccionPortafolioDto.fromJson(e)).toList();
  }

  @override
  Future<int> insert(object) async {
    Transaccion transferenciaModel = object as Transaccion;

    final db = await DatabaseHelper().ejecutor;
    final result = await db.insert(table, Auditoria.datosCreacion(transferenciaModel.toJson()));

    return result;
  }

  @override
  Future<int> update(object) async {
    Transaccion transferenciaModel = object as Transaccion;

    final db = await DatabaseHelper().ejecutor;
    final result = await db.update(
      table, Auditoria.datosActualizacion(transferenciaModel.toJson()), where: '$idTransferencia = ?',
      // Condición de actualización
      whereArgs: [transferenciaModel.idTransferencia!],
    );

    return result;
  }

  @override
  Future<int> insertAll(List object) async {
    int result = 0;

    await deleteAll();
    for (var element in object) {
      result += await insert(element);
    }
    return result;
  }

  @override
  Future<int> deleteById(int idTable) async {
    final db = await DatabaseHelper().ejecutor;
    final result =
        await Auditoria.borradoLogico(db, table, idTransferencia, idTable);

    return result;
  }
}
