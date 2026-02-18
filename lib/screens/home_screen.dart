import 'package:flutter/material.dart';

// Imports absolutos
import 'package:proyecto_av/screens/paquetes_screen.dart';
import 'package:proyecto_av/screens/clientes_screen.dart';
import 'package:proyecto_av/screens/citas_screen.dart';
import 'package:proyecto_av/screens/ventas_screen.dart';
import 'package:proyecto_av/screens/login_screen.dart';
import 'package:proyecto_av/screens/perfil_screen.dart';
import 'package:proyecto_av/screens/venta_rapida_screen.dart';
import 'package:proyecto_av/utils/session_manager.dart';
import 'package:proyecto_av/utils/custom_page_route.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // --- Logout ---
  Future<void> _doLogout(BuildContext context) async {
    final bool didConfirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Seguro que deseas salir?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
              const Text('Salir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ??
        false;

    if (!didConfirm) return;

    if (context.mounted) {
      SessionManager.instance.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // -------------------------
      //      APP BAR BLANCO
      // -------------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Inicio - Corte & Paga',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              FadeInPageRoute(child: const PerfilScreen()),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.red.shade700,
            onPressed: () => _doLogout(context),
          )
        ],
      ),

      // -------------------------
      //           BODY
      // -------------------------
      body: FadeTransition(
        opacity: _fadeController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // -------------------------
              //     SALUDO PREMIUM
              // -------------------------
              Text(
                '¡Bienvenido, Barbero!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),

              // -------------------------
              // IMAGEN PRINCIPAL PREMIUM
              // -------------------------
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/home_bg.png',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.65),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // -------------------------
              //     BOTONES DE MENÚ
              // -------------------------
              _menuButton(
                label: 'Administrar mis Paquetes',
                icon: Icons.content_cut,
                onTap: () => Navigator.push(context,
                    FadeInPageRoute(child: const PaquetesScreen())),
              ),
              const SizedBox(height: 16),

              _menuButton(
                label: 'Administrar Clientes',
                icon: Icons.people,
                onTap: () => Navigator.push(context,
                    FadeInPageRoute(child: const ClientesScreen())),
              ),
              const SizedBox(height: 16),

              _menuButton(
                label: 'Venta Rápida (Sin Cita)',
                icon: Icons.point_of_sale,
                color1: Colors.amber.shade900,
                color2: Colors.amber.shade800,
                onTap: () => Navigator.push(context,
                    FadeInPageRoute(child: const VentaRapidaScreen())),
              ),
              const SizedBox(height: 16),

              _menuButton(
                label: 'Corte de Caja / Reportes',
                icon: Icons.bar_chart,
                color1: Colors.green.shade900,
                color2: Colors.green.shade800,
                onTap: () => Navigator.push(
                    context, FadeInPageRoute(child: const VentasScreen())),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),

      // -------------------------
      //   FAB — Calendario
      // -------------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => Navigator.push(
          context,
          FadeInPageRoute(child: const CitasScreen()),
        ),
        child: const Icon(Icons.calendar_month, color: Colors.white),
      ),
    );
  }

  // ----------------------------------------------------
  //      BOTÓN ANIMADO NEGRO PREMIUM
  // ----------------------------------------------------
  Widget _menuButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? color1,
    Color? color2,
  }) {
    final c1 = color1 ?? Colors.black87;
    final c2 = color2 ?? Colors.black;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.90, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (_, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c1, c2]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
