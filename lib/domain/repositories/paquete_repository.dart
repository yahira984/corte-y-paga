import '../../data/database/database_helper.dart';
import '../../data/models/paquete_model.dart';

/*
* Esta clase es el puente (repositorio) entre la Lógica de Negocio/UI
* y la Capa de Acceso a Datos (DatabaseHelper).
* Su trabajo es pedir los datos al Helper.
*/
class PaqueteRepository {

  // Obtenemos la instancia singleton de nuestro helper
  final dbHelper = DatabaseHelper.instance;

  // --- MÉTODOS PÚBLICOS QUE LA UI PODRÁ LLAMAR ---

  Future<int> insertPaquete(Paquete paquete) async {
    return await dbHelper.insertPaquete(paquete);
  }

  Future<List<Paquete>> getPaquetes() async {
    return await dbHelper.getAllPaquetes();
  }

  Future<int> updatePaquete(Paquete paquete) async {
    return await dbHelper.updatePaquete(paquete);
  }

  Future<int> deletePaquete(int id) async {
    return await dbHelper.deletePaquete(id);
  }
}