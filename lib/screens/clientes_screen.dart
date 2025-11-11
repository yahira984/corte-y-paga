import 'package:flutter/material.dart';
// Usamos las rutas absolutas (la forma más segura)
import 'package:proyecto_av/domain/repositories/cliente_repository.dart';
import 'package:proyecto_av/data/models/cliente_model.dart';
import 'package:proyecto_av/screens/cliente_form_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({Key? key}) : super(key: key);

  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _repo = ClienteRepository();
  List<Cliente> _listaClientes = [];
  bool _isLoading = true; // <-- Añadido para un look pro

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    setState(() {
      _isLoading = true;
      _listaClientes = [];
    });

    final clientes = await _repo.getClientes();

    setState(() {
      _listaClientes = clientes;
      _isLoading = false;
    });
  }

  // Navegación para CREAR o EDITAR
  void _navigateAndRefresh({Cliente? cliente}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClienteFormScreen(cliente: cliente),
      ),
    ).then((_) {
      _loadClientes();
    });
  }

  // Lógica para BORRAR
  Future<void> _deleteCliente(Cliente cliente) async {
    final bool didConfirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Borrado'),
          content: Text('¿Estás seguro de que quieres borrar a "${cliente.nombre}"?'),
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
        await _repo.deleteCliente(cliente.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${cliente.nombre}" borrado con éxito.')),
        );
        _loadClientes(); // Recargar la lista
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al borrar el cliente: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos el color de fondo de nuestro tema
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Mis Clientes'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _listaClientes.isEmpty
          ? Center(
        child: Text('Aún no tienes clientes registrados.'),
      )
          : ListView.builder(
        // Añadimos padding a la lista
        padding: const EdgeInsets.all(16.0),
        itemCount: _listaClientes.length,
        itemBuilder: (context, index) {
          final cliente = _listaClientes[index];

          // --- ¡AQUÍ ESTÁ EL CAMBIO! ---
          // Envolvemos el ListTile en un Card
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0), // Espacio entre tarjetas
            child: ListTile(
              // Hacemos el ListTile cliqueable
              onTap: () => _navigateAndRefresh(cliente: cliente),
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),

              // --- AVATAR MEJORADO ---
              leading: CircleAvatar(
                radius: 28, // Un poco más grande
                // Usamos el color secundario (madera) del tema
                backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                child: Icon(
                  Icons.person_outline,
                  size: 30,
                  // Usamos el color primario (azul-gris) del tema
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              // --- TEXTO MEJORADO ---
              title: Text(
                cliente.nombre,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                cliente.telefono ?? 'Sin teléfono',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),

              // --- BOTÓN DE BORRAR (sin cambios) ---
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                onPressed: () => _deleteCliente(cliente),
                tooltip: 'Borrar Cliente',
              ),
            ),
          );
        },
      ),

      // Botón flotante para AÑADIR (ya usa el color del tema)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(),
        child: Icon(Icons.add),
        tooltip: 'Añadir Cliente',
      ),
    );
  }
}