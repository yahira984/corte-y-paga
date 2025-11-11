import '../database/database_helper.dart';

class Cita {
  final int? id;
  final int idCliente;
  final int idPaquete;
  final String fechaHora; // Usaremos String (formato ISO8601) para guardar en SQLite
  final String estado;

  Cita({
    this.id,
    required this.idCliente,
    required this.idPaquete,
    required this.fechaHora, // Ej: '2025-11-10T14:30:00'
    this.estado = 'programada',
  });

  // Convertir un Map (de la BD) a un objeto Cita
  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map[DatabaseHelper.columnId],
      idCliente: map[DatabaseHelper.columnIdCliente],
      idPaquete: map[DatabaseHelper.columnIdPaquete],
      fechaHora: map[DatabaseHelper.columnFechaHora],
      estado: map[DatabaseHelper.columnEstado],
    );
  }

  // Convertir un objeto Cita a un Map (para la BD)
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnIdCliente: idCliente,
      DatabaseHelper.columnIdPaquete: idPaquete,
      DatabaseHelper.columnFechaHora: fechaHora,
      DatabaseHelper.columnEstado: estado,
    };
  }
}