import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

// Modelos
import 'package:proyecto_av/data/models/paquete_model.dart';
import 'package:proyecto_av/data/models/usuario_model.dart';
import 'package:proyecto_av/data/models/cliente_model.dart';
import 'package:proyecto_av/data/models/cita_model.dart';
import 'package:proyecto_av/data/models/venta_model.dart';

<<<<<<< HEAD
// --- IMPORTAMOS NUESTROS MODELOS ---
import '../models/paquete_model.dart';
import '../models/usuario_model.dart';
import '../models/cliente_model.dart';
import '../models/cita_model.dart';
import 'package:proyecto_av/data/models/venta_model.dart'; // <-- ¡NUEVO IMPORT!

=======
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
class DatabaseHelper {
  static final _databaseName = "CorteYPaga_Fixed_Secure.db";
  static final _databaseVersion = 1;

  // Columnas
  static const columnId = 'id';
  static const columnNombre = 'nombre';
  static const columnEmail = 'email';
  static const columnPassword = 'password';
  static const columnRole = 'role';
  static const columnTelefono = 'telefono';
  static const columnPreferencias = 'preferencias';
  static const columnDescripcion = 'descripcion';
  static const columnPrecio = 'precio';
  static const columnImagePath = 'imagePath';
  static const columnIdCliente = 'idCliente';
  static const columnIdPaquete = 'idPaquete';
  static const columnFechaHora = 'fechaHora';
  static const columnEstado = 'estado';
  static const columnCustomDescripcion = 'customDescripcion';
  static const columnCustomPrecio = 'customPrecio';
  static const columnIdCita = 'idCita';
  static const columnMontoTotal = 'montoTotal';
  static const columnFechaVenta = 'fechaVenta';
  static const columnMetodoPago = 'metodoPago';

  // Tablas
  static const tableUsuarios = 'usuarios';
  static const tableClientes = 'clientes';
  static const tablePaquetes = 'paquetes';
  static const tableCitas = 'citas';
  static const tableVentas = 'ventas';

<<<<<<< HEAD
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
  static final columnImagePath = 'imagePath';

  // --- COLUMNAS TABLA CITAS ---
  static final columnIdCliente = 'idCliente';
  static final columnIdPaquete = 'idPaquete';
  static final columnFechaHora = 'fechaHora';
  static final columnEstado = 'estado';
  static final columnCustomDescripcion = 'customDescripcion';
  static final columnCustomPrecio = 'customPrecio';

  // --- COLUMNAS TABLA VENTAS ---
  static final columnIdCita = 'idCita';
  static final columnMontoTotal = 'montoTotal';
  static final columnFechaVenta = 'fechaVenta';
  static final columnMetodoPago = 'metodoPago'; // (Aún no lo usamos, pero está listo)

  // --- INICIO DEL PATRÓN SINGLETON ---
=======
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
<<<<<<< HEAD
    // ... (Tablas Usuarios, Clientes, Paquetes - sin cambios) ...
=======
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
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

<<<<<<< HEAD
    // --- Tabla Citas ---
=======
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
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

<<<<<<< HEAD
    // --- Tabla Ventas ---
=======
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
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

  // Hash seguro
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

<<<<<<< HEAD
  // ... (Usuarios, Paquetes, Clientes, Citas - sin cambios) ...
=======
  // USUARIOS
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
  Future<int> insertUsuario(Usuario usuario) async {
    Database db = await instance.database;
    var row = usuario.toMap();
    row[columnPassword] = _hashPassword(usuario.password);
    return await db.insert(tableUsuarios, row);
  }

  Future<Usuario?> getUsuario(String email, String password) async {
    Database db = await instance.database;
    String hashed = _hashPassword(password);

    final maps = await db.query(
      tableUsuarios,
      where: '$columnEmail = ? AND $columnPassword = ?',
      whereArgs: [email, hashed],
    );

    if (maps.isNotEmpty) return Usuario.fromMap(maps.first);
    return null;
  }
<<<<<<< HEAD
=======

  Future<int> updateUsuarioPassword({
    required int id,
    required String oldPassword,
    required String newPassword,
  }) async {
    Database db = await instance.database;

    String hashedOld = _hashPassword(oldPassword);
    String hashedNew = _hashPassword(newPassword);

    return await db.update(
      tableUsuarios,
      {columnPassword: hashedNew},
      where: '$columnId = ? AND $columnPassword = ?',
      whereArgs: [id, hashedOld],
    );
  }

  // PAQUETES
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
  Future<int> insertPaquete(Paquete paquete) async {
    Database db = await instance.database;
    final map = paquete.toMap(); // ← YA incluye imagePath JSON
    return await db.insert(tablePaquetes, map);
  }

  Future<List<Paquete>> getAllPaquetes() async {
    Database db = await instance.database;
    final maps = await db.query(tablePaquetes);

    return List.generate(maps.length, (i) {
      return Paquete.fromMap(maps[i]); // ← TODO se carga desde el modelo
    });
  }

  Future<int> updatePaquete(Paquete paquete) async {
    Database db = await instance.database;
    final map = paquete.toMap();
    return await db.update(
      tablePaquetes,
      map,
      where: '$columnId = ?',
      whereArgs: [paquete.id],
    );
  }

  Future<int> deletePaquete(int id) async {
    Database db = await instance.database;
    return await db.delete(tablePaquetes, where: '$columnId = ?', whereArgs: [id]);
  }

  // CLIENTES
  Future<int> insertCliente(Cliente cliente) async {
    Database db = await instance.database;
    return await db.insert(tableClientes, cliente.toMap());
  }

  Future<List<Cliente>> getAllClientes() async {
    Database db = await instance.database;
    final maps = await db.query(tableClientes);
    return List.generate(maps.length, (i) => Cliente.fromMap(maps[i]));
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
    return await db.delete(tableClientes, where: '$columnId = ?', whereArgs: [id]);
  }

  // CITAS
  Future<int> insertCita(Cita cita) async {
    Database db = await instance.database;
    return await db.insert(tableCitas, cita.toMap());
  }

  Future<List<Cita>> getAllCitas() async {
    Database db = await instance.database;
    final maps = await db.query(tableCitas);
    return List.generate(maps.length, (i) => Cita.fromMap(maps[i]));
  }

  Future<List<Cita>> getCitasPorDia(DateTime dia) async {
    Database db = await instance.database;
    String diaString = dia.toIso8601String().substring(0, 10);

    final maps = await db.query(
      tableCitas,
      where: '$columnFechaHora LIKE ?',
      whereArgs: ['$diaString%'],
      orderBy: '$columnFechaHora ASC',
    );

    return List.generate(maps.length, (i) => Cita.fromMap(maps[i]));
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
    return await db.delete(tableCitas, where: '$columnId = ?', whereArgs: [id]);
  }

<<<<<<< HEAD
  // --- Métodos CRUD para Ventas --- // <-- ¡SECCIÓN NUEVA!

  // Insertar una venta
=======
  // VENTAS
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
  Future<int> insertVenta(Venta venta) async {
    Database db = await instance.database;
    return await db.insert(tableVentas, venta.toMap());
  }

<<<<<<< HEAD
  // Obtener todas las ventas
  Future<List<Venta>> getAllVentas() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableVentas);

    return List.generate(maps.length, (i) {
      return Venta.fromMap(maps[i]);
    });
  }

  // Obtener ventas por rango de fechas (¡Para los reportes!)
  Future<List<Venta>> getVentasPorRango(DateTime inicio, DateTime fin) async {
    Database db = await instance.database;

    // Aseguramos que la fecha 'fin' cubra todo el día
    DateTime finDelDia = DateTime(fin.year, fin.month, fin.day, 23, 59, 59);

    final List<Map<String, dynamic>> maps = await db.query(
=======
  Future<List<Venta>> getAllVentas() async {
    Database db = await instance.database;
    final maps = await db.query(tableVentas);

    return List.generate(maps.length, (i) => Venta.fromMap(maps[i]));
  }

  Future<List<Venta>> getVentasPorRango(DateTime inicio, DateTime fin) async {
    Database db = await instance.database;

    DateTime finDelDia = DateTime(fin.year, fin.month, fin.day, 23, 59, 59);

    final maps = await db.query(
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
      tableVentas,
      where: '$columnFechaVenta BETWEEN ? AND ?',
      whereArgs: [inicio.toIso8601String(), finDelDia.toIso8601String()],
      orderBy: '$columnFechaVenta DESC',
    );

<<<<<<< HEAD
    return List.generate(maps.length, (i) {
      return Venta.fromMap(maps[i]);
    });
  }

// (No pondremos 'update' o 'delete' para ventas,
// ya que un registro financiero no debe modificarse ni borrarse,
// en todo caso se cancela con otro movimiento, pero eso es más avanzado)
}
=======
    return List.generate(maps.length, (i) => Venta.fromMap(maps[i]));
  }

  Future<List<Venta>> getVentasDelDia(DateTime dia) async {
    return getVentasPorRango(dia, dia);
  }
}
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
