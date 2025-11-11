import '../database/database_helper.dart';

class Cita {
  final int? id;
  final int idCliente;
  final int? idPaquete; // <-- ¡CAMBIO! Ahora es nullable
  final String fechaHora;
  final String estado;
  final String? customDescripcion; // <-- ¡NUEVO!
  final double? customPrecio;       // <-- ¡NUEVO!

  Cita({
    this.id,
    required this.idCliente,
    this.idPaquete, // <-- ¡CAMBIO!
    required this.fechaHora,
    this.estado = 'programada',
    this.customDescripcion, // <-- ¡NUEVO!
    this.customPrecio,       // <-- ¡NUEVO!
  });

  // Convertir un Map (de la BD) a un objeto Cita
  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map[DatabaseHelper.columnId],
      idCliente: map[DatabaseHelper.columnIdCliente],
      idPaquete: map[DatabaseHelper.columnIdPaquete], // <-- ¡CAMBIO!
      fechaHora: map[DatabaseHelper.columnFechaHora],
      estado: map[DatabaseHelper.columnEstado],
      customDescripcion: map[DatabaseHelper.columnCustomDescripcion], // <-- ¡NUEVO!
      customPrecio: map[DatabaseHelper.columnCustomPrecio],       // <-- ¡NUEVO!
    );
  }

  // Convertir un objeto Cita a un Map (para la BD)
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnIdCliente: idCliente,
      DatabaseHelper.columnIdPaquete: idPaquete, // <-- ¡CAMBIO!
      DatabaseHelper.columnFechaHora: fechaHora,
      DatabaseHelper.columnEstado: estado,
      DatabaseHelper.columnCustomDescripcion: customDescripcion, // <-- ¡NUEVO!
      DatabaseHelper.columnCustomPrecio: customPrecio,       // <-- ¡NUEVO!
    };
  }
}