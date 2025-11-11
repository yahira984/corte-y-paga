import 'package:flutter/material.dart';
import 'package:proyecto_av/domain/repositories/cita_repository.dart';
import 'package:proyecto_av/domain/repositories/cliente_repository.dart';
import 'package:proyecto_av/domain/repositories/paquete_repository.dart';
import 'package:proyecto_av/data/models/cita_model.dart';
import 'package:proyecto_av/data/models/cliente_model.dart';
import 'package:proyecto_av/data/models/paquete_model.dart';
import 'package:proyecto_av/screens/cliente_form_screen.dart';
import 'package:intl/intl.dart';

class CitaFormScreen extends StatefulWidget {
  final Cita? cita;
  final DateTime? diaSeleccionado;

  const CitaFormScreen({Key? key, this.cita, this.diaSeleccionado}) : super(key: key);

  @override
  _CitaFormScreenState createState() => _CitaFormScreenState();
}

class _CitaFormScreenState extends State<CitaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Repositorios
  final _citaRepo = CitaRepository();
  final _clienteRepo = ClienteRepository();
  final _paqueteRepo = PaqueteRepository();

  // Listas para los Dropdowns
  List<Cliente> _clientes = [];
  List<Paquete> _paquetes = [];

  // Valores seleccionados
  Cliente? _selectedCliente;
  Paquete? _selectedPaquete;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // --- ¡NUEVO ESTADO! ---
  bool _esServicioPersonalizado = false;
  final _customDescController = TextEditingController();
  final _customPrecioController = TextEditingController();

  bool _isLoading = true;
  bool get _isEditing => widget.cita != null;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() { _isLoading = true; });

    final clientes = await _clienteRepo.getClientes();
    final paquetes = await _paqueteRepo.getPaquetes();

    setState(() {
      _clientes = clientes;
      _paquetes = paquetes;

      if (_isEditing) {
        // --- LÓGICA DE EDICIÓN ACTUALIZADA ---
        _selectedCliente = clientes.firstWhere((c) => c.id == widget.cita!.idCliente);
        final fechaHora = DateTime.parse(widget.cita!.fechaHora);
        _selectedDate = fechaHora;
        _selectedTime = TimeOfDay.fromDateTime(fechaHora);

        // Revisa si es un paquete o un servicio personalizado
        if (widget.cita!.idPaquete != null) {
          _esServicioPersonalizado = false;
          _selectedPaquete = paquetes.firstWhere((p) => p.id == widget.cita!.idPaquete);
        } else {
          _esServicioPersonalizado = true;
          _customDescController.text = widget.cita!.customDescripcion ?? '';
          _customPrecioController.text = widget.cita!.customPrecio?.toString() ?? '';
        }

      } else {
        _selectedDate = widget.diaSeleccionado;
      }

      _isLoading = false;
    });
  }

  Future<void> _addNewCliente() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClienteFormScreen()),
    );
    // Recarga los clientes después de volver
    final clientes = await _clienteRepo.getClientes();
    setState(() {
      _clientes = clientes;
      // Opcional: seleccionar el cliente recién creado
      if (_clientes.isNotEmpty) {
        _selectedCliente = _clientes.last;
      }
    });
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // --- ¡LÓGICA DE GUARDADO ACTUALIZADA! ---
  Future<void> _saveCita() async {
    if (!_formKey.currentState!.validate()) return;

    // Validación de campos comunes
    if (_selectedCliente == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa el cliente, fecha y hora.')),
      );
      return;
    }

    // Variables para la cita
    int? idPaquete;
    String? customDesc;
    double? customPrecio;

    if (_esServicioPersonalizado) {
      // --- Guardar como Servicio Personalizado ---
      if (_customDescController.text.isEmpty || _customPrecioController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ingresa descripción y precio personalizados.')),
        );
        return;
      }
      customDesc = _customDescController.text;
      customPrecio = double.tryParse(_customPrecioController.text);
      if (customPrecio == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ingresa un precio válido.')),
        );
        return;
      }
    } else {
      // --- Guardar como Paquete ---
      if (_selectedPaquete == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, selecciona un paquete.')),
        );
        return;
      }
      idPaquete = _selectedPaquete!.id;
    }

    // Combinar fecha y hora
    final fullDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final cita = Cita(
      id: _isEditing ? widget.cita!.id : null,
      idCliente: _selectedCliente!.id!,
      fechaHora: fullDateTime.toIso8601String(),
      estado: _isEditing ? widget.cita!.estado : 'programada',
      // Campos condicionales
      idPaquete: idPaquete,
      customDescripcion: customDesc,
      customPrecio: customPrecio,
    );

    try {
      if (_isEditing) {
        await _citaRepo.updateCita(cita);
      } else {
        await _citaRepo.insertCita(cita);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Cita guardada con éxito!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la cita: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Cita' : 'Nueva Cita'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- SELECTOR DE CLIENTE (CON BOTÓN '+') ---
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Cliente>(
                      value: _selectedCliente,
                      hint: Text('Selecciona un Cliente'),
                      items: _clientes.map((cliente) {
                        return DropdownMenuItem(
                          value: cliente,
                          child: Text(cliente.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCliente = value;
                        });
                      },
                      validator: (value) => value == null ? 'Campo requerido' : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
                    onPressed: _addNewCliente,
                    tooltip: 'Añadir Cliente Nuevo',
                  ),
                ],
              ),
              SizedBox(height: 20),

              // --- ¡NUEVO SWITCH! ---
              SwitchListTile(
                title: Text('Servicio Personalizado'),
                value: _esServicioPersonalizado,
                onChanged: (bool value) {
                  setState(() {
                    _esServicioPersonalizado = value;
                  });
                },
              ),

              // --- UI CONDICIONAL ---
              if (_esServicioPersonalizado)
              // --- CAMPOS PERSONALIZADOS ---
                Column(
                  children: [
                    TextFormField(
                      controller: _customDescController,
                      decoration: InputDecoration(labelText: 'Descripción del Servicio'),
                      validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _customPrecioController,
                      decoration: InputDecoration(labelText: 'Precio', prefixIcon: Icon(Icons.attach_money)),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                    ),
                  ],
                )
              else
              // --- DROPDOWN DE PAQUETE (como antes) ---
                DropdownButtonFormField<Paquete>(
                  value: _selectedPaquete,
                  hint: Text('Selecciona un Servicio'),
                  items: _paquetes.map((paquete) {
                    return DropdownMenuItem(
                      value: paquete,
                      child: Text('${paquete.nombre} (\$${paquete.precio.toStringAsFixed(2)})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaquete = value;
                    });
                  },
                  validator: (value) => value == null ? 'Campo requerido' : null,
                ),

              SizedBox(height: 30),

              // --- SELECTOR DE FECHA ---
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'Ninguna fecha seleccionada'
                          : 'Fecha: ${DateFormat.yMMMMd('es_MX').format(_selectedDate!)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text('Cambiar'),
                  ),
                ],
              ),

              // --- SELECTOR DE HORA ---
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedTime == null
                          ? 'Ninguna hora seleccionada'
                          : 'Hora: ${_selectedTime!.format(context)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickTime,
                    child: Text('Cambiar'),
                  ),
                ],
              ),
              SizedBox(height: 40),

              // --- BOTÓN DE GUARDAR ---
              ElevatedButton(
                onPressed: _saveCita,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Guardar Cita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}