import '../database/database_helper.dart';

class Usuario {
  final int? id;
  final String nombre;
  final String email;
  final String password; // En el futuro, esto debería ser un hash
  final String? role;

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
    this.role,
  });

  // Convertir un Map (de la BD) a un objeto Usuario
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map[DatabaseHelper.columnId],
      nombre: map[DatabaseHelper.columnNombre],
      email: map[DatabaseHelper.columnEmail],
      password: map[DatabaseHelper.columnPassword],
      role: map[DatabaseHelper.columnRole],
    );
  }

  // Convertir un objeto Usuario a un Map (para la BD)
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnNombre: nombre,
      DatabaseHelper.columnEmail: email,
      DatabaseHelper.columnPassword: password,
      DatabaseHelper.columnRole: role,
    };
  }
}