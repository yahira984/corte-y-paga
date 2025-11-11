import 'package:flutter/material.dart';
// Imports absolutos (la forma más segura)
import 'package:proyecto_av/screens/paquetes_screen.dart';
import 'package:proyecto_av/screens/clientes_screen.dart';
import 'package:proyecto_av/screens/citas_screen.dart';
import 'package:proyecto_av/screens/ventas_screen.dart';
import 'package:proyecto_av/screens/login_screen.dart';
import 'package:proyecto_av/utils/session_manager.dart';
import 'package:proyecto_av/screens/perfil_screen.dart';
import 'package:proyecto_av/utils/custom_page_route.dart'; // <-- Import de Animación

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // --- Función de Logout ---
  Future<void> _doLogout(BuildContext context) async {
    final bool didConfirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres salir?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Salir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false;

    if (!didConfirm) return;

    if (context.mounted) {
      SessionManager.instance.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- ¡Estilo Login! (Fondo de la app) ---
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        // --- Widget de Perfil (¡CON ANIMACIÓN!) ---
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                FadeInPageRoute(child: const PerfilScreen()),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                color: Colors.blueGrey[900],
              ),
            ),
          ),
        ),

        title: Text('Inicio - Corte & Paga'),

        actions: [
          // --- Botón de Logout ---
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              _doLogout(context);
            },
          )
        ],
      ),

      // --- ¡Estilo Login! (Sin Stack) ---
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¡Bienvenido, Barbero!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),

                // --- Imagen estilo Login ---
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    'assets/images/home_bg.png', // Tu imagen de ambiente
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                      );
                    },
                  ),
                ),

                SizedBox(height: 40),

                // --- Botón de Paquetes (¡CON ANIMACIÓN!) ---
                ElevatedButton.icon(
                  icon: Icon(Icons.content_cut),
                  label: Text('Administrar mis Paquetes'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeInPageRoute(child: const PaquetesScreen()),
                    );
                  },
                ),
                SizedBox(height: 20),

                // --- Botón de Clientes (¡CON ANIMACIÓN!) ---
                ElevatedButton.icon(
                  icon: Icon(Icons.people),
                  label: Text('Administrar Clientes'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeInPageRoute(child: const ClientesScreen()),
                    );
                  },
                ),
                SizedBox(height: 20),

                // --- Botón de Reportes (¡CON ANIMACIÓN!) ---
                ElevatedButton.icon(
                  icon: Icon(Icons.bar_chart, color: Colors.green[700]),
                  label: Text('Corte de Caja / Reportes'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeInPageRoute(child: const VentasScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      // --- FAB (¡CON ANIMACIÓN!) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            FadeInPageRoute(child: const CitasScreen()),
          );
        },
        child: Icon(Icons.calendar_month),
        tooltip: 'Ver Agenda',
      ),
    );
  }
}