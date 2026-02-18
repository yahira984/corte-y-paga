import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:proyecto_av/domain/repositories/paquete_repository.dart';
import 'package:proyecto_av/data/models/paquete_model.dart';
import 'package:proyecto_av/screens/paquete_form_screen.dart';

class PaquetesScreen extends StatefulWidget {
  const PaquetesScreen({Key? key}) : super(key: key);

  @override
  _PaquetesScreenState createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  final _repo = PaqueteRepository();
  List<Paquete> _listaPaquetes = [];

  @override
  void initState() {
    super.initState();
    _loadPaquetes();
  }

  Future<void> _loadPaquetes() async {
<<<<<<< HEAD
    // 1. Mostrar un indicador de carga
    setState(() {
      _listaPaquetes = [];
      // Podríamos añadir un bool _isLoading = true;
    });

=======
    setState(() => _isLoading = true);
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
    final paquetes = await _repo.getPaquetes();
    setState(() {
      _listaPaquetes = paquetes;
    });
  }

  // 2. Navegación para CREAR o EDITAR (ahora es más inteligente)
  //    (Ya no recibe 'context' porque lo usamos desde la clase State)
  void _navigateAndRefresh({Paquete? paquete}) {
    Navigator.push(
      context,
<<<<<<< HEAD
      MaterialPageRoute(
        // 3. Pasa el 'paquete' si existe (para Editar)
        builder: (context) => PaqueteFormScreen(paquete: paquete),
      ),
    ).then((_) {
      // 4. Refresca la lista al volver
      _loadPaquetes();
    });
=======
      MaterialPageRoute(builder: (context) => PaqueteFormScreen(paquete: paquete)),
    ).then((_) => _loadPaquetes());
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
  }

  // 5. Lógica para BORRAR
  Future<void> _deletePaquete(Paquete paquete) async {
<<<<<<< HEAD
    // 6. Mostrar diálogo de confirmación
    final bool didConfirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar Borrado'),
          content: Text('¿Estás seguro de que quieres borrar "${paquete.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // No
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Sí
              child: Text('Borrar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false; // Si el usuario cierra el diálogo, es 'false'

    // 7. Si confirmaron, borrar
    if (didConfirm) {
      try {
        await _repo.deletePaquete(paquete.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${paquete.nombre}" borrado con éxito.')),
        );
        _loadPaquetes(); // Recargar la lista
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al borrar el paquete: $e')),
        );
      }
=======
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Eliminar paquete", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Seguro que quieres borrar "${paquete.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Borrar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    ) ?? false;

    if (confirm) {
      await _repo.deletePaquete(paquete.id!);
      _loadPaquetes();
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
<<<<<<< HEAD
        title: Text('Mis Paquetes de Servicios'),
      ),
      body: _listaPaquetes.isEmpty
          ? Center(
        child: Text('Aún no tienes paquetes creados.'),
      )
          : ListView.builder(
        itemCount: _listaPaquetes.length,
        itemBuilder: (context, index) {
          final paquete = _listaPaquetes[index];
          return ListTile(
            // 8. Mostrar Imagen o un Ícono
            leading: paquete.imagePath != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image.file(
                File(paquete.imagePath!),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
                : CircleAvatar(
              child: Icon(Icons.content_cut),
            ),

            title: Text(paquete.nombre),
            subtitle: Text(paquete.descripcion ?? 'Sin descripción'),

            // 9. Trailing con Precio Y Botón de Borrar
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${paquete.precio.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                  onPressed: () => _deletePaquete(paquete),
                ),
              ],
            ),

            // 10. onTap para EDITAR
            onTap: () {
              _navigateAndRefresh(paquete: paquete);
            },
          );
        },
=======
        title: Text("Mis Paquetes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 23)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
      ),

      // Botón flotante para AÑADIR (llama a la misma función, sin paquete)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _navigateAndRefresh(),
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.black))
          : _listaPaquetes.isEmpty
          ? Center(child: Text("No hay paquetes aún.", style: TextStyle(fontSize: 17, color: Colors.black54)))
          : ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: _listaPaquetes.length,
        itemBuilder: (context, index) {
          final paquete = _listaPaquetes[index];

          return _animatedCard(
            delay: index * 120,
            child: _buildPaqueteCard(paquete),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 🔥 CARD ESTILO PREMIUM
  // --------------------------------------------------------------------------
  Widget _buildPaqueteCard(Paquete paquete) {
    return Container(
      margin: EdgeInsets.only(bottom: 26),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: Offset(0, 10),
          )
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // -----------------------------
            // 🔥 CARRUSEL ULTRA PRO
            // -----------------------------
            paquete.rutasImagenes.isEmpty
                ? Container(
              height: 200,
              color: Colors.grey.shade200,
              child: Center(
                child: Icon(Icons.image_not_supported, size: 70, color: Colors.grey),
              ),
            )
                : _buildCarousel(paquete),

            // -----------------------------
            // 🔥 CONTENIDO DE LA CARD
            // -----------------------------
            Padding(
              padding: const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          paquete.nombre,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),

                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.black87, size: 26),
                        onPressed: () => _navigateAndRefresh(paquete: paquete),
                      ),

                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 26),
                        onPressed: () => _deletePaquete(paquete),
                      ),
                    ],
                  ),

                  if (paquete.descripcion != null && paquete.descripcion!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        paquete.descripcion!,
                        style: TextStyle(color: Colors.black54, fontSize: 16, height: 1.2),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  SizedBox(height: 14),

                  Text(
                    '\$${paquete.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 🔥 CARRUSEL MEGA PRO CON BLUR DINÁMICO
  // --------------------------------------------------------------------------
  Widget _buildCarousel(Paquete paquete) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 230,
        viewportFraction: 1,
        enlargeCenterPage: false,
        autoPlay: paquete.rutasImagenes.length > 1,
        enableInfiniteScroll: paquete.rutasImagenes.length > 1,
      ),

      items: paquete.rutasImagenes.map((ruta) {
        return Stack(
          children: [
            Positioned.fill(
              child: Image.file(
                File(ruta),
                fit: BoxFit.cover,
              ),
            ),

            // 🔥 Blur elegante sobre fondo
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),
            ),

            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(
                  File(ruta),
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            )
          ],
        );
      }).toList(),
    );
  }

  // --------------------------------------------------------------------------
  // 🔥 ANIMACIÓN DE ENTRADA PARA LAS CARDS
  // --------------------------------------------------------------------------
  Widget _animatedCard({required Widget child, required int delay}) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutQuart,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 28),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }
}
