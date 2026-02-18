import 'package:flutter/material.dart';
import 'package:proyecto_av/domain/repositories/venta_repository.dart';
import 'package:proyecto_av/domain/repositories/cliente_repository.dart';
import 'package:proyecto_av/domain/repositories/paquete_repository.dart';
import 'package:proyecto_av/data/models/venta_model.dart';
import 'package:proyecto_av/data/models/cliente_model.dart';
import 'package:proyecto_av/data/models/paquete_model.dart';
import 'package:proyecto_av/screens/cliente_form_screen.dart';

class VentaRapidaScreen extends StatefulWidget {
  const VentaRapidaScreen({Key? key}) : super(key: key);

  @override
  _VentaRapidaScreenState createState() => _VentaRapidaScreenState();
}

class _VentaRapidaScreenState extends State<VentaRapidaScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _ventaRepo = VentaRepository();
  final _clienteRepo = ClienteRepository();
  final _paqueteRepo = PaqueteRepository();

  List<Cliente> _clientes = [];
  List<Paquete> _paquetes = [];

  Cliente? _selectedCliente;
  Paquete? _selectedPaquete;

  bool _esServicioPersonalizado = false;
  final _customDescController = TextEditingController();
  final _customPrecioController = TextEditingController();

  bool _isLoading = true;

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _loadData();

    _animController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOutCubic);

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final int? selectedClienteId = _selectedCliente?.id;
    final int? selectedPaqueteId = _selectedPaquete?.id;

    final clientes = await _clienteRepo.getClientes();
    final paquetes = await _paqueteRepo.getPaquetes();

    setState(() {
      _clientes = clientes;
      _paquetes = paquetes;

      if (selectedClienteId != null) {
        try {
          _selectedCliente =
              _clientes.firstWhere((c) => c.id == selectedClienteId);
        } catch (e) {
          _selectedCliente = null;
        }
      }

      if (selectedPaqueteId != null) {
        try {
          _selectedPaquete =
              _paquetes.firstWhere((p) => p.id == selectedPaqueteId);
        } catch (e) {
          _selectedPaquete = null;
        }
      }

      _isLoading = false;
    });
  }

  Future<void> _addNewCliente() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => ClienteFormScreen()));
    _loadData();
  }

  Future<void> _cobrar() async {
    if (!_formKey.currentState!.validate()) return;

    double precioFinal = 0.0;

    if (_esServicioPersonalizado) {
      precioFinal = double.tryParse(_customPrecioController.text) ?? 0.0;
    } else {
      if (_selectedPaquete == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Selecciona un paquete')));
        return;
      }
      precioFinal = _selectedPaquete!.precio;
    }

    final venta = Venta(
      idCita: null,
      montoTotal: precioFinal,
      fechaVenta: DateTime.now().toIso8601String(),
    );

    try {
      await _ventaRepo.registrarVenta(venta);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '¡Venta registrada!  \$${precioFinal.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // --- WIDGET CARD DECORADA ---
  Widget _buildCard({required Widget child}) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Venta Rápida / Sin Cita"),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // CLIENTE --------------------
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Cliente",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<Cliente>(
                              value: _selectedCliente,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                              ),
                              hint: Text("Cliente (Opcional)"),
                              items: _clientes
                                  .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c.nombre)))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedCliente = val),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle),
                            child: IconButton(
                              onPressed: _addNewCliente,
                              icon: Icon(Icons.add,
                                  color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                // TIPO SERVICIO --------------------
                _buildCard(
                  child: SwitchListTile(
                    title: Text(
                      "Servicio Personalizado",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: _esServicioPersonalizado,
                    onChanged: (v) =>
                        setState(() => _esServicioPersonalizado = v),
                    activeColor: Colors.black,
                  ),
                ),

                // CAMPOS --------------------
                if (_esServicioPersonalizado)
                  _buildCard(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _customDescController,
                          decoration: InputDecoration(
                            labelText: "Descripción",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(10)),
                          ),
                          validator: (v) =>
                          v!.isEmpty ? "Requerido" : null,
                        ),
                        SizedBox(height: 14),
                        TextFormField(
                          controller: _customPrecioController,
                          decoration: InputDecoration(
                            labelText: "Precio",
                            prefixIcon: Icon(Icons.attach_money),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(10)),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                          v!.isEmpty ? "Requerido" : null,
                        ),
                      ],
                    ),
                  )
                else
                  _buildCard(
                    child: DropdownButtonFormField<Paquete>(
                      value: _selectedPaquete,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      hint: Text("Selecciona Paquete"),
                      items: _paquetes
                          .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                              "${p.nombre}   (\$${p.precio})")))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedPaquete = v),
                      validator: (v) => !_esServicioPersonalizado &&
                          v == null
                          ? "Requerido"
                          : null,
                    ),
                  ),

                SizedBox(height: 30),

                // BOTÓN COBRAR --------------------
                GestureDetector(
                  onTap: _cobrar,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black,
                          Colors.grey.shade800,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "COBRAR AHORA",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
