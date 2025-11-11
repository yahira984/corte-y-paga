import 'package:flutter/material.dart';
import 'package:proyecto_av/domain/repositories/cliente_repository.dart';
import 'package:proyecto_av/data/models/cliente_model.dart';
import 'cliente_form_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({Key? key}) : super(key: key);

  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _repo = ClienteRepository();
  List<Cliente> _listaClientes = [];

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    final clientes = await _repo.getClientes();
    setState(() {
      _listaClientes = clientes;
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
      // Refresca la lista al volver
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
      appBar: AppBar(
        title: Text('Mis Clientes'),
      ),
      body: _listaClientes.isEmpty
          ? Center(
        child: Text('Aún no tienes clientes registrados.'),
      )
          : ListView.builder(
        itemCount: _listaClientes.length,
        itemBuilder: (context, index) {
          final cliente = _listaClientes[index];
          return ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(cliente.nombre),
            subtitle: Text(cliente.telefono ?? 'Sin teléfono'),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: () => _deleteCliente(cliente),
            ),
            onTap: () {
              // Navegar para EDITAR
              _navigateAndRefresh(cliente: cliente);
            },
          );
        },
      ),

      // Botón flotante para AÑADIR
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(),
        child: Icon(Icons.add),
        tooltip: 'Añadir Cliente',
      ),
    );
  }
}