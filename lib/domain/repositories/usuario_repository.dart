import '../../data/database/database_helper.dart';
import '../../data/models/usuario_model.dart';

/*
* Repositorio para manejar la lógica de autenticación y
* gestión de usuarios (barberos).
*/
class UsuarioRepository {

  final dbHelper = DatabaseHelper.instance;

  // --- MÉTODOS PÚBLICOS ---

  // Método para el Login
  Future<Usuario?> login(String email, String password) async {
    // La UI no sabe cómo se valida, solo llama a login()
    return await dbHelper.getUsuario(email, password);
  }

  // Método para el Registro
  Future<int> registro(Usuario usuario) async {
    return await dbHelper.insertUsuario(usuario);
  }

// TODO: Agregar métodos futuros (ej: getPerfil, updatePerfil)
}