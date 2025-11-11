import 'package:flutter/material.dart';
// Corregimos todos los imports a rutas absolutas (la forma más segura)
import 'package:proyecto_av/screens/paquetes_screen.dart';
import 'package:proyecto_av/screens/clientes_screen.dart';
import 'package:proyecto_av/screens/citas_screen.dart';
import 'package:proyecto_av/screens/ventas_screen.dart';
import 'package:proyecto_av/screens/login_screen.dart';
import 'package:proyecto_av/utils/session_manager.dart';
import 'package:proyecto_av/screens/perfil_screen.dart';

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
      appBar: AppBar(
        // --- ¡NUEVO WIDGET DE PERFIL! ---
        leading: Padding(
          padding: const EdgeInsets.all(8.0), // Padding para que no esté pegado
          child: GestureDetector(
            onTap: () {
              // Navegación a la pantalla de Perfil
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PerfilScreen()),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[300], // Un fondo
              child: Icon(
                Icons.person,
                color: Colors.blueGrey[900], // Color del ícono
              ),
            ),
          ),
        ),
        // ---------------------------------

        title: Text('Inicio - Corte & Paga'),

        actions: [
          // --- Botón de Logout (ya lo teníamos) ---
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              _doLogout(context);
            },
          )
        ],
      ),

      // --- BODY LIMPIO (SIN EL BOTÓN DE PERFIL) ---
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¡Bienvenido, Barbero!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),

              // Botón de Paquetes
              ElevatedButton.icon(
                icon: Icon(Icons.content_cut),
                label: Text('Administrar mis Paquetes'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaquetesScreen()),
                  );
                },
              ),
              SizedBox(height: 20),

              // Botón de Clientes
              ElevatedButton.icon(
                icon: Icon(Icons.people),
                label: Text('Administrar Clientes'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ClientesScreen()),
                  );
                },
              ),
              SizedBox(height: 20),

              // Botón de Reportes
              ElevatedButton.icon(
                icon: Icon(Icons.bar_chart, color: Colors.green[700]),
                label: Text('Corte de Caja / Reportes'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VentasScreen()),
                  );
                },
              ),

              // --- ¡BOTÓN DE PERFIL ELIMINADO DE AQUÍ! ---

            ],
          ),
        ),
      ),

      // --- FAB CORREGIDO (apunta al Calendario) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CitasScreen()),
          );
        },
        child: Icon(Icons.calendar_month),
        tooltip: 'Ver Agenda',
      ),
    );
  }
}