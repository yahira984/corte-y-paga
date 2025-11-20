import 'package:flutter/material.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Variables para mostrar en la UI
  String nombre = '';
  String email = '';
  String rol = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  // Simula la carga de datos desde el SessionManager
  Future<void> _cargarDatosUsuario() async {
    // Simulamos un pequeño delay para ver el efecto de carga
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      nombre = SessionManager().getNombre() ?? 'Usuario';
      email = SessionManager().getEmail() ?? 'usuario@correo.com';
      rol = SessionManager().getRol() ?? 'Invitado';
      isLoading = false;
    });
  }

  // Función para cerrar sesión
  Future<void> _cerrarSesion() async {
    await SessionManager().logout();

    if (mounted) {
      // Aquí normalmente navegarías al Login
      Navigator.of(context).pushReplacementNamed('/login');
      // O si no tienes rutas definidas aún:
      // Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatosUsuario,
            tooltip: 'Recargar datos',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar del usuario
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.indigo.shade100,
              child: Text(
                nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nombre del usuario
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Rol (Chip)
            Chip(
              label: Text(
                rol.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.orange,
            ),
            const SizedBox(height: 30),

            // Tarjeta de información
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.indigo),
                      title: const Text('Correo Electrónico'),
                      subtitle: Text(email),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.security, color: Colors.indigo),
                      title: const Text('Nivel de Acceso'),
                      subtitle: Text(rol),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.indigo),
                      title: const Text('Teléfono'),
                      subtitle: const Text('+52 55 1234 5678'), // Dato simulado
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Botón de Cerrar Sesión
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _cerrarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: const BorderSide(color: Colors.red),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// CLASE SESSION MANAGER (Integrada aquí para corregir el error)
// ---------------------------------------------------------
class SessionManager {
  // Singleton: Asegura que solo exista una instancia de esta clase
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  // Variables privadas para almacenar datos en memoria
  String? _usuarioId;
  String? _nombre;
  String? _email;
  String? _rol;
  bool _isLoggedIn = false;

  // Métodos para establecer datos (normalmente usados en el Login)
  void saveUserSession(String id, String nombre, String email, String rol) {
    _usuarioId = id;
    _nombre = nombre;
    _email = email;
    _rol = rol;
    _isLoggedIn = true;
  }

  // Getters para obtener la información
  String? getUsuarioId() => _usuarioId;
  String? getNombre() => _nombre;
  String? getEmail() => _email;
  String? getRol() => _rol;
  bool isLoggedIn() => _isLoggedIn;

  // Método para cerrar sesión
  Future<void> logout() async {
    // Aquí limpiarías SharedPreferences si lo estuvieras usando
    _usuarioId = null;
    _nombre = null;
    _email = null;
    _rol = null;
    _isLoggedIn = false;
    debugPrint("Sesión cerrada correctamente (Datos en memoria limpiados)");
  }
}