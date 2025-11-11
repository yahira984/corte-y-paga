import 'package:flutter/material.dart';
import '../../domain/repositories/usuario_repository.dart';
import '../../data/models/usuario_model.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _usuarioRepo = UsuarioRepository();

  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 1. Crear el objeto Usuario con los datos
    final nuevoUsuario = Usuario(
      nombre: _nombreController.text,
      email: _emailController.text,
      password: _passwordController.text, // TODO: En el futuro, esto debe ser un HASH
    );

    try {
      // 2. Llamar al repositorio para insertar
      final id = await _usuarioRepo.registro(nuevoUsuario);

      if (id > 0) {
        // ¡Éxito!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Usuario registrado con éxito! Ya puedes iniciar sesión.')),
        );

        // 3. Regresar a la pantalla de Login
        Navigator.pop(context);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar. ¿El email ya existe?')),
        );
      }
    } catch (e) {
      // Error de base de datos (probablemente email duplicado)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: El email ya está en uso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Barbero'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Crea tu cuenta',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 30),

              // --- Campo de Nombre ---
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // --- Campo de Email ---
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor ingresa un email válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // --- Campo de Contraseña ---
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              // --- Botón de Registro ---
              ElevatedButton(
                onPressed: _doRegister,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Registrarme'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}