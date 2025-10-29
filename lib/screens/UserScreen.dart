import 'dart:io'; // ✨ 1. Importa esto para poder usar 'File'
import 'package:flutter/material.dart';
import 'package:proyecto_av/utils/database.dart';

class Userscreen extends StatefulWidget {
  const Userscreen({super.key});

  @override
  State<Userscreen> createState() => _UserscreenState();
}

class _UserscreenState extends State<Userscreen> {
  late Future<List<Map<String, dynamic>>> _usersFuture;

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final db = await DatabaseHelper.database;
    return await db.query('users');
  }

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios Registrados'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay usuarios registrados'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final imagePath = user['fotoperfil'];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(user['name']),
                  subtitle: Text(user['user']),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: imagePath != null ? FileImage(File(imagePath)) : null,
                    child: imagePath == null ? Icon(Icons.person, color: Colors.white, size: 30) : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}