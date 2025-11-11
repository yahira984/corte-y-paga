import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// --- IMPORTAMOS NUESTROS MODELOS ---
import '../models/paquete_model.dart';
import '../models/usuario_model.dart';
// TODO: Importar los otros modelos (cliente, cita, venta) cuando los usemos

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

  // --- COLUMNAS TABLA USUARIOS ---
  static final columnEmail = 'email';
  static final columnPassword = 'password';
  static final columnRole = 'role';

  // --- COLUMNAS TABLA CLIENTES ---
  static final columnTelefono = 'telefono';
  static final columnPreferencias = 'preferencias';

  // --- COLUMNAS TABLA PAQUETES ---
  static final columnDescripcion = 'descripcion';
  static final columnPrecio = 'precio';
  static final columnImagePath = 'imagePath'; // <-- ¡NUEVO!

  // --- COLUMNAS TABLA CITAS ---
  static final columnIdCliente = 'idCliente';
  static final columnIdPaquete = 'idPaquete';
  static final columnFechaHora = 'fechaHora';
  static final columnEstado = 'estado';

  // --- COLUMNAS TABLA VENTAS ---
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

  // Método privado para inicializar la base de datos
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
    // Tabla Usuarios (Barberos)
    await db.execute('''
      CREATE TABLE $tableUsuarios (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNombre TEXT NOT NULL,
        $columnEmail TEXT NOT NULL UNIQUE,
        $columnPassword TEXT NOT NULL,
        $columnRole TEXT DEFAULT 'barbero'
      )
    ''');

    // Tabla Clientes
    await db.execute('''
      CREATE TABLE $tableClientes (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNombre TEXT NOT NULL,
        $columnTelefono TEXT,
        $columnPreferencias TEXT
      )
    ''');

    // Tabla Paquetes (Servicios)
    await db.execute('''
      CREATE TABLE $tablePaquetes (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNombre TEXT NOT NULL,
        $columnDescripcion TEXT,
        $columnPrecio REAL NOT NULL,
        $columnImagePath TEXT 
      )
    '''); // <-- ¡SE ACTUALIZÓ ESTA TABLA!

    // Tabla Citas
    await db.execute('''
      CREATE TABLE $tableCitas (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnIdCliente INTEGER NOT NULL,
        $columnIdPaquete INTEGER NOT NULL,
        $columnFechaHora TEXT NOT NULL,
        $columnEstado TEXT NOT NULL DEFAULT 'programada',
        FOREIGN KEY ($columnIdCliente) REFERENCES $tableClientes ($columnId),
        FOREIGN KEY ($columnIdPaquete) REFERENCES $tablePaquetes ($columnId)
      )
    ''');

    // Tabla Ventas
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

  // Insertar un usuario (Registro)
  Future<int> insertUsuario(Usuario usuario) async {
    Database db = await instance.database;
    return await db.insert(tableUsuarios, usuario.toMap());
  }

  // Obtener un usuario (Login)
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

  // --- Métodos CRUD para Paquetes (Servicios) ---

  // Insertar un paquete
  Future<int> insertPaquete(Paquete paquete) async {
    Database db = await instance.database;
    return await db.insert(tablePaquetes, paquete.toMap());
  }

  // Obtener todos los paquetes
  Future<List<Paquete>> getAllPaquetes() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tablePaquetes);

    return List.generate(maps.length, (i) {
      return Paquete.fromMap(maps[i]);
    });
  }

  // Actualizar un paquete
  Future<int> updatePaquete(Paquete paquete) async {
    Database db = await instance.database;
    return await db.update(
      tablePaquetes,
      paquete.toMap(),
      where: '$columnId = ?',
      whereArgs: [paquete.id],
    );
  }

  // Eliminar un paquete
  Future<int> deletePaquete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      tablePaquetes,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

// TODO: Añadir métodos CRUD para Clientes, Citas y Ventas
}