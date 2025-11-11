import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'corte_y_paga.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        correo TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Tabla de citas
    await db.execute('''
      CREATE TABLE citas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER,
        fecha TEXT NOT NULL,
        hora TEXT NOT NULL,
        servicio TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
      )
    ''');

    // Tabla de ventas
    await db.execute('''
      CREATE TABLE ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER,
        monto REAL NOT NULL,
        fecha TEXT NOT NULL,
        metodo_pago TEXT,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
      )
    ''');

    // Tabla de paquetes
    await db.execute('''
      CREATE TABLE paquetes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        precio REAL NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // ✅ Registrar usuario (solo si no existe)
  Future<int> registerUser(Map<String, dynamic> user) async {
    final db = await database;

    final existingUser = await db.query(
      'usuarios',
      where: 'correo = ?',
      whereArgs: [user['correo']],
    );

    if (existingUser.isNotEmpty) {
      return -1; // Ya existe
    }

    return await db.insert('usuarios', user);
  }

  // ✅ Login de usuario
  Future<Map<String, dynamic>?> loginUser(String correo, String password) async {
    final db = await database;

    final result = await db.query(
      'usuarios',
      where: 'correo = ? AND password = ?',
      whereArgs: [correo, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // ✅ Consultas generales
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('usuarios');
  }

  Future<List<Map<String, dynamic>>> getCitas() async {
    final db = await database;
    return await db.query('citas');
  }

  Future<List<Map<String, dynamic>>> getVentas() async {
    final db = await database;
    return await db.query('ventas');
  }

  Future<List<Map<String, dynamic>>> getPaquetes() async {
    final db = await database;
    return await db.query('paquetes');
  }
}
