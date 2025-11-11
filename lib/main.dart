import 'package:flutter/material.dart';
import 'package:proyecto_av/presentation/screens/login/login_screen.dart';
import 'package:proyecto_av/presentation/screens/registro/registro_screen.dart';
// 🔹 importa tu pantalla de inicio o splash si ya la tenías
import 'package:proyecto_av/presentation/screens/splash_screen.dart';

void main() {
  runApp(const CorteYPagaApp());
}

class CorteYPagaApp extends StatelessWidget {
  const CorteYPagaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corte & Paga',
      debugShowCheckedModeBanner: false,

      // 👇 si quieres que primero se vea el Splash
      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashScreen(), // tu pantalla original
        '/login': (context) => const LoginScreen(),
        '/registro': (context) => const RegistroScreen(),
      },
    );
  }
}
