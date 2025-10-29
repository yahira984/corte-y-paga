import 'package:flutter/material.dart';
import 'package:proyecto_av/screens/home_screen.dart';
import 'package:proyecto_av/screens/register_screen.dart';
import 'package:proyecto_av/utils/database.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController txtUsername = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: Image.network(
                    'https://static.vecteezy.com/system/resources/previews/041/731/156/non_2x/login-icon-vector.jpg',
                    fit: BoxFit.cover),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                  child: TextFormField(
                    controller: txtUsername,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person), label: Text('Usuario')),
                  )),
              Padding(
                  padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                  child: TextFormField(
                    controller: txtPassword,
                    obscureText: true,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        label: Text('Contraseña')),
                  )),
              TextButton(
                  onPressed: () async {
                    final db = await DatabaseHelper.database;

                    final List<Map<String, dynamic>> result = await db.query(
                        'users',
                        where: 'user = ? and password = ?',
                        whereArgs: [txtUsername.text, txtPassword.text]);
                    if (result.isNotEmpty) {
                      QuickAlert.show(
                          context: context,
                          type: QuickAlertType.success,
                          title: '¡Bienvenido!',
                          text: 'Acceso concedido.',
                          confirmBtnText: 'Entrar',
                          onConfirmBtnTap: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()));
                          });
                    } else {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.error,
                        title: 'Oops...',
                        text: 'Usuario o contraseña incorrectos.',
                      );
                    }
                  },
                  child: Text('Accesar')),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegistrerScreen()));
                  },
                  child: Text('Registrar')),
            ],
          ),
        ));
  }
}