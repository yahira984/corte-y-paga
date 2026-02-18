import 'package:proyecto_av/data/database/database_helper.dart';
import 'package:proyecto_av/data/models/paquete_model.dart';

class PaqueteRepository {
  final dbHelper = DatabaseHelper.instance;

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