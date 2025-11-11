import 'package:flutter/material.dart';
import 'package:proyecto_av/core/services/database_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final db = DatabaseService();

  Future<void> _iniciarSesion() async {
    final correo = _correoCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (correo.isEmpty || pass.isEmpty) {
      _mostrarMensaje('Por favor llena todos los campos');
      return;
    }

    final user = await db.loginUser(correo, pass);
    if (user != null) {
      _mostrarMensaje('✅ Bienvenido ${user['nombre']}');
    } else {
      _mostrarMensaje('❌ Credenciales incorrectas');
    }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _correoCtrl, decoration: const InputDecoration(labelText: 'Correo')),
            const SizedBox(height: 8),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _iniciarSesion, child: const Text('Iniciar sesión')),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/registro');
              },
              child: const Text('¿No tienes cuenta? Regístrate aquí'),
            ),
          ],
        ),
      ),
    );
  }
}
