import '../database/database_helper.dart';
class Cita {
  final int? id;
  final int idCliente;
  final int? idPaquete;
  final String fechaHora;
  final String estado;
  final String? customDescripcion;
  final double? customPrecio;

  Cita({
    this.id,
    required this.idCliente,
    this.idPaquete,
    required this.fechaHora,
    this.estado = 'programada',
    this.customDescripcion,
    this.customPrecio,
  });

  // Convertir un Map (de la BD) a un objeto Cita
  factory Cita.fromMap(Map<String, dynamic> map) {
    return Cita(
      id: map[DatabaseHelper.columnId],
      idCliente: map[DatabaseHelper.columnIdCliente],
      idPaquete: map[DatabaseHelper.columnIdPaquete],
      fechaHora: map[DatabaseHelper.columnFechaHora],
      estado: map[DatabaseHelper.columnEstado],
      customDescripcion: map[DatabaseHelper.columnCustomDescripcion],
      customPrecio: map[DatabaseHelper.columnCustomPrecio],
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
      DatabaseHelper.columnCustomDescripcion: customDescripcion,
      DatabaseHelper.columnCustomPrecio: customPrecio,
    };
  }

  // --- ¡NUEVA FUNCIÓN! ---
  // Clonar el objeto Cita con valores diferentes
  Cita copyWith({
    int? id,
    int? idCliente,
    int? idPaquete,
    String? fechaHora,
    String? estado,
    String? customDescripcion,
    double? customPrecio,
  }) {
    return Cita(
      id: id ?? this.id,
      idCliente: idCliente ?? this.idCliente,
      idPaquete: idPaquete ?? this.idPaquete,
      fechaHora: fechaHora ?? this.fechaHora,
      estado: estado ?? this.estado,
      customDescripcion: customDescripcion ?? this.customDescripcion,
      customPrecio: customPrecio ?? this.customPrecio,
    );
  }
}