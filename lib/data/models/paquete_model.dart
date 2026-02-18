import 'dart:convert';

class Paquete {
  final int? id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final List<String> rutasImagenes; // ← Lista de imágenes

  Paquete({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.rutasImagenes = const [],
  });

  factory Paquete.fromMap(Map<String, dynamic> map) {
    // Manejo seguro de imagePath que puede venir como String(JSON) o incluso como List.
    List<String> imagenes = [];

    final dynamic imagePath = map['imagePath'];

    if (imagePath != null) {
      try {
        if (imagePath is String && imagePath.isNotEmpty) {
          final decoded = jsonDecode(imagePath);
          if (decoded is List) {
            imagenes = decoded.map((e) => e.toString()).toList();
          }
        } else if (imagePath is List) {
          imagenes = imagePath.map((e) => e.toString()).toList();
        }
      } catch (e) {
        // si algo falla, dejamos la lista vacía (no romperá)
        imagenes = [];
      }
    }

    // Aseguramos que precio sea double
    double precioDouble;
    final dynamic precioRaw = map['precio'];
    if (precioRaw is int) {
      precioDouble = precioRaw.toDouble();
    } else if (precioRaw is double) {
      precioDouble = precioRaw;
    } else {
      precioDouble = double.tryParse(precioRaw?.toString() ?? '0') ?? 0.0;
    }

    return Paquete(
      id: map['id'] is int ? map['id'] as int : (map['id'] is String ? int.tryParse(map['id']) : null),
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString(),
      precio: precioDouble,
      rutasImagenes: imagenes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      // Guardamos la lista como JSON (esto es lo que usa tu DatabaseHelper)
      'imagePath': jsonEncode(rutasImagenes),
    };
  }

  Paquete copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precio,
    List<String>? rutasImagenes,
  }) {
    return Paquete(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      rutasImagenes: rutasImagenes ?? this.rutasImagenes,
    );
  }
}
