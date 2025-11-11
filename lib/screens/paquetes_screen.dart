import 'dart:io'; // <-- ¡NUEVO! Para mostrar la imagen
import 'package:flutter/material.dart';
import '../../domain/repositories/paquete_repository.dart';
import '../../data/models/paquete_model.dart';
import 'paquete_form_screen.dart';
class PaquetesScreen extends StatefulWidget {
  const PaquetesScreen({Key? key}) : super(key: key);

  @override
  _PaquetesScreenState createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  final _repo = PaqueteRepository();
  List<Paquete> _listaPaquetes = [];
  bool _isLoading = true; // <-- Añadimos un indicador de carga

  @override
  void initState() {
    super.initState();
    _loadPaquetes();
  }

  Future<void> _loadPaquetes() async {
    setState(() {
      _isLoading = true; // Iniciamos la carga
      _listaPaquetes = []; // Limpiamos la lista para mostrar el loading
    });

    final paquetes = await _repo.getPaquetes();
    setState(() {
      _listaPaquetes = paquetes;
      _isLoading = false; // Finalizamos la carga
    });
  }

  void _navigateAndRefresh({Paquete? paquete}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaqueteFormScreen(paquete: paquete),
      ),
    ).then((_) {
      _loadPaquetes();
    });
  }

  Future<void> _deletePaquete(Paquete paquete) async {
    final bool didConfirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Borrado'),
          content: Text('¿Estás seguro de que quieres borrar "${paquete.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Borrar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false;

    if (didConfirm) {
      try {
        await _repo.deletePaquete(paquete.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${paquete.nombre}" borrado con éxito.')),
        );
        _loadPaquetes();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al borrar el paquete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Paquetes de Servicios'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Mostramos carga
          : _listaPaquetes.isEmpty
          ? Center(
        child: Text('Aún no tienes paquetes creados.'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0), // Padding general para la lista
        itemCount: _listaPaquetes.length,
        itemBuilder: (context, index) {
          final paquete = _listaPaquetes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0), // Espacio entre tarjetas
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell( // Para que toda la tarjeta sea cliqueable para editar
              onTap: () => _navigateAndRefresh(paquete: paquete),
              borderRadius: BorderRadius.circular(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- IMAGEN GRANDE ---
                  paquete.imagePath != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.file(
                      File(paquete.imagePath!),
                      width: double.infinity, // Ancho completo
                      height: 180, // Altura más grande
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // En caso de que la imagen no se encuentre
                        return Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                        );
                      },
                    ),
                  )
                      : Container( // Contenedor por defecto si no hay imagen
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    child: Icon(Icons.content_cut, size: 60, color: Theme.of(context).primaryColor),
                  ),

                  // --- CONTENIDO DE TEXTO Y BOTONES ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                paquete.nombre,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Botón de Borrar (en la misma línea del título)
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                              onPressed: () => _deletePaquete(paquete),
                              tooltip: 'Borrar Paquete',
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          paquete.descripcion ?? 'Sin descripción',
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 2, // Limita la descripción a 2 líneas
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '\$${paquete.precio.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(),
        child: Icon(Icons.add),
        tooltip: 'Añadir Paquete',
      ),
    );
  }
}