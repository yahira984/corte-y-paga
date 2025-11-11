import 'package:flutter/material.dart';
import 'package:proyecto_av/domain/repositories/cita_repository.dart';
import 'package:proyecto_av/domain/repositories/cliente_repository.dart';
import 'package:proyecto_av/domain/repositories/paquete_repository.dart';
import 'package:proyecto_av/data/models/cita_model.dart';
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
  final _citaRepo = CitaRepository();
  final _clienteRepo = ClienteRepository();
  final _paqueteRepo = PaqueteRepository();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Cita> _citasDelDia = [];

  Map<int, String> _nombresClientes = {};
  Map<int, String> _nombresPaquetes = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_MX', null);

    _selectedDay = _focusedDay;
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await _loadNombres();
    await _loadDataForDay(_selectedDay!);
  }

  Future<void> _loadDataForDay(DateTime day) async {
    final citas = await _citaRepo.getCitasPorDia(day);
    setState(() {
      _citasDelDia = citas;
    });
  }

  Future<void> _loadNombres() async {
    final clientes = await _clienteRepo.getClientes();
    final paquetes = await _paqueteRepo.getPaquetes();

    setState(() {
      _nombresClientes = { for (var c in clientes) c.id! : c.nombre };
      _nombresPaquetes = { for (var p in paquetes) p.id! : p.nombre };
    });
  }

  String _getNombreCliente(int id) {
    return _nombresClientes[id] ?? 'Cliente Borrado';
  }

  // --- FUNCIÓN ACTUALIZADA ---
  // Ahora devuelve el nombre del paquete o la descripción personalizada
  String _getDescripcionServicio(Cita cita) {
    if (cita.idPaquete != null) {
      return _nombresPaquetes[cita.idPaquete] ?? 'Paquete Borrado';
    }
    return cita.customDescripcion ?? 'Servicio Personalizado';
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

          // --- Lista de Citas ---
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
                      child: Icon(Icons.person),
                    ),
                    title: Text(_getNombreCliente(cita.idCliente)),
                    // --- SUBTÍTULO ACTUALIZADO ---
                    subtitle: Text(_getDescripcionServicio(cita)),
                    trailing: Text(
                      DateFormat.jm('es_MX').format(fechaHora),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onTap: () {
                      _navigateAndRefresh(cita: cita);
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