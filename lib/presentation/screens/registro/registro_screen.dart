import 'package:flutter/material.dart';
import 'package:proyecto_av/core/services/database_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final db = DatabaseService();

  Future<void> _registrarUsuario() async {
    if (_nombreCtrl.text.isEmpty || _correoCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _mostrarMensaje('Por favor llena todos los campos');
      return;
    }

    final result = await db.registerUser({
      'nombre': _nombreCtrl.text.trim(),
      'correo': _correoCtrl.text.trim(),
      'password': _passCtrl.text.trim(),
    });

    if (result == -1) {
      _mostrarMensaje('❌ El correo ya está registrado');
    } else {
      _mostrarMensaje('✅ Registro exitoso');
      _nombreCtrl.clear();
      _correoCtrl.clear();
      _passCtrl.clear();
    }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 8),
            TextField(controller: _correoCtrl, decoration: const InputDecoration(labelText: 'Correo')),
            const SizedBox(height: 8),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _registrarUsuario, child: const Text('Registrar')),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('¿Ya tienes cuenta? Inicia sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
