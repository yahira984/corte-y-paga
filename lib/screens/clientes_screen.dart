import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:proyecto_av/domain/repositories/cliente_repository.dart';
import 'package:proyecto_av/data/models/cliente_model.dart';
import 'package:proyecto_av/screens/cliente_form_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class ClientesScreen extends StatefulWidget {
  const ClientesScreen({Key? key}) : super(key: key);

  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen>
    with SingleTickerProviderStateMixin {
  final _repo = ClienteRepository();
  List<Cliente> _listaCompleta = [];
  List<Cliente> _listaFiltrada = [];
  bool _isLoading = true;

  final _searchController = TextEditingController();

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _loadClientes();

    _searchController.addListener(_onSearchChanged);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // WHATSAPP LAUNCHER
  // ------------------------------------------------------------
  void _abrirWhatsApp(String numero) async {
    final uri = Uri.parse("https://wa.me/$numero");

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo abrir WhatsApp")),
      );
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _listaFiltrada = _listaCompleta.where((cliente) {
        final nombre = cliente.nombre.toLowerCase();
        final tel = cliente.telefono?.toLowerCase() ?? '';
        return nombre.contains(query) || tel.contains(query);
      }).toList();
    });
  }

  Future<void> _loadClientes() async {
    setState(() => _isLoading = true);

    final clientes = await _repo.getClientes();

    setState(() {
      _listaCompleta = clientes;
      _listaFiltrada = clientes;
      _isLoading = false;
    });

    _animController.forward(from: 0);
  }

  void _navigateAndRefresh({Cliente? cliente}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClienteFormScreen(cliente: cliente),
      ),
    ).then((_) => _loadClientes());
  }

  Future<void> _deleteCliente(Cliente cliente) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Cliente"),
        content: Text(
          '¿Deseas borrar a "${cliente.nombre}"?\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Borrar", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ) ??
        false;

    if (confirm) {
      await _repo.deleteCliente(cliente.id!);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Cliente eliminado")));
      _loadClientes();
    }
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(" ");
    if (parts.isEmpty) return "";
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  // ------------------------------------------------------------
  // UI PRINCIPAL
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        title: Text(
          'Clientes (${_listaCompleta.length})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),

      body: Column(
        children: [
          // ------------------ BUSCADOR --------------------
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon:
                    Icon(Icons.clear, color: Colors.grey[700], size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged();
                      setState(() {});
                    },
                  )
                      : null,
                  hintText: "Buscar cliente por nombre o teléfono...",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // ------------------ LISTA --------------------
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _listaFiltrada.isEmpty
                ? _buildEmptyState()
                : _buildClientList(),
          ),
        ],
      ),

      // ------------------ BOTÓN AGREGAR --------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _navigateAndRefresh(),
      ),
    );
  }

  Widget _buildClientList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _listaFiltrada.length,
      itemBuilder: (context, index) {
        final cliente = _listaFiltrada[index];

        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final anim = CurvedAnimation(
              parent: _animController,
              curve: Interval(
                (index * 0.05).clamp(0.0, 0.9),
                1,
                curve: Curves.easeOutQuint,
              ),
            );

            return Transform.translate(
              offset: Offset(0, 20 * (1 - anim.value)),
              child: Opacity(opacity: anim.value, child: child),
            );
          },
          child: _buildClientCard(cliente),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // TARJETA PREMIUM
  // ------------------------------------------------------------
  Widget _buildClientCard(Cliente cliente) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _navigateAndRefresh(cliente: cliente),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.black,
          child: Text(
            _getInitials(cliente.nombre),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),

        title: Text(
          cliente.nombre,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        subtitle: cliente.telefono != null && cliente.telefono!.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Row(
            children: [
              Icon(Icons.phone,
                  size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                cliente.telefono!,
                style:
                TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ],
          ),
        )
            : null,

        // ------------------ BOTONES: WHATSAPP + BORRAR --------------------
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cliente.telefono != null && cliente.telefono!.isNotEmpty)
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 26),
                onPressed: () => _abrirWhatsApp(cliente.telefono!),
              ),

            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              onPressed: () => _deleteCliente(cliente),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined,
              color: Colors.grey.shade400, size: 70),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Aún no tienes clientes registrados.'
                : 'No se encontraron clientes.',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          )
        ],
      ),
    );
  }
}
