import 'package:flutter/material.dart';
import 'dart:async'; // Para el Timer

// Importar servicios y pantallas
import 'package:proyecto_av/utils/notification_service.dart';
import 'package:proyecto_av/screens/login_screen.dart';

Future<void> main() async {
  // Asegura que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa nuestro servicio de notificaciones
  await NotificationService.instance.init();
  // ------------------------------

  runApp(const CorteYPagaApp());
}

class CorteYPagaApp extends StatelessWidget {
  const CorteYPagaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corte & Paga',

      // --- ¡TEMA DE BARBERÍA "CHINGÓN"! ---
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',

        // 1. Esquema de Color (Paleta de Barbería)
        colorScheme: ColorScheme.light(
          primary: Color(0xFF37474F), // Azul-Gris oscuro
          secondary: Color(0xFFBCAAA4), // Tono "madera" o "cuero" claro
          background: Colors.grey[100]!, // Blanco "roto"
          surface: Colors.white, // Color de las tarjetas
          primaryContainer: Colors.green[700], // Acentos de precios
          error: Colors.red.shade700, // Color para errores
        ),

        // 2. Estilo de los Botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF37474F), // Azul-Gris oscuro
              foregroundColor: Colors.white, // Texto blanco
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              )),
        ),

        // 3. Estilo del AppBar (Barra superior)
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // AppBar blanca
          foregroundColor: Color(0xFF37474F), // Texto/íconos oscuros
          elevation: 2,
          titleTextStyle: TextStyle(
            color: Color(0xFF37474F),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
          iconTheme: IconThemeData(
            color: Color(0xFF37474F), // Íconos
          ),
        ),

        // 4. Estilo de las tarjetas (Cards)
        // --- ¡AQUÍ ESTÁ LA CORRECCIÓN! ---
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ), // <-- ¡CORREGIDO A "CardThemeData"!

        // 5. Estilo de los campos de texto
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF37474F), width: 2),
          ),
          labelStyle: TextStyle(
            color: Colors.grey[700],
          ),
        ),

      ), // <-- Aquí se cierra el ThemeData
      // ---------------------------------------------

      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    ); // <-- Aquí se cierra el MaterialApp
  } // <-- Aquí se cierra el build
} // <-- Aquí se cierra la clase CorteYPagaApp

// --- PANTALLA DE SPLASH ---
class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 6. Llamamos a nuestra función de navegación al iniciar
    _navigateToLogin();
  }

  void _navigateToLogin() {
    // 7. Creamos el Timer de 8 segundos
    Timer(const Duration(seconds: 8), () {
      // 8. Navegamos y REEMPLAZAMOS la pantalla
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  // 9. Movemos el método 'build' aquí
  @override
  Widget build(BuildContext context) {
    // ¡Splash Screen con los nuevos colores!
    return Scaffold(
      backgroundColor: Color(0xFF37474F), // Fondo oscuro
      body: Center(
        child: Text(
          '💈 Corte & Paga 💈',
          style: TextStyle(
            color: Colors.white, // Texto blanco
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}