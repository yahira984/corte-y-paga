import 'package:flutter/material.dart';
import 'dart:async'; // <-- 1. Importante para el Timer

// 2. Importamos la pantalla de Login que creaste
import 'screens/login_screen.dart';
import 'package:proyecto_av/utils/notification_service.dart';

Future<void> main() async {
  // --- SE AÑADEN ESTAS LÍNEAS ---
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      // 3. Quitamos el 'const' porque SplashScreen ya no es constante
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 4. Convertimos a StatefulWidget
class SplashScreen extends StatefulWidget {
  // Quitamos el 'const'
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// 5. Creamos la clase 'State' que maneja la lógica
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
      //    Usamos pushReplacement para que el usuario no pueda
      //    presionar "atrás" y volver al splash.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  // 9. Movemos el método 'build' aquí
  @override
  Widget build(BuildContext context) {
    // Este es tu mismo código de UI, no cambió nada
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          '💈 Corte & Paga 💈',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}