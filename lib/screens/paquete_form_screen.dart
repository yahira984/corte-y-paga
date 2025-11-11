import 'dart:io'; // <-- ¡NUEVO! Para mostrar la imagen
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // <-- ¡NUEVO!
import '../../domain/repositories/paquete_repository.dart';
import '../../data/models/paquete_model.dart';

class PaqueteFormScreen extends StatefulWidget {
  // 1. Acepta un paquete opcional (para editar)
  final Paquete? paquete;

  const PaqueteFormScreen({Key? key, this.paquete}) : super(key: key);

  @override
  _PaqueteFormScreenState createState() => _PaqueteFormScreenState();
}

class _PaqueteFormScreenState extends State<PaqueteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = PaqueteRepository();

  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();

  // 2. Variable para guardar la ruta de la imagen seleccionada
  String? _selectedImagePath;

  // 3. Variable para saber si estamos editando
  bool get _isEditing => widget.paquete != null;

  @override
  void initState() {
    super.initState();
    // 4. Si estamos editando, llenamos los campos
    if (_isEditing) {
      _nombreController.text = widget.paquete!.nombre;
      _descripcionController.text = widget.paquete!.descripcion ?? '';
      _precioController.text = widget.paquete!.precio.toString();
      _selectedImagePath = widget.paquete!.imagePath;
    }
  }

  // 5. Lógica para seleccionar imagen
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  // 6. Lógica de guardado (Insertar o Actualizar)
  Future<void> _savePaquete() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 7. Creamos el objeto paquete (nuevo o actualizado)
    final paquete = Paquete(
      id: _isEditing ? widget.paquete!.id : null, // Mantenemos el ID si editamos
      nombre: _nombreController.text,
      descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
      precio: double.tryParse(_precioController.text) ?? 0.0,
      imagePath: _selectedImagePath,
    );

    try {
      if (_isEditing) {
        // ACTUALIZAR
        await _repo.updatePaquete(paquete);
      } else {
        // INSERTAR
        await _repo.insertPaquete(paquete);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Paquete guardado con éxito!')),
      );
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el paquete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 8. Título dinámico
        title: Text(_isEditing ? 'Editar Paquete' : 'Nuevo Paquete'),
      ),
      body: SingleChildScrollView( // <-- Añadido para evitar overflow
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // --- 9. Widget para mostrar/seleccionar imagen ---
                Stack(
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _selectedImagePath != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_selectedImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                          : Icon(Icons.image, size: 50, color: Colors.grey[600]),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: _pickImage,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // --- Campo de Nombre ---
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Servicio',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // --- Campo de Descripción ---
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                // --- Campo de Precio ---
                TextFormField(
                  controller: _precioController,
                  decoration: InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El precio es obligatorio';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Ingresa un número válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),

                // --- Botón de Guardar ---
                ElevatedButton(
                  onPressed: _savePaquete,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Guardar Paquete'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}