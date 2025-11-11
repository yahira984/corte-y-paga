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

  @override
  void initState() {
    super.initState();
    _loadPaquetes();
  }

  Future<void> _loadPaquetes() async {
    // 1. Mostrar un indicador de carga
    setState(() {
      _listaPaquetes = [];
      // Podríamos añadir un bool _isLoading = true;
    });

    final paquetes = await _repo.getPaquetes();
    setState(() {
      _listaPaquetes = paquetes;
    });
  }

  // 2. Navegación para CREAR o EDITAR (ahora es más inteligente)
  //    (Ya no recibe 'context' porque lo usamos desde la clase State)
  void _navigateAndRefresh({Paquete? paquete}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // 3. Pasa el 'paquete' si existe (para Editar)
        builder: (context) => PaqueteFormScreen(paquete: paquete),
      ),
    ).then((_) {
      // 4. Refresca la lista al volver
      _loadPaquetes();
    });
  }

  // 5. Lógica para BORRAR
  Future<void> _deletePaquete(Paquete paquete) async {
    // 6. Mostrar diálogo de confirmación
    final bool didConfirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Borrado'),
          content: Text('¿Estás seguro de que quieres borrar "${paquete.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // No
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Sí
              child: Text('Borrar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false; // Si el usuario cierra el diálogo, es 'false'

    // 7. Si confirmaron, borrar
    if (didConfirm) {
      try {
        await _repo.deletePaquete(paquete.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${paquete.nombre}" borrado con éxito.')),
        );
        _loadPaquetes(); // Recargar la lista
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
      body: _listaPaquetes.isEmpty
          ? Center(
        child: Text('Aún no tienes paquetes creados.'),
      )
          : ListView.builder(
        itemCount: _listaPaquetes.length,
        itemBuilder: (context, index) {
          final paquete = _listaPaquetes[index];
          return ListTile(
            // 8. Mostrar Imagen o un Ícono
            leading: paquete.imagePath != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image.file(
                File(paquete.imagePath!),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
                : CircleAvatar(
              child: Icon(Icons.content_cut),
            ),

            title: Text(paquete.nombre),
            subtitle: Text(paquete.descripcion ?? 'Sin descripción'),

            // 9. Trailing con Precio Y Botón de Borrar
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${paquete.precio.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                  onPressed: () => _deletePaquete(paquete),
                ),
              ],
            ),

            // 10. onTap para EDITAR
            onTap: () {
              _navigateAndRefresh(paquete: paquete);
            },
          );
        },
      ),

      // Botón flotante para AÑADIR (llama a la misma función, sin paquete)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(),
        child: Icon(Icons.add),
        tooltip: 'Añadir Paquete',
      ),
    );
  }
}