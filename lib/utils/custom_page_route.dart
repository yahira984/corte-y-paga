import 'package:flutter/material.dart';

// Esta es nuestra nueva clase de animación
class FadeInPageRoute extends PageRouteBuilder {
  final Widget child;

  FadeInPageRoute({required this.child})
      : super(
    // Duración de la animación (300 milisegundos)
    transitionDuration: const Duration(milliseconds: 300),

    // El constructor de la página a la que vamos
    pageBuilder: (context, animation, secondaryAnimation) => child,

    // El constructor de la animación
    transitionsBuilder: (context, animation, secondaryAnimation, page) {
      // Usamos un FadeTransition (transición de opacidad)
      return FadeTransition(
        opacity: animation,
        child: page, // 'page' es la pantalla a la que vamos (el 'child')
      );
    },
  );
}