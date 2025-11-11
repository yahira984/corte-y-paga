import 'package:proyecto_av/data/models/usuario_model.dart';

class SessionManager {

  // --- INICIO DEL PATRÓN SINGLETON ---
  SessionManager._privateConstructor();
  static final SessionManager instance = SessionManager._privateConstructor();
  // --- FIN DEL PATRÓN SINGLETON ---

  // Variable privada para guardar el usuario
  Usuario? _currentUser;

  // Getter público para obtener el usuario
  Usuario? get currentUser => _currentUser;

  // Método para "guardar" el usuario al iniciar sesión
  void login(Usuario usuario) {
    _currentUser = usuario;
  }

  // Método para "borrar" el usuario al cerrar sesión
  void logout() {
    _currentUser = null;
  }
}