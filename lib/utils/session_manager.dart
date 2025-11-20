import 'package:proyecto_av/data/models/usuario_model.dart';
import 'package:proyecto_av/screens/perfil_screen.dart';
class SessionManager {

  // --- INICIO DEL PATRÓN SINGLETON ---
  // (Esto asegura que siempre usemos la MISMISIMA instancia en toda la app)
  SessionManager._privateConstructor();
  static final SessionManager instance = SessionManager._privateConstructor();
  // --- FIN DEL PATRÓN SINGLETON ---

  // Variable privada para guardar el usuario actual
  Usuario? _currentUser;

  // Getter público para obtener el usuario desde cualquier pantalla
  // Se usa así: SessionManager.instance.currentUser
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