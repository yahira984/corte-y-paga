import '../database/database_helper.dart';

class Cliente {
  final int? id;
  final String nombre;
  final String? telefono;
  final String? preferencias;

  Cliente({
    this.id,
    required this.nombre,
    this.telefono,
    this.preferencias,
  });

  // Convertir un Map (de la BD) a un objeto Cliente
  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map[DatabaseHelper.columnId],
      nombre: map[DatabaseHelper.columnNombre],
      telefono: map[DatabaseHelper.columnTelefono],
      preferencias: map[DatabaseHelper.columnPreferencias],
    );
  }

  // Convertir un objeto Cliente a un Map (para la BD)
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnNombre: nombre,
      DatabaseHelper.columnTelefono: telefono,
      DatabaseHelper.columnPreferencias: preferencias,
    };
  }
}