import 'package:flutter/material.dart';

class LegalViewScreen extends StatelessWidget {
  final String titulo;
  final String contenido;

  const LegalViewScreen({
    Key? key,
    required this.titulo,
    required this.contenido,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              contenido,
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      ),
    );
  }
}