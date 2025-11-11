import 'package:flutter/material.dart';
import 'package:proyecto_av/domain/repositories/cliente_repository.dart';
import 'package:proyecto_av/data/models/cliente_model.dart';

class ClienteFormScreen extends StatefulWidget {
  final Cliente? cliente;
  const ClienteFormScreen({Key? key, this.cliente}) : super(key: key);

  @override
  _ClienteFormScreenState createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = ClienteRepository();

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _preferenciasController = TextEditingController();

  bool get _isEditing => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nombreController.text = widget.cliente!.nombre;
      _telefonoController.text = widget.cliente!.telefono ?? '';
      _preferenciasController.text = widget.cliente!.preferencias ?? '';
    }
  }

  Future<void> _saveCliente() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cliente = Cliente(
      id: _isEditing ? widget.cliente!.id : null,
      nombre: _nombreController.text,
      telefono: _telefonoController.text.isEmpty ? null : _telefonoController.text,
      preferencias: _preferenciasController.text.isEmpty ? null : _preferenciasController.text,
    );

    try {
      if (_isEditing) {
        await _repo.updateCliente(cliente);
      } else {
        await _repo.insertCliente(cliente);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Cliente guardado con éxito!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el cliente: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Cliente' : 'Nuevo Cliente'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Cliente',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _telefonoController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono (Opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _preferenciasController,
                  decoration: InputDecoration(
                    labelText: 'Preferencias (Opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveCliente,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Guardar Cliente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}