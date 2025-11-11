import 'package:flutter/material.dart';
import 'package:proyecto_av/domain/repositories/venta_repository.dart';
import 'package:proyecto_av/data/models/venta_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({Key? key}) : super(key: key);

  @override
  _VentasScreenState createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final _ventaRepo = VentaRepository();
  bool _isLoading = true;

  List<Venta> _ventasDelDia = [];
  double _totalHoy = 0.0;
  double _totalSemana = 0.0;
  double _totalMes = 0.0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_MX', null);
    _loadReportes();
  }

  Future<void> _loadReportes() async {
    setState(() { _isLoading = true; });

    DateTime now = DateTime.now();

    // --- ¡AQUÍ ESTÁ LA CORRECCIÓN! ---
    // 1. Definimos el inicio exacto de hoy (00:00
    DateTime inicioDeHoy = DateTime(now.year, now.month, now.day);
    // 2. Definimos el fin exacto de hoy (23:59:59)
    DateTime finDeHoy = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // 3. Usamos el rango exacto para pedir las ventas de HOY
    final ventasHoy = await _ventaRepo.getVentasPorRango(inicioDeHoy, finDeHoy);
    double totalHoy = ventasHoy.fold(0.0, (sum, venta) => sum + venta.montoTotal);
    // --- FIN DE LA CORRECCIÓN ---

    // --- Calcular Total de la Semana ---
    DateTime inicioDeSemana = now.subtract(Duration(days: now.weekday - 1));
    inicioDeSemana = DateTime(inicioDeSemana.year, inicioDeSemana.month, inicioDeSemana.day);
    // Usamos 'now' como fin, lo cual está bien
    final ventasSemana = await _ventaRepo.getVentasPorRango(inicioDeSemana, now);
    double totalSemana = ventasSemana.fold(0.0, (sum, venta) => sum + venta.montoTotal);

    // --- Calcular Total del Mes ---
    DateTime inicioDeMes = DateTime(now.year, now.month, 1);
    // Usamos 'now' como fin, lo cual está bien
    final ventasMes = await _ventaRepo.getVentasPorRango(inicioDeMes, now);
    double totalMes = ventasMes.fold(0.0, (sum, venta) => sum + venta.montoTotal);

    // 3. Actualizar la UI
    setState(() {
      _ventasDelDia = ventasHoy;
      _totalHoy = totalHoy;
      _totalSemana = totalSemana;
      _totalMes = totalMes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Corte de Caja y Reportes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReportes,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // --- Tarjetas de Totales ---
          _buildTotalCard(
            'Ganancias de Hoy',
            _totalHoy,
            Colors.green,
          ),
          _buildTotalCard(
            'Ganancias de la Semana',
            _totalSemana,
            Colors.blue,
          ),
          _buildTotalCard(
            'Ganancias del Mes',
            _totalMes,
            Colors.orange,
          ),

          // --- Lista de Ventas del Día ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Ventas Registradas Hoy',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          Expanded(
            child: _ventasDelDia.isEmpty
                ? Center(
              child: Text('Aún no hay ventas registradas hoy.'),
            )
                : ListView.builder(
              itemCount: _ventasDelDia.length,
              itemBuilder: (context, index) {
                final venta = _ventasDelDia[index];
                final fechaVenta = DateTime.parse(venta.fechaVenta);

                return ListTile(
                  leading: Icon(Icons.receipt_long, color: Colors.green[700]),
                  title: Text('Venta a las ${DateFormat.jm('es_MX').format(fechaVenta)}'),
                  trailing: Text(
                    '+\$${venta.montoTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper para crear las tarjetas bonitas
  Widget _buildTotalCard(String title, double amount, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}