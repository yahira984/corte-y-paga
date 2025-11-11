import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// --- IMPORTAMOS NUESTROS MODELOS ---
import '../models/paquete_model.dart';
import '../models/usuario_model.dart';
import '../models/cliente_model.dart';
import '../models/cita_model.dart';
import 'package:proyecto_av/data/models/venta_model.dart'; // <-- ¡NUEVO IMPORT!
class DatabaseHelper {
  static final _databaseName = "CorteYPaga.db";
  static final _databaseVersion = 1;

  // --- NOMBRES DE TABLAS ---
  static final tableUsuarios = 'usuarios';
  static final tableClientes = 'clientes';
  static final tablePaquetes = 'paquetes';
  static final tableCitas = 'citas';
  static final tableVentas = 'ventas';

  // --- NOMBRES DE COLUMNAS COMUNES ---
  static final columnId = 'id';
  static final columnNombre = 'nombre';

  // ... (Todas las demás columnas sin cambios) ...
  static final columnEmail = 'email';
  static final columnPassword = 'password';
  static final columnRole = 'role';
  static final columnTelefono = 'telefono';
  static final columnPreferencias = 'preferencias';
  static final columnDescripcion = 'descripcion';
  static final columnPrecio = 'precio';
  static final columnImagePath = 'imagePath';
  static final columnIdCliente = 'idCliente';
  static final columnIdPaquete = 'idPaquete';
  static final columnFechaHora = 'fechaHora';
  static final columnEstado = 'estado';
  static final columnCustomDescripcion = 'customDescripcion';
  static final columnCustomPrecio = 'customPrecio';
  static final columnIdCita = 'idCita';
  static final columnMontoTotal = 'montoTotal';
  static final columnFechaVenta = 'fechaVenta';
  static final columnMetodoPago = 'metodoPago';

  // --- INICIO DEL PATRÓN SINGLETON ---
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  // --- FIN DEL PATRÓN SINGLETON ---

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL para crear las tablas
  Future _onCreate(Database db, int version) async {
    // ... (Creación de todas las tablas - sin cambios) ...
    await db.execute('''
      CREATE TABLE $tableUsuarios (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNombre TEXT NOT NULL,
        $columnEmail TEXT NOT NULL UNIQUE,
        $columnPassword TEXT NOT NULL,
        $columnRole TEXT DEFAULT 'barbero'
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableClientes (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNombre TEXT NOT NULL,
        $columnTelefono TEXT,
        $columnPreferencias TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $tablePaquetes (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNombre TEXT NOT NULL,
        $columnDescripcion TEXT,
        $columnPrecio REAL NOT NULL,
        $columnImagePath TEXT 
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableCitas (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnIdCliente INTEGER NOT NULL,
        $columnIdPaquete INTEGER, 
        $columnFechaHora TEXT NOT NULL,
        $columnEstado TEXT NOT NULL DEFAULT 'programada',
        $columnCustomDescripcion TEXT,
        $columnCustomPrecio REAL,
        FOREIGN KEY ($columnIdCliente) REFERENCES $tableClientes ($columnId),
        FOREIGN KEY ($columnIdPaquete) REFERENCES $tablePaquetes ($columnId)
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableVentas (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnIdCita INTEGER,
        $columnMontoTotal REAL NOT NULL,
        $columnFechaVenta TEXT NOT NULL,
        $columnMetodoPago TEXT,
        FOREIGN KEY ($columnIdCita) REFERENCES $tableCitas ($columnId)
      )
    ''');
  }

  // --- INICIO MÉTODOS CRUD ---

  // --- Métodos CRUD para Usuarios ---
  Future<int> insertUsuario(Usuario usuario) async {
    Database db = await instance.database;
    return await db.insert(tableUsuarios, usuario.toMap());
  }
  Future<Usuario?> getUsuario(String email, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      tableUsuarios,
      where: '$columnEmail = ? AND $columnPassword = ?',
      whereArgs: [email, password],
    );
    if (results.isNotEmpty) {
      return Usuario.fromMap(results.first);
    }
    return null;
  }

  // --- ¡NUEVA FUNCIÓN! ---
  // Actualizar la contraseña de un usuario
  Future<int> updateUsuarioPassword({
    required int id,
    required String oldPassword,
    required String newPassword,
  }) async {
    Database db = await instance.database;
    // Actualiza solo si el ID Y la contraseña antigua coinciden
    return await db.update(
      tableUsuarios,
      { columnPassword: newPassword },
      where: '$columnId = ? AND $columnPassword = ?',
      whereArgs: [id, oldPassword],
    );
  }

  // ... (Métodos CRUD de Paquetes, Clientes, Citas, Ventas - sin cambios) ...
  Future<int> insertPaquete(Paquete paquete) async {
    Database db = await instance.database;
    return await db.insert(tablePaquetes, paquete.toMap());
  }
  Future<List<Paquete>> getAllPaquetes() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tablePaquetes);
    return List.generate(maps.length, (i) {
      return Paquete.fromMap(maps[i]);
    });
  }
  Future<int> updatePaquete(Paquete paquete) async {
    Database db = await instance.database;
    return await db.update(
      tablePaquetes,
      paquete.toMap(),
      where: '$columnId = ?',
      whereArgs: [paquete.id],
    );
  }
  Future<int> deletePaquete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      tablePaquetes,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  Future<int> insertCliente(Cliente cliente) async {
    Database db = await instance.database;
    return await db.insert(tableClientes, cliente.toMap());
  }
  Future<List<Cliente>> getAllClientes() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableClientes);
    return List.generate(maps.length, (i) {
      return Cliente.fromMap(maps[i]);
    });
  }
  Future<int> updateCliente(Cliente cliente) async {
    Database db = await instance.database;
    return await db.update(
      tableClientes,
      cliente.toMap(),
      where: '$columnId = ?',
      whereArgs: [cliente.id],
    );
  }
  Future<int> deleteCliente(int id) async {
    Database db = await instance.database;
    return await db.delete(
      tableClientes,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  Future<int> insertCita(Cita cita) async {
    Database db = await instance.database;
    return await db.insert(tableCitas, cita.toMap());
  }
  Future<List<Cita>> getAllCitas() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableCitas);
    return List.generate(maps.length, (i) {
      return Cita.fromMap(maps[i]);
    });
  }
  Future<List<Cita>> getCitasPorDia(DateTime dia) async {
    Database db = await instance.database;
    String diaString = dia.toIso8601String().substring(0, 10);
    final List<Map<String, dynamic>> maps = await db.query(
      tableCitas,
      where: '$columnFechaHora LIKE ?',
      whereArgs: ['$diaString%'],
      orderBy: '$columnFechaHora ASC',
    );
    return List.generate(maps.length, (i) {
      return Cita.fromMap(maps[i]);
    });
  }
  Future<int> updateCita(Cita cita) async {
    Database db = await instance.database;
    return await db.update(
      tableCitas,
      cita.toMap(),
      where: '$columnId = ?',
      whereArgs: [cita.id],
    );
  }
  Future<int> deleteCita(int id) async {
    Database db = await instance.database;
    return await db.delete(
      tableCitas,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  Future<int> insertVenta(Venta venta) async {
    Database db = await instance.database;
    return await db.insert(tableVentas, venta.toMap());
  }
  Future<List<Venta>> getAllVentas() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableVentas);
    return List.generate(maps.length, (i) {
      return Venta.fromMap(maps[i]);
    });
  }
  Future<List<Venta>> getVentasPorRango(DateTime inicio, DateTime fin) async {
    Database db = await instance.database;
    DateTime finDelDia = DateTime(fin.year, fin.month, fin.day, 23, 59, 59);
    final List<Map<String, dynamic>> maps = await db.query(
      tableVentas,
      where: '$columnFechaVenta BETWEEN ? AND ?',
      whereArgs: [inicio.toIso8601String(), finDelDia.toIso8601String()],
      orderBy: '$columnFechaVenta DESC',
    );
    return List.generate(maps.length, (i) {
      return Venta.fromMap(maps[i]);
    });
  }
}