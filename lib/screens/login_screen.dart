import 'package:flutter/material.dart';
// Importamos todo lo que necesita con rutas absolutas (a prueba de errores)
import 'package:proyecto_av/domain/repositories/usuario_repository.dart';
import 'package:proyecto_av/screens/home_screen.dart';
import 'package:proyecto_av/screens/register_screen.dart';
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
      if (usuario != null && context.mounted) {
        // ¡Éxito! Guardamos en sesión
        SessionManager.instance.login(usuario);

        // Navegar a la pantalla Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (context.mounted) {
        // Error: Usuario o contraseña incorrectos
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email o contraseña incorrectos.'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      // Error general
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos el color de fondo 'roto' de nuestro tema
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Corte & Paga - Login'),
      ),
      // Usamos SingleChildScrollView para evitar overflow con el teclado
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // --- ¡AQUÍ ESTÁ LA IMAGEN! ---
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    'assets/images/login_bg.png', // Tu nueva imagen
                    height: 250, // Un buen tamaño
                    width: double.infinity,
                    fit: BoxFit.cover, // Para que llene el espacio
                    // En caso de que la imagen no cargue
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),
                SizedBox(height: 30),

                // -----------------------------

                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 30),

                // --- Campo de Email ---
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                  // El botón ya toma el estilo del ThemeData (azul-gris)
                  child: Text('Ingresar'),
                ),

                SizedBox(height: 20),

                // --- Botón de Registro ---
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: Text('¿No tienes cuenta? Regístrate aquí'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}