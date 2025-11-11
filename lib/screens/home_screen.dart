import 'package:flutter/material.dart';
import 'paquetes_screen.dart';
import 'clientes_screen.dart';
import 'package:proyecto_av/screens/citas_screen.dart';
import 'package:proyecto_av/screens/ventas_screen.dart'; // <-- AÑADE ESTA LÍNEA
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Citas'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // TODO: Implementar lógica de Logout y navegar al Login
            },
          )
        ],
      ),
      // --- MODIFICA EL BODY ---
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