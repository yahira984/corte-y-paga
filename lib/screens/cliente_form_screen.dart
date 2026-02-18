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
    if (!_formKey.currentState!.validate()) return;

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

  // ---------- ESTILO DE LOS CAMPOS ----------
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // -------------------- APPBAR BLANCO PREMIUM --------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          _isEditing ? 'Editar Cliente' : 'Nuevo Cliente',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),

      backgroundColor: Color(0xFFF5F5F5),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ---------- NOMBRE ----------
                TextFormField(
                  controller: _nombreController,
                  decoration: _inputStyle('Nombre del Cliente', Icons.person),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'El nombre es obligatorio' : null,
                ),
                SizedBox(height: 20),

                // ---------- TELÉFONO ----------
                TextFormField(
                  controller: _telefonoController,
                  decoration: _inputStyle('Teléfono (Opcional)', Icons.phone),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),

                // ---------- PREFERENCIAS ----------
                TextFormField(
                  controller: _preferenciasController,
                  decoration: _inputStyle('Preferencias (Opcional)', Icons.notes),
                  maxLines: 3,
                ),
                SizedBox(height: 35),

                // ---------- BOTÓN GUARDAR ----------
                ElevatedButton(
                  onPressed: _saveCliente,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 55),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Guardar Cliente',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
