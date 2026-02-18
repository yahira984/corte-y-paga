import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto_av/domain/repositories/paquete_repository.dart';
import 'package:proyecto_av/data/models/paquete_model.dart';

class PaqueteFormScreen extends StatefulWidget {
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

  List<String> _selectedImages = [];
  bool get _isEditing => widget.paquete != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nombreController.text = widget.paquete!.nombre;
      _descripcionController.text = widget.paquete!.descripcion ?? '';
      _precioController.text = widget.paquete!.precio.toString();
      _selectedImages = List.from(widget.paquete!.rutasImagenes);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((e) => e.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _savePaquete() async {
    if (!_formKey.currentState!.validate()) return;

    final paquete = Paquete(
      id: _isEditing ? widget.paquete!.id : null,
      nombre: _nombreController.text,
      descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
      precio: double.tryParse(_precioController.text) ?? 0.0,
      rutasImagenes: _selectedImages,
    );

    try {
      if (_isEditing) {
        await _repo.updatePaquete(paquete);
      } else {
        await _repo.insertPaquete(paquete);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Paquete guardado!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🔥 Fondo blanco elegante
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Paquete' : 'Nuevo Paquete',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),

        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔥 Botón moderno para agregar fotos
              ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate, size: 26),
                label: const Text("Agregar Fotos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black45,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 Carrusel de imágenes elegante
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.only(right: 15),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(_selectedImages[index]),
                                width: 140,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // ❌ Botón para eliminar imagen
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text('Sin fotos', style: TextStyle(color: Colors.grey)),
                ),

              // 🔥 Inputs con estilo premium

              _inputBox(
                label: "Nombre del Servicio",
                controller: _nombreController,
                validator: (value) => value!.isEmpty ? 'Obligatorio' : null,
              ),

              _inputBox(
                label: "Descripción (Opcional)",
                controller: _descripcionController,
              ),

              _inputBox(
                label: "Precio",
                controller: _precioController,
                keyboard: TextInputType.number,
                icon: Icons.attach_money,
                validator: (value) => value!.isEmpty ? 'Obligatorio' : null,
              ),

              const SizedBox(height: 40),

              // 🔥 Botón guardar estilo premium
              ElevatedButton(
                onPressed: _savePaquete,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Guardar Paquete',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // 🔥 FUNCIONES DE DISEÑO: Caja de input moderna
  Widget _inputBox({
    required String label,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),

      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: validator,

        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.black) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
