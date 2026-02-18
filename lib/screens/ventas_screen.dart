import 'package:flutter/material.dart';
import 'package:proyecto_av/domain/repositories/venta_repository.dart';
import 'package:proyecto_av/data/models/venta_model.dart';
import 'package:proyecto_av/screens/ventas_detalle_screen.dart';
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
    setState(() => _isLoading = true);

    DateTime now = DateTime.now();

<<<<<<< HEAD
    // --- ¡AQUÍ ESTÁ LA CORRECCIÓN! ---
    // 1. Definimos el inicio exacto de hoy (00:00)
=======
>>>>>>> 99d891abe10cac4ce26c79aace8edf7cbc8d1679
    DateTime inicioDeHoy = DateTime(now.year, now.month, now.day);
    DateTime finDeHoy = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final ventasHoy = await _ventaRepo.getVentasPorRango(inicioDeHoy, finDeHoy);
    double totalHoy =
    ventasHoy.fold(0.0, (sum, venta) => sum + venta.montoTotal);

    DateTime inicioDeSemana = now.subtract(Duration(days: now.weekday - 1));
    inicioDeSemana =
        DateTime(inicioDeSemana.year, inicioDeSemana.month, inicioDeSemana.day);
    final ventasSemana =
    await _ventaRepo.getVentasPorRango(inicioDeSemana, now);
    double totalSemana =
    ventasSemana.fold(0.0, (sum, venta) => sum + venta.montoTotal);

    DateTime inicioDeMes = DateTime(now.year, now.month, 1);
    final ventasMes = await _ventaRepo.getVentasPorRango(inicioDeMes, now);
    double totalMes =
    ventasMes.fold(0.0, (sum, venta) => sum + venta.montoTotal);

    setState(() {
      _ventasDelDia = ventasHoy;
      _totalHoy = totalHoy;
      _totalSemana = totalSemana;
      _totalMes = totalMes;
      _isLoading = false;
    });
  }

  Future<void> _verDetalle(
      String titulo, DateTime inicio, DateTime fin) async {
    final ventas = await _ventaRepo.getVentasPorRango(inicio, fin);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VentasDetalleScreen(titulo: titulo, ventas: ventas),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime inicioDeSemana = now.subtract(Duration(days: now.weekday - 1));
    inicioDeSemana =
        DateTime(inicioDeSemana.year, inicioDeSemana.month, inicioDeSemana.day);
    DateTime inicioDeMes = DateTime(now.year, now.month, 1);

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fa),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Text('Reporte de Ventas', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blueAccent),
            onPressed: _loadReportes,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12),

            _buildAnimatedCard(
              title: "Ganancias de Hoy",
              amount: _totalHoy,
              icon: Icons.today,
              color1: Colors.green.shade400,
              color2: Colors.green.shade700,
            ),

            _buildAnimatedCard(
              title: "Esta Semana",
              amount: _totalSemana,
              icon: Icons.date_range,
              color1: Colors.blue.shade400,
              color2: Colors.blue.shade700,
              onTap: () => _verDetalle("Ventas de la Semana", inicioDeSemana, now),
            ),

            _buildAnimatedCard(
              title: "Este Mes",
              amount: _totalMes,
              icon: Icons.calendar_month,
              color1: Colors.orange.shade400,
              color2: Colors.orange.shade700,
              onTap: () => _verDetalle("Ventas del Mes", inicioDeMes, now),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 10),
              child: Row(
                children: [
                  Text(
                    "Movimientos de Hoy",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),

            _ventasDelDia.isEmpty
                ? Padding(
              padding: const EdgeInsets.all(35.0),
              child: Text("Sin ventas hoy.",
                  style:
                  TextStyle(fontSize: 16, color: Colors.grey)),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _ventasDelDia.length,
              itemBuilder: (context, index) {
                final venta = _ventasDelDia[index];
                final fecha = DateTime.parse(venta.fechaVenta);

                return Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long,
                          color: Colors.green.shade700),
                    ),
                    title: Text(
                      DateFormat.jm('es_MX').format(fecha),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat("d 'de' MMMM", 'es_MX')
                          .format(fecha),
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 13),
                    ),
                    trailing: Text(
                      "+\$${venta.montoTotal.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // 🔥 Tarjetas estilo Shopify / Stripe
  Widget _buildAnimatedCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color1,
    required Color color2,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 350),
        curve: Curves.easeOut,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color2.withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 6),
                  Text(
                    "\$${amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: onTap != null ? Colors.white : Colors.white54, size: 28),
          ],
        ),
      ),
    );
  }
}
