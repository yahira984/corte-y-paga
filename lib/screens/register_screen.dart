import 'package:flutter/material.dart';
import 'package:proyecto_av/domain/repositories/usuario_repository.dart';
import 'package:proyecto_av/data/models/usuario_model.dart';
import 'package:proyecto_av/utils/legal_content.dart';
import 'package:proyecto_av/screens/legal_view_screen.dart';

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

  // --- NUEVA VARIABLE ---
  bool _terminosAceptados = false;

  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // --- NUEVA VALIDACIÓN ---
    if (!_terminosAceptados) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debes aceptar los Términos y el Aviso de Privacidad.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nuevoUsuario = Usuario(
      nombre: _nombreController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    try {
      final id = await _usuarioRepo.registro(nuevoUsuario);

      if (id > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Usuario registrado con éxito! Ya puedes iniciar sesión.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar. ¿El email ya existe?')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: El email ya está en uso.')),
      );
    }
  }

  // Función auxiliar para navegar a los documentos
  void _verDocumento(String titulo, String contenido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LegalViewScreen(titulo: titulo, contenido: contenido),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Barbero'),
      ),
      body: SingleChildScrollView( // Para que no estorbe el teclado
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

              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => !value!.contains('@') ? 'Email inválido' : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),

              SizedBox(height: 20),

              // --- SECCIÓN DE TÉRMINOS Y CONDICIONES ---
              Row(
                children: [
                  Checkbox(
                    value: _terminosAceptados,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (bool? value) {
                      setState(() {
                        _terminosAceptados = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text("He leído y acepto los "),
                        GestureDetector(
                          onTap: () => _verDocumento("Términos y Condiciones", LegalContent.terminosYCondiciones),
                          child: Text(
                            "Términos y Condiciones",
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                        ),
                        Text(" y el "),
                        GestureDetector(
                          onTap: () => _verDocumento("Aviso de Privacidad", LegalContent.avisoPrivacidad),
                          child: Text(
                            "Aviso de Privacidad",
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                        ),
                        Text("."),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

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