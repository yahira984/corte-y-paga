import '../../data/database/database_helper.dart';
import '../../data/models/cliente_model.dart';

/*
* Repositorio para manejar la lógica de negocio
* de los Clientes.
*/
class ClienteRepository {

  // Obtenemos la instancia singleton de nuestro helper
  final dbHelper = DatabaseHelper.instance;

  // --- MÉTODOS PÚBLICOS QUE LA UI PODRÁ LLAMAR ---

  Future<int> insertCliente(Cliente cliente) async {
    return await dbHelper.insertCliente(cliente);
  }

  Future<List<Cliente>> getClientes() async {
    return await dbHelper.getAllClientes();
  }

  Future<int> updateCliente(Cliente cliente) async {
    return await dbHelper.updateCliente(cliente);
  }

  Future<int> deleteCliente(int id) async {
    return await dbHelper.deleteCliente(id);
  }
}