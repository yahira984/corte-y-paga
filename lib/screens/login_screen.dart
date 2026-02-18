import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart'; // <-- Huella
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // <-- Baúl Seguro
import 'package:proyecto_av/domain/repositories/usuario_repository.dart';
import 'package:proyecto_av/screens/home_screen.dart';
import 'package:proyecto_av/screens/register_screen.dart';
import 'package:proyecto_av/utils/session_manager.dart';
import 'package:proyecto_av/utils/custom_page_route.dart'; // Animación

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _usuarioRepo = UsuarioRepository();

  // Herramientas de biometría y almacenamiento
  final LocalAuthentication auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics(); // Revisar si el cel tiene huella al iniciar
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics && await auth.isDeviceSupported();
    } catch (e) {
      canCheckBiometrics = false;
    }
    if (!mounted) return;
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  // Lógica de Login con Contraseña (Manual)
  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final usuario = await _usuarioRepo.login(email, password);

      if (usuario != null && mounted) {
        // --- ¡MAGIA! GUARDAMOS LAS CREDENCIALES ---
        await _storage.write(key: 'email', value: email);
        await _storage.write(key: 'password', value: password);
        // ------------------------------------------

        SessionManager.instance.login(usuario);
        Navigator.pushReplacement(
          context,
          FadeInPageRoute(child: const HomeScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email o contraseña incorrectos.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Lógica de Login con Huella (Automático)
  Future<void> _authWithBiometrics() async {
    try {
      // 1. Pedir Huella
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Por favor, escanea tu huella para entrar',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        // 2. Si pasó, leer credenciales guardadas
        final String? storedEmail = await _storage.read(key: 'email');
        final String? storedPass = await _storage.read(key: 'password');

        if (storedEmail != null && storedPass != null) {
          // 3. Llenar campos y entrar
          _emailController.text = storedEmail;
          _passwordController.text = storedPass;
          _doLogin(); // Reusamos la función de login
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Primero inicia sesión con contraseña una vez para activar la huella.')),
          );
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de biometría: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: Text('Corte & Paga - Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    'assets/images/login_bg.png',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(height: 250, color: Colors.grey[300], child: Icon(Icons.store, size: 80)),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => !v!.contains('@') ? 'Email inválido' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                SizedBox(height: 30),

                // Botón Ingresar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _doLogin,
                    child: Text('Ingresar', style: TextStyle(fontSize: 18)),
                  ),
                ),

                SizedBox(height: 20),

                // --- BOTÓN DE HUELLA ---
                if (_canCheckBiometrics)
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      iconSize: 60,
                      icon: Icon(Icons.fingerprint, color: Theme.of(context).colorScheme.primary),
                      onPressed: _authWithBiometrics,
                      tooltip: 'Ingresar con Huella',
                    ),
                  ),
                // -----------------------

                TextButton(
                  onPressed: () {
                    Navigator.push(context, FadeInPageRoute(child: const RegisterScreen()));
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