import 'package:flutter/material.dart';
import 'package:proyecto_av/domain/repositories/cita_repository.dart';
import 'package:proyecto_av/domain/repositories/cliente_repository.dart';
import 'package:proyecto_av/domain/repositories/paquete_repository.dart';
import 'package:proyecto_av/domain/repositories/venta_repository.dart';
import 'package:proyecto_av/data/models/cita_model.dart';
import 'package:proyecto_av/data/models/venta_model.dart';
import 'package:proyecto_av/data/models/paquete_model.dart';
import 'package:proyecto_av/screens/cita_form_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({Key? key}) : super(key: key);

  @override
  _CitasScreenState createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> with SingleTickerProviderStateMixin {
  final _citaRepo = CitaRepository();
  final _clienteRepo = ClienteRepository();
  final _paqueteRepo = PaqueteRepository();
  final _ventaRepo = VentaRepository();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Cita> _citasDelDia = [];
  Map<int, String> _nombresClientes = {};
  Map<int, Paquete> _mapaPaquetes = {};
  Map<int, String?> _telefonosClientes = {}; // <-- mapa de teléfonos

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_MX', null);
    _selectedDay = _focusedDay;
    _loadAllData();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await _loadNombresYPaquetes();
    await _loadDataForDay(_selectedDay!);
    // start animation after load
    _animController.forward(from: 0);
  }

  Future<void> _loadDataForDay(DateTime day) async {
    final citas = await _citaRepo.getCitasPorDia(day);
    setState(() {
      _citasDelDia = citas;
    });
  }

  // Cargamos nombres, paquetes y telefonos (sin tocar DB)
  Future<void> _loadNombresYPaquetes() async {
    final clientes = await _clienteRepo.getClientes();
    final paquetes = await _paqueteRepo.getPaquetes();
    setState(() {
      _nombresClientes = {for (var c in clientes) c.id!: c.nombre};
      _mapaPaquetes = {for (var p in paquetes) p.id!: p};
      _telefonosClientes = {for (var c in clientes) c.id!: c.telefono};
    });
  }

  String _getNombreCliente(int id) => _nombresClientes[id] ?? 'Cliente Borrado';

  String _getDescripcionServicio(Cita cita) {
    if (cita.idPaquete != null) {
      return _mapaPaquetes[cita.idPaquete]?.nombre ?? 'Paquete Borrado';
    }
    return cita.customDescripcion ?? 'Servicio Personalizado';
  }

  // --- LÓGICA DE ESTADOS (sin modificación) ---
  Future<void> _completarCita(Cita cita) async {
    double precio = cita.customPrecio ?? 0.0;
    if (cita.idPaquete != null) {
      precio = _mapaPaquetes[cita.idPaquete]?.precio ?? 0.0;
    }

    final venta = Venta(
      idCita: cita.id!,
      montoTotal: precio,
      fechaVenta: DateTime.now().toIso8601String(),
    );
    await _ventaRepo.registrarVenta(venta);

    await _citaRepo.updateCita(cita.copyWith(estado: 'completada'));
    _loadDataForDay(_selectedDay!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Cita completada y venta registrada!')),
    );
  }

  Future<void> _marcarPendiente(Cita cita) async {
    await _citaRepo.updateCita(cita.copyWith(estado: 'programada'));
    _loadDataForDay(_selectedDay!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cita marcada como pendiente.')),
    );
  }

  Future<void> _eliminarCita(Cita cita) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cita'),
        content: const Text('¿Estás seguro? Esto borrará la cita permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await _citaRepo.deleteCita(cita.id!);
      _loadDataForDay(_selectedDay!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita eliminada.')));
    }
  }

  // --- MENÚ DE OPCIONES AL TOCAR ---
  void _showCitaOptions(Cita cita) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Opciones de Cita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),

              if (cita.estado == 'programada')
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Completar Cita'),
                  onTap: () {
                    Navigator.pop(context);
                    _completarCita(cita);
                  },
                ),

              if (cita.estado == 'completada')
                ListTile(
                  leading: const Icon(Icons.undo, color: Colors.orange),
                  title: const Text('Marcar como Pendiente'),
                  onTap: () {
                    Navigator.pop(context);
                    _marcarPendiente(cita);
                  },
                ),

              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Editar Cita'),
                onTap: () {
                  Navigator.pop(context);
                  if (cita.estado == 'programada') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CitaFormScreen(cita: cita, diaSeleccionado: _selectedDay),
                      ),
                    ).then((_) => _loadAllData());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se puede editar una cita completada.')));
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar Cita'),
                onTap: () {
                  Navigator.pop(context);
                  _eliminarCita(cita);
                },
              ),

              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  // --------------------------
  // WHATSAPP: función que abre chat con mensaje personalizado (Opción A)
  // --------------------------
  Future<void> _abrirWhatsappParaCita({required int clienteId, required DateTime fechaHora}) async {
    final telefonoRaw = _telefonosClientes[clienteId];
    if (telefonoRaw == null || telefonoRaw.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Este cliente no tiene número registrado')));
      return;
    }

    // Limpiamos el número (solo dígitos)
    final telefono = telefonoRaw.replaceAll(RegExp(r'[^0-9]'), '');
    if (telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Número inválido')));
      return;
    }

    // Formateamos fecha y hora
    final dia = DateFormat.yMMMMd('es_MX').format(fechaHora);
    final hora = DateFormat.jm('es_MX').format(fechaHora);
    final nombre = _nombresClientes[clienteId] ?? '';

    final mensaje = Uri.encodeComponent('Hola $nombre, te escribimos de Corte & Paga para confirmar tu cita del $dia a las $hora.');

    final uri = Uri.parse('https://wa.me/$telefono?text=$mensaje');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir WhatsApp')));
    }
  }

  // --------------------------
  // Build
  // --------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      // Banner negro con título blanco
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Agenda de Citas',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat.yMMMMd('es_MX').format(_selectedDay ?? DateTime.now()),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Calendario dentro de una tarjeta blanca con sombra
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
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
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black87),
                    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black87),
                    titleTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.12), shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    markerDecoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Fecha + cantidad de citas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMMd('es_MX').format(_selectedDay ?? DateTime.now()),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                ),
                Text('${_citasDelDia.length} Citas', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lista de citas
          Expanded(
            child: _citasDelDia.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text('Sin citas programadas', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _citasDelDia.length,
              itemBuilder: (context, index) {
                final cita = _citasDelDia[index];
                final fechaHora = DateTime.parse(cita.fechaHora);
                final esCompletada = cita.estado == 'completada';

                // animación por índice
                final anim = CurvedAnimation(
                  parent: _animController,
                  curve: Interval((index * 0.06).clamp(0.0, 0.9), 1.0, curve: Curves.easeOutCubic),
                );

                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(anim),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: esCompletada ? Colors.green.withOpacity(0.12) : Colors.grey.shade100),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6))],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showCitaOptions(cita),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                // Hora
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('h:mm', 'es_MX').format(fechaHora),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat('a', 'es_MX').format(fechaHora),
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 16),

                                // barra vertical
                                Container(height: 44, width: 2, color: Colors.grey.shade100),

                                const SizedBox(width: 16),

                                // Info principal + botón WhatsApp
                                Expanded(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Info principal
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _getNombreCliente(cita.idCliente),
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              _getDescripcionServicio(cita),
                                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // BOTÓN WHATSAPP (usa el número cargado en _telefonosClientes)
                                      IconButton(
                                        icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 26),
                                        onPressed: () => _abrirWhatsappParaCita(clienteId: cita.idCliente, fechaHora: fechaHora),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Estado
                                Column(
                                  children: [
                                    if (esCompletada)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.check_circle, color: Colors.green, size: 18),
                                            SizedBox(width: 6),
                                            Text('Completada', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.pending, color: Colors.grey[600], size: 18),
                                            const SizedBox(width: 6),
                                            Text('Programada', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CitaFormScreen(diaSeleccionado: _selectedDay),
            ),
          ).then((_) => _loadAllData());
        },
      ),
    );
  }
}
