import 'package:flutter/material.dart';
import 'paquetes_screen.dart';
import 'clientes_screen.dart';
import 'package:proyecto_av/screens/citas_screen.dart';
import 'package:proyecto_av/screens/ventas_screen.dart'; // <-- AÑADE ESTA LÍNEA
import 'package:proyecto_av/screens/login_screen.dart'; // <-- ¡NUEVO IMPORT!

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // --- ¡NUEVA FUNCIÓN DE LOGOUT! ---
  Future<void> _doLogout(BuildContext context) async {
    // 1. Mostrar diálogo de confirmación
    final bool didConfirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres salir?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // No
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Sí
              child: Text('Salir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false; // Si el usuario cierra el diálogo, es 'false'

    if (!didConfirm) return;

    // 2. Si confirmó, navegar al Login y borrar el historial
    //    (El 'context' debe ser 'mounted' para usarse aquí)
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false, // Esta línea borra todas las rutas
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio - Corte & Paga'),
        actions: [
          // --- ¡BOTÓN DE LOGOUT ACTUALIZADO! ---
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              // Llamamos a nuestra nueva función
              _doLogout(context);
            },
          )
        ],
      ),
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
              // ------------------------
              SizedBox(height: 20),

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
              // ------------------------
              SizedBox(height: 20),

              ElevatedButton.icon(
                icon: Icon(Icons.calendar_month),
                label: Text('Agendar Citas'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CitasScreen()),
                  );
                },
              ),
              // --- ¡AÑADE ESTE WIDGET DE AQUÍ ABAJO! ---
              SizedBox(height: 20), // Un separador

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
// ---------------------------------------------



            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar a la pantalla de "Crear Cita"
        },
        child: Icon(Icons.add),
      ),
    );
  }
}