import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:proyecto_av/utils/database.dart'; // Asegúrate que la ruta a tu database helper sea correcta

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _locations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final data = await _dbHelper.getLocations();
    setState(() {
      _locations = data;
    });
  }

  Future<void> _getCurrentLocationAndSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Los permisos de ubicación son necesarios.')),
            );
          }
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _dbHelper.insertLocation(newLocation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Ubicación guardada con éxito! ✅'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _loadLocations();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener la ubicación: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- ESTA ES LA FUNCIÓN CON LA CORRECCIÓN FINAL ---
  Future<void> _openInGoogleMaps(double latitude, double longitude) async {
    // Se construye la URL usando las variables para que apunte a la ubicación correcta.
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    final Uri uri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps.')),
        );
      }
    }
  }

  String _formatTimestamp(String isoDate) {
    final DateTime date = DateTime.parse(isoDate);
    return DateFormat('dd MMM, yyyy - hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ubicaciones'),
      ),
      body: _locations.isEmpty
          ? const Center(
        child: Text(
          'No hay ubicaciones guardadas.\nPresiona el botón + para agregar una.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _locations.length,
        itemBuilder: (context, index) {
          final location = _locations[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: const Icon(Icons.pin_drop, color: Colors.blue),
              title: Text(
                'Lat: ${location['latitude']}',
              ),
              subtitle: Text(
                'Lon: ${location['longitude']}\n${_formatTimestamp(location['timestamp'])}',
              ),
              onTap: () => _openInGoogleMaps(
                location['latitude'],
                location['longitude'],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _getCurrentLocationAndSave,
        tooltip: 'Guardar Ubicación Actual',
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add_location_alt),
      ),
    );
  }
}