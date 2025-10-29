import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:proyecto_av/utils/database.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class RegistrerScreen extends StatefulWidget {
  const RegistrerScreen({super.key});

  @override
  State<RegistrerScreen> createState() => _RegistrerScreenState();
}

class _RegistrerScreenState extends State<RegistrerScreen> {
  TextEditingController txtUsername = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtName = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = p.basename(pickedFile.path);
      final String newPath = p.join(directory.path, fileName);
      final File newImage = await File(pickedFile.path).copy(newPath);

      setState(() {
        _imageFile = newImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Regístrate'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? Icon(
                  Icons.person,
                  color: Colors.grey[800],
                  size: 50,
                )
                    : null,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text('Cámara'),
                    style: ElevatedButton.styleFrom(
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo_library),
                    label: Text('Galería'),
                    style: ElevatedButton.styleFrom(
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                  padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                  child: TextFormField(
                    controller: txtName,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        label: Text('Nombres')),
                  )),
              Padding(
                  padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                  child: TextFormField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        label: Text('Apellidos')),
                  )),
              Padding(
                  padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                  child: TextFormField(
                    controller: txtUsername,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.work), label: Text('Usuario')),
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
              ElevatedButton(
                onPressed: () async {
                  final db = await DatabaseHelper.database;

                  final user = {
                    'user': txtUsername.text,
                    'name': txtName.text,
                    'password': txtPassword.text,
                    'fotoperfil': _imageFile?.path
                  };

                  if (txtUsername.text.isEmpty ||
                      txtPassword.text.isEmpty ||
                      txtName.text.isEmpty) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      text: 'Por favor, completa todos los campos requeridos.',
                    );
                    return;
                  }

                  final id = await db.insert('users', user);

                  QuickAlert.show(
                      context: context,
                      type: QuickAlertType.success,
                      text: 'Usuario registrado con éxito',
                      onConfirmBtnTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                  );
//...

                  txtName.clear();
                  txtUsername.clear();
                  txtPassword.clear();
                  setState(() {
                    _imageFile = null;
                  });
                },
                child: Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Volver al Login')),
            ],
          ),
        ));
  }
}