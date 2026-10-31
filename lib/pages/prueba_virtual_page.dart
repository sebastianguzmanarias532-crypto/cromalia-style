

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'registro_cliente_page.dart';
import 'autorizacion_prueba_page.dart';
import 'package:image_picker/image_picker.dart';
import 'captura_fotos_prueba_page.dart';

class PruebaVirtualPage extends StatefulWidget {
  const PruebaVirtualPage({super.key});

  @override
  State<PruebaVirtualPage> createState() => _PruebaVirtualPageState();
}

class _PruebaVirtualPageState extends State<PruebaVirtualPage> {
  static const Color negro = Color(0xFF121212);
  static const Color tarjeta = Color(0xFF1C1C1C);
  static const Color dorado = Color(0xFFD4AF37);
  static const Color texto = Color(0xFFF5F5F5);
  static const Color secundario = Color(0xFFB8B8B8);

  final TextEditingController _busquedaController =
      TextEditingController();
  final FocusNode _busquedaFocusNode = FocusNode();

  late Future<List<Map<String, dynamic>>> _clientesFuture;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  void _cargarClientes() {
    _clientesFuture = DatabaseHelper.instance.obtenerClientes();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _busquedaFocusNode.dispose();
    super.dispose();
  }

  Future<void> _actualizarClientes() async {
    setState(_cargarClientes);
    await _clientesFuture;
  }

  Future<void> _registrarCliente() async {
    final resultado = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => const RegistroClientePage(),
      ),
    );

    if (!mounted) return;

    // Si se guardó el cliente, regresar a la pantalla de inicio.
    if (resultado != null) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  InputDecoration _decoracionBusqueda() {
    return InputDecoration(
      hintText: 'Buscar por nombre o teléfono...',
      hintStyle: const TextStyle(color: secundario),
      prefixIcon: const Icon(Icons.search, color: dorado),
      suffixIcon: _busqueda.isEmpty
          ? null
          : IconButton(
              tooltip: 'Limpiar búsqueda',
              onPressed: () {
                _busquedaController.clear();
                setState(() => _busqueda = '');
              },
              icon: const Icon(Icons.close, color: secundario),
            ),
      filled: true,
      fillColor: tarjeta,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF383838)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF383838)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: dorado, width: 1.5),
      ),
    );
  }

  Widget _tarjetaCliente(Map<String, dynamic> cliente) {
    final nombre = cliente['nombre']?.toString() ?? 'Sin nombre';
    final telefono = cliente['telefono']?.toString() ?? '';

    return Card(
      color: tarjeta,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF383838)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF3A321B),
          child: Icon(Icons.person_outline, color: dorado),
        ),
        title: Text(
          nombre,
          style: const TextStyle(
            color: texto,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            telefono,
            style: const TextStyle(color: secundario),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: dorado,
        ),
          
        onTap: () async {
          final clienteId = cliente['id'] as int;

          final autorizado = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AutorizacionPruebaPage(
                clienteId: clienteId,
              ),
            ),
          );
 
          if (!mounted || autorizado != true) return;

          final fotos = await Navigator.push<Map<String, XFile>>(
            context,
            MaterialPageRoute(
              builder: (_) => CapturaFotosPruebaPage(
                clienteId: clienteId,
                nombreCliente: nombre,
              ),
            ),
          );

          if (!mounted || fotos == null) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Se confirmaron ${fotos.length} fotografías para $nombre.',
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: negro,
      appBar: AppBar(
        backgroundColor: negro,
        foregroundColor: dorado,
        title: const Text(
          'Prueba virtual',
          style: TextStyle(
            color: dorado,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar clientes',
            onPressed: _actualizarClientes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Column(
                children: [
                  const Icon(
                    Icons.face_retouching_natural,
                    color: dorado,
                    size: 58,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Descubre tu próximo look',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dorado,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona el perfil del cliente para comenzar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secundario),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _busquedaController,
                    focusNode: _busquedaFocusNode,
                    onChanged: (valor) {
                      setState(() => _busqueda = valor.trim());
                    },
                    style: const TextStyle(color: texto),
                    decoration: _decoracionBusqueda(),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'CLIENTES REGISTRADOS',
                  style: TextStyle(
                    color: dorado,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _clientesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: dorado),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No se pudieron cargar los clientes.\n'
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: texto),
                        ),
                      ),
                    );
                  }

                  final todos = snapshot.data ?? [];
                  final consulta = _busqueda.toLowerCase();

                  final clientes = todos.where((cliente) {
                    final nombre =
                        cliente['nombre']?.toString().toLowerCase() ?? '';
                    final telefono =
                        cliente['telefono']?.toString().toLowerCase() ?? '';

                    return nombre.contains(consulta) ||
                        telefono.contains(consulta);
                  }).toList();

                  if (todos.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Todavía no hay clientes registrados.\n'
                          'Usa el botón inferior para registrar uno.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: secundario),
                        ),
                      ),
                    );
                  }

                  if (clientes.isEmpty) {
                    return const Center(
                      child: Text(
                        'No se encontraron clientes.',
                        style: TextStyle(color: secundario),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: dorado,
                    onRefresh: _actualizarClientes,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: clientes.length,
                      itemBuilder: (context, index) {
                        return _tarjetaCliente(clientes[index]);
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _registrarCliente,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('REGISTRAR CLIENTE'),
                  style: FilledButton.styleFrom(
                    backgroundColor: dorado,
                    foregroundColor: negro,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

