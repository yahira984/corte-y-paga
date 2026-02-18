import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_av/data/models/venta_model.dart';

class VentasDetalleScreen extends StatelessWidget {
  final String titulo;
  final List<Venta> ventas;

  const VentasDetalleScreen({
    Key? key,
    required this.titulo,
    required this.ventas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = ventas.fold(0.0, (sum, venta) => sum + venta.montoTotal);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // ---------- HEADER PRO ----------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Total del Periodo',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // ---------- LISTA DE VENTAS ----------
          Expanded(
            child: ventas.isEmpty
                ? const Center(
              child: Text(
                'No hay ventas en este periodo.',
                style: TextStyle(fontSize: 17),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ventas.length,
              itemBuilder: (context, index) {
                final venta = ventas[index];
                final fechaVenta = DateTime.parse(venta.fechaVenta);

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.green[100],
                      child: Icon(
                        Icons.attach_money_rounded,
                        size: 28,
                        color: Colors.green[800],
                      ),
                    ),
                    title: Text(
                      '${DateFormat.MMMd('es_MX').format(fechaVenta)} - ${DateFormat.jm('es_MX').format(fechaVenta)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Venta #${venta.id}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+\$${venta.montoTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
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
}
