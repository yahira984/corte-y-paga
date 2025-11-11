import 'package:flutter/material.dart';
import 'package:proyecto_av/utils/session_manager.dart';
import 'package:proyecto_av/domain/repositories/usuario_repository.dart';
import 'package:proyecto_av/data/models/usuario_model.dart';
import 'package:proyecto_av/screens/login_screen.dart'; // Para l logout forzado

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Repositorio y usuario
  final _usuarioRepo = UsuarioRepository();
  final Usuario? _currentUser = SessionManager.instance.currentUser;

  // Controladores para el formulario
  final _formKey = GlobalKey<FormState>();
  final _passAntiguaController = TextEditingController();
  final _passNuevaController = TextEditingController();
  final _passConfirmarController = TextEditingController();

  // Función para cambiar la contraseña
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return; // Si el formulario no es válido, no hace nada
    }

    // Validar que las contraseñas nuevas coincidan
    if (_passNuevaController.text != _passConfirmarController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas nuevas no coinciden.')),
      );
      return;
    }

    try {
      // Llamar al repositorio
      final int rowsAffected = await _usuarioRepo.updatePassword(
        id: _currentUser!.id!,
        oldPassword: _passAntiguaController.text,
        newPassword: _passNuevaController.text,
      );

      if (rowsAffected > 0) {
        // ¡Éxito!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Contraseña actualizada con éxito! Por favor, inicia sesión de nuevo.')),
        );

        // Forzamos el logout para que inicie sesión con la nueva contraseña
        if (context.mounted) {
          SessionManager.instance.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
          );
        }
      } else {
        // Error: 0 filas afectadas (la contraseña antigua estaba mal)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: La contraseña antigua es incorrecta.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Tarjeta de Información ---
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person, color: Theme.of(context).primaryColor),
                      title: Text('Nombre de Barbero'),
                      subtitle: Text(
                        _currentUser?.nombre ?? 'No disponible',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email, color: Theme.of(context).primaryColor),
                      title: Text('Email de Cuenta'),
                      subtitle: Text(
                        _currentUser?.email ?? 'No disponible',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // --- Formulario de Cambio de Contraseña ---
            Text(
              'Cambiar Contraseña',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- Contraseña Antigua ---
                  TextFormField(
                    controller: _passAntiguaController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña Antigua',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_clock),
                    ),
                    obscureText: true,
                    validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  SizedBox(height: 20),

                  // --- Contraseña Nueva ---
                  TextFormField(
                    controller: _passNuevaController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña Nueva',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_open),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requerido';
                      if (value.length < 6) return 'Debe tener al menos 6 caracteres';
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // --- Confirmar Contraseña Nueva ---
                  TextFormField(
                    controller: _passConfirmarController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña Nueva',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_open),
                    ),
                    obscureText: true,
                    validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  SizedBox(height: 30),

                  // --- Botón de Guardar ---
                  ElevatedButton(
                    onPressed: _changePassword,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Actualizar Contraseña'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}