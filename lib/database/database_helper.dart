
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  // =========================
  // INICIALIZACIÓN DE LA BASE DE DATOS
  // =========================

  Future<Database> _initDatabase() async {
    final ruta = join(
      await getDatabasesPath(),
      'cromalia_style.db',
    );

    return openDatabase(
      ruta,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE clientes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            telefono TEXT NOT NULL,
            correo TEXT,
            observaciones TEXT,
            fecha_registro TEXT NOT NULL
          )
        ''');

        await _crearTablaCitas(db);
        await _crearTablaAutorizaciones(db);
        await _crearTablaFichasCapilares(db);
      },
      onUpgrade: (db, versionAnterior, versionNueva) async {
        if (versionAnterior < 2) {
          await _crearTablaCitas(db);
        }

        if (versionAnterior < 3) {
          await _crearTablaAutorizaciones(db);
        }

        if (versionAnterior < 4) {
          await _crearTablaFichasCapilares(db);
        }
      },
    );
  }

  // =========================
  // TABLA DE CITAS
  // =========================

  Future<void> _crearTablaCitas(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE citas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        servicio TEXT NOT NULL,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        precio REAL NOT NULL DEFAULT 0,
        estado TEXT NOT NULL DEFAULT 'Pendiente',
        observaciones TEXT,
        FOREIGN KEY (cliente_id)
          REFERENCES clientes (id)
          ON DELETE RESTRICT
      )
    ''');
  }

  // =========================
  // TABLA DE AUTORIZACIONES
  // =========================

  Future<void> _crearTablaAutorizaciones(
    DatabaseExecutor db,
  ) async {
    await db.execute('''
      CREATE TABLE autorizaciones_prueba (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        fecha_autorizacion TEXT NOT NULL,
        version_texto TEXT NOT NULL,
        finalidad TEXT NOT NULL,
        texto_autorizacion TEXT NOT NULL,
        aceptada INTEGER NOT NULL CHECK (aceptada IN (0, 1)),
        FOREIGN KEY (cliente_id)
          REFERENCES clientes (id)
          ON DELETE RESTRICT
      )
    ''');
  }

  // =========================
  // TABLA DE FICHAS CAPILARES
  // =========================

  Future<void> _crearTablaFichasCapilares(
    DatabaseExecutor db,
  ) async {
    await db.execute('''
      CREATE TABLE fichas_capilares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        textura TEXT NOT NULL,
        grosor TEXT NOT NULL,
        estado_cabello TEXT NOT NULL,
        elasticidad TEXT NOT NULL,
        tratamientos_anteriores TEXT,
        observaciones_profesional TEXT,
        recomendaciones TEXT,
        fecha_evaluacion TEXT NOT NULL,
        FOREIGN KEY (cliente_id)
          REFERENCES clientes (id)
          ON DELETE RESTRICT
      )
    ''');
  }

  // =========================
  // GESTIÓN DE AUTORIZACIONES
  // =========================

  Future<int> registrarAutorizacionPrueba({
    required int clienteId,
    required String versionTexto,
    required String finalidad,
    required String textoAutorizacion,
  }) async {
    final db = await database;

    return db.insert('autorizaciones_prueba', {
      'cliente_id': clienteId,
      'fecha_autorizacion': DateTime.now().toIso8601String(),
      'version_texto': versionTexto,
      'finalidad': finalidad,
      'texto_autorizacion': textoAutorizacion,
      'aceptada': 1,
    });
  }

  Future<List<Map<String, dynamic>>>
      obtenerAutorizacionesPrueba() async {
    final db = await database;

    return db.query(
      'autorizaciones_prueba',
      orderBy: 'fecha_autorizacion DESC',
    );
  }

  // =========================
  // GESTIÓN DE CLIENTES
  // =========================

  Future<int> insertarCliente(
    Map<String, String> cliente,
  ) async {
    final db = await database;

    return db.insert('clientes', {
      'nombre': cliente['nombre'] ?? '',
      'telefono': cliente['telefono'] ?? '',
      'correo': cliente['correo'] ?? '',
      'observaciones': cliente['observaciones'] ?? '',
      'fecha_registro': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> obtenerClientes() async {
    final db = await database;

    return db.query(
      'clientes',
      orderBy: 'id DESC',
    );
  }

  Future<Map<String, dynamic>?> obtenerClientePorId(
    int id,
  ) async {
    final db = await database;

    final resultado = await db.query(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  Future<int> eliminarCliente(int id) async {
    final db = await database;

    return db.delete(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // GESTIÓN DE CITAS
  // =========================

  Future<bool> existeCitaEnHorario({
    required String fecha,
    required String hora,
    int? excluirCitaId,
  }) async {
    final db = await database;

    final condiciones = <String>[
      'fecha = ?',
      'hora = ?',
      'estado != ?',
    ];

    final argumentos = <Object?>[
      fecha,
      hora,
      'Cancelada',
    ];

    if (excluirCitaId != null) {
      condiciones.add('id != ?');
      argumentos.add(excluirCitaId);
    }

    final resultado = await db.query(
      'citas',
      columns: ['id'],
      where: condiciones.join(' AND '),
      whereArgs: argumentos,
      limit: 1,
    );

    return resultado.isNotEmpty;
  }

  Future<int> insertarCita(
    Map<String, dynamic> cita,
  ) async {
    final db = await database;

    return db.insert('citas', {
      'cliente_id': cita['cliente_id'],
      'servicio': cita['servicio'],
      'fecha': cita['fecha'],
      'hora': cita['hora'],
      'precio': cita['precio'] ?? 0,
      'estado': cita['estado'] ?? 'Pendiente',
      'observaciones': cita['observaciones'] ?? '',
    });
  }

  Future<List<Map<String, dynamic>>> obtenerCitas() async {
    final db = await database;

    return db.rawQuery('''
      SELECT
        citas.*,
        clientes.nombre AS nombre_cliente,
        clientes.telefono AS telefono_cliente
      FROM citas
      INNER JOIN clientes
        ON citas.cliente_id = clientes.id
      ORDER BY citas.fecha ASC, citas.hora ASC
    ''');
  }

  Future<Map<String, dynamic>?> obtenerCitaPorId(
    int id,
  ) async {
    final db = await database;

    final resultado = await db.query(
      'citas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    return resultado.first;
  }

  Future<int> actualizarEstadoCita(
    int id,
    String estado,
  ) async {
    final db = await database;

    return db.update(
      'citas',
      {'estado': estado},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminarCita(int id) async {
    final db = await database;

    return db.delete(
      'citas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // GESTIÓN DE FICHAS CAPILARES
  // =========================

  Future<int> insertarFichaCapilar(
    Map<String, dynamic> ficha,
  ) async {
    final db = await database;

    return db.insert('fichas_capilares', {
      'cliente_id': ficha['cliente_id'],
      'textura': ficha['textura'],
      'grosor': ficha['grosor'],
      'estado_cabello': ficha['estado_cabello'],
      'elasticidad': ficha['elasticidad'],
      'tratamientos_anteriores':
          ficha['tratamientos_anteriores'] ?? '',
      'observaciones_profesional':
          ficha['observaciones_profesional'] ?? '',
      'recomendaciones': ficha['recomendaciones'] ?? '',
      'fecha_evaluacion': DateTime.now().toIso8601String(),
    });
  }

  Future<int> actualizarFichaCapilar(
    int id,
    Map<String, dynamic> ficha,
  ) async {
    final db = await database;

    return await db.update(
      'fichas_capilares',
      {
        'cliente_id': ficha['cliente_id'],
        'textura': ficha['textura'],
        'grosor': ficha['grosor'],
        'estado_cabello': ficha['estado_cabello'],
        'elasticidad': ficha['elasticidad'],
        'tratamientos_anteriores':
            ficha['tratamientos_anteriores'] ?? '',
        'observaciones_profesional':
            ficha['observaciones_profesional'] ?? '',
        'recomendaciones': ficha['recomendaciones'] ?? '',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>>
      obtenerFichasCapilares() async {
    final db = await database;

    return db.rawQuery('''
      SELECT
        fichas_capilares.*,
        clientes.nombre AS nombre_cliente,
        clientes.telefono AS telefono_cliente
      FROM fichas_capilares
      INNER JOIN clientes
        ON fichas_capilares.cliente_id = clientes.id
      ORDER BY fichas_capilares.fecha_evaluacion DESC
    ''');
  }

  Future<List<Map<String, dynamic>>>
      obtenerFichasCapilaresPorCliente(
    int clienteId,
  ) async {
    final db = await database;

    return db.query(
      'fichas_capilares',
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
      orderBy: 'fecha_evaluacion DESC',
    );
  }
}

