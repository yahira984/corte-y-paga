import '../database/database_helper.dart';

class Paquete {
  final int? id;
  final String nombre;
  final String? descripcion;
  final double precio;

  Paquete({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
  });

  // Convertir un Map (de la BD) a un objeto Paquete
  factory Paquete.fromMap(Map<String, dynamic> map) {
    return Paquete(
      id: map[DatabaseHelper.columnId],
      nombre: map[DatabaseHelper.columnNombre],
      descripcion: map[DatabaseHelper.columnDescripcion],
      precio: map[DatabaseHelper.columnPrecio],
    );
  }

  // Convertir un objeto Paquete a un Map (para la BD)
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnNombre: nombre,
      DatabaseHelper.columnDescripcion: descripcion,
      DatabaseHelper.columnPrecio: precio,
    };
  }
}