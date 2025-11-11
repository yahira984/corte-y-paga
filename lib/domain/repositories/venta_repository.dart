import 'package:proyecto_av/data/database/database_helper.dart';
import 'package:proyecto_av/data/models/venta_model.dart';

/*
* Repositorio para manejar la lógica de negocio
* de las Ventas y Reportes.
*/
class VentaRepository {

  final dbHelper = DatabaseHelper.instance;

  // Método para registrar una nueva venta
  Future<int> registrarVenta(Venta venta) async {
    return await dbHelper.insertVenta(venta);
  }

  // Método para obtener el reporte de un día
  Future<List<Venta>> getVentasDelDia(DateTime dia) async {
    // El rango es el mismo día (inicio y fin)
    return await dbHelper.getVentasPorRango(dia, dia);
  }

  // Método para obtener un reporte por rango (semanal, mensual)
  Future<List<Venta>> getVentasPorRango(DateTime inicio, DateTime fin) async {
    return await dbHelper.getVentasPorRango(inicio, fin);
  }
}