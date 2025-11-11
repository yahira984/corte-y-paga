import '../database/database_helper.dart';

class Venta {
  final int? id;
  final int? idCita; // Puede ser nulo si es una venta "directa" sin cita
  final double montoTotal;
  final String fechaVenta; // Usaremos String (formato ISO8601)
  final String? metodoPago;

  Venta({
    this.id,
    this.idCita,
    required this.montoTotal,
    required this.fechaVenta,
    this.metodoPago,
  });

  // Convertir un Map (de la BD) a un objeto Venta
  factory Venta.fromMap(Map<String, dynamic> map) {
    return Venta(
      id: map[DatabaseHelper.columnId],
      idCita: map[DatabaseHelper.columnIdCita],
      montoTotal: map[DatabaseHelper.columnMontoTotal],
      fechaVenta: map[DatabaseHelper.columnFechaVenta],
      metodoPago: map[DatabaseHelper.columnMetodoPago],
    );
  }

  // Convertir un objeto Venta a un Map (para la BD)
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnIdCita: idCita,
      DatabaseHelper.columnMontoTotal: montoTotal,
      DatabaseHelper.columnFechaVenta: fechaVenta,
      DatabaseHelper.columnMetodoPago: metodoPago,
    };
  }
}