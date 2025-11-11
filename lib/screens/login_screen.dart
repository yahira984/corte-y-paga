import 'package:flutter/material.dart';
import '../../domain/repositories/usuario_repository.dart';
import 'home_screen.dart'; // Crearemos esta pantalla en el paso 3
import 'register_screen.dart';
import 'package:proyecto_av/utils/session_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para el texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Llave para el Formulario (para validaciones)
  final _formKey = GlobalKey<FormState>();

  // Instancia de nuestro repositorio
  final _usuarioRepo = UsuarioRepository();

  // Método para manejar el login
  Future<void> _doLogin() async {
    // 1. Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return; // Si no es válido, no hace nada
    }

    // 2. Obtener el texto
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      // 3. Llamar al repositorio
      final usuario = await _usuarioRepo.login(email, password);

      // 4. Revisar el resultado
      if (usuario != null) {
        // --- ¡AÑADE ESTA LÍNEA! ---
        SessionManager.instance.login(usuario);
        // ----------------------------

        // ¡Éxito! Navegar a la pantalla Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Error: Usuario o contraseña incorrectos
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email o contraseña incorrectos.')),
        );
      }
    } catch (e) {
      // Error general
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Corte & Paga - Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Bienvenido',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 30),

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
                obscureText: true, // Oculta la contraseña
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              // --- Botón de Login ---
              ElevatedButton(
                onPressed: _doLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Botón ancho
                ),
                child: Text('Ingresar'),
              ),

              SizedBox(height: 20),

                  // --- Botón de Registro ---
                  TextButton(
                    onPressed: () {
                      // --- MODIFICA AQUÍ ---
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                      // ---------------------
                    },
                    child: Text('¿No tienes cuenta? Regístrate aquí'),
                  )
            ],
          ),
        ),
      ),
    );
  }
}