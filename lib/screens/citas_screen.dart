import 'package:flutter/material.dart';
import 'package:proyecto_av/domain/repositories/cita_repository.dart';
import 'package:proyecto_av/domain/repositories/cliente_repository.dart';
import 'package:proyecto_av/domain/repositories/paquete_repository.dart';
import 'package:proyecto_av/domain/repositories/venta_repository.dart'; // <-- ¡NUEVO!
import 'package:proyecto_av/data/models/cita_model.dart';
import 'package:proyecto_av/data/models/venta_model.dart'; // <-- ¡NUEVO!
import 'package:proyecto_av/data/models/paquete_model.dart'; // <-- Para buscar precio
import 'package:proyecto_av/screens/cita_form_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({Key? key}) : super(key: key);

  @override
  _CitasScreenState createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  // Repositorios
  final _citaRepo = CitaRepository();
  final _clienteRepo = ClienteRepository();
  final _paqueteRepo = PaqueteRepository();
  final _ventaRepo = VentaRepository(); // <-- ¡NUEVO!

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Cita> _citasDelDia = [];

  // Ahora guardamos los objetos Paquete completos
  Map<int, String> _nombresClientes = {};
  Map<int, Paquete> _mapaPaquetes = {}; // <-- ¡CAMBIO!

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_MX', null);

    _selectedDay = _focusedDay;
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await _loadNombresYPaquetes();
    await _loadDataForDay(_selectedDay!);
  }

  Future<void> _loadDataForDay(DateTime day) async {
    final citas = await _citaRepo.getCitasPorDia(day);
    setState(() {
      _citasDelDia = citas;
    });
  }

  // Carga nombres y también los paquetes completos
  Future<void> _loadNombresYPaquetes() async {
    final clientes = await _clienteRepo.getClientes();
    final paquetes = await _paqueteRepo.getPaquetes();

    setState(() {
      _nombresClientes = {for (var c in clientes) c.id!: c.nombre};
      _mapaPaquetes = {for (var p in paquetes) p.id!: p}; // <-- ¡CAMBIO!
    });
  }

  String _getNombreCliente(int id) {
    return _nombresClientes[id] ?? 'Cliente Borrado';
  }

  String _getDescripcionServicio(Cita cita) {
    if (cita.idPaquete != null) {
      return _mapaPaquetes[cita.idPaquete]?.nombre ?? 'Paquete Borrado';
    }
    return cita.customDescripcion ?? 'Servicio Personalizado';
  }

  // --- ¡NUEVA FUNCIÓN PARA COMPLETAR CITA Y GENERAR VENTA! ---
  Future<void> _completarCita(Cita cita) async {
    // 1. Confirmar con el usuario
    final bool didConfirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Completar Cita'),
        content: Text('¿Confirmas que este servicio se ha completado? Esto generará la venta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Completar'),
          ),
        ],
      ),
    ) ?? false;

    if (!didConfirm) return;

    // 2. Determinar el precio
    double precioFinal = 0.0;
    if (cita.idPaquete != null) {
      // Es un paquete
      precioFinal = _mapaPaquetes[cita.idPaquete]?.precio ?? 0.0;
    } else {
      // Es personalizado
      precioFinal = cita.customPrecio ?? 0.0;
    }

    // 3. Crear el objeto Venta
    final nuevaVenta = Venta(
      idCita: cita.id!,
      montoTotal: precioFinal,
      fechaVenta: DateTime.now().toIso8601String(), // La venta se registra ahora
    );

    try {
      // 4. Guardar la Venta
      await _ventaRepo.registrarVenta(nuevaVenta);

      // 5. Actualizar estado de la Cita
      final citaActualizada = cita.copyWith(estado: 'completada');
      await _citaRepo.updateCita(citaActualizada);

      // 6. Refrescar la lista
      _loadDataForDay(_selectedDay!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Cita completada y venta registrada!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar la venta: $e')),
      );
    }
  }

  void _navigateAndRefresh({Cita? cita}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CitaFormScreen(
          cita: cita,
          diaSeleccionado: _selectedDay,
        ),
      ),
    ).then((_) {
      _loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda de Citas'),
      ),
      body: Column(
        children: [
          TableCalendar(
            // ... (Toda la configuración del TableCalendar - sin cambios) ...
            locale: 'es_MX',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadDataForDay(selectedDay);
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Citas para el ${DateFormat.yMMMMd('es_MX').format(_selectedDay!)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: _citasDelDia.isEmpty
                ? Center(
              child: Text('No hay citas para este día.'),
            )
                : ListView.builder(
              itemCount: _citasDelDia.length,
              itemBuilder: (context, index) {
                final cita = _citasDelDia[index];
                final fechaHora = DateTime.parse(cita.fechaHora);

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      // --- ¡CAMBIO! Color según estado ---
                      backgroundColor: cita.estado == 'completada'
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                      child: Icon(
                        cita.estado == 'completada'
                            ? Icons.check
                            : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(_getNombreCliente(cita.idCliente)),
                    subtitle: Text(_getDescripcionServicio(cita)),

                    // --- ¡TRAILING ACTUALIZADO! ---
                    trailing: Wrap(
                      spacing: -10, // Juntar los botones
                      children: [
                        Text(
                          DateFormat.jm('es_MX').format(fechaHora),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 2.5, // Para centrarlo verticalmente
                          ),
                        ),

                        if (cita.estado == 'programada')
                        // Botón para Completar Cita
                          IconButton(
                            icon: Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _completarCita(cita),
                            tooltip: 'Completar cita',
                          )
                        else
                        // Pastilla de "Completada"
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                            child: Chip(
                              label: Text('Hecho'),
                              backgroundColor: Colors.green[50],
                              labelStyle: TextStyle(color: Colors.green[800]),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      // Solo dejamos editar si está programada
                      if (cita.estado == 'programada') {
                        _navigateAndRefresh(cita: cita);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateAndRefresh();
        },
        child: Icon(Icons.add),
        tooltip: 'Agendar nueva cita',
      ),
    );
  }
}