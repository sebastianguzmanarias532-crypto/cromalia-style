
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

const Color negroClientes = Color(0xFF111111);
const Color tarjetaClientes = Color(0xFF1C1C1C);
const Color doradoClientes = Color(0xFFD4AF37);
const Color textoClientes = Color(0xFFF5F5F5);
const Color secundarioClientes = Color(0xFFB8B8B8);

class MisClientesPage extends StatefulWidget {
  const MisClientesPage({super.key});

  @override
  State<MisClientesPage> createState() => _MisClientesPageState();
}

class _MisClientesPageState extends State<MisClientesPage> {
  late Future<List<Map<String, dynamic>>> _clientesFuture;

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  void _cargarClientes() {
    _clientesFuture = DatabaseHelper.instance.obtenerClientes();
  }

  Future<void> _actualizarClientes() async {
    setState(_cargarClientes);
    await _clientesFuture;
  }

  void _mostrarDetalle(Map<String, dynamic> cliente) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tarjetaClientes,
        title: Text(
          cliente['nombre']?.toString() ?? 'Cliente',
          style: const TextStyle(
            color: doradoClientes,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detalle('Teléfono', cliente['telefono']),
              _detalle('Correo', cliente['correo']),
              _detalle('Observaciones', cliente['observaciones']),
              _detalle('Fecha de registro', cliente['fecha_registro']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CERRAR',
              style: TextStyle(color: doradoClientes),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detalle(String titulo, dynamic valor) {
    final texto = valor?.toString().trim() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: doradoClientes,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            texto.isEmpty ? 'No registrado' : texto,
            style: const TextStyle(color: textoClientes),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(Map<String, dynamic> cliente) async {
    final id = cliente['id'] as int;
    final nombre = cliente['nombre']?.toString() ?? 'este cliente';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: tarjetaClientes,
        title: const Text(
          'Eliminar cliente',
          style: TextStyle(color: doradoClientes),
        ),
        content: Text(
          '¿Deseas eliminar el registro de $nombre?',
          style: const TextStyle(color: textoClientes),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'CANCELAR',
              style: TextStyle(color: secundarioClientes),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: doradoClientes),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await DatabaseHelper.instance.eliminarCliente(id);
      if (!mounted) return;

      setState(_cargarClientes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente eliminado.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el cliente: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: negroClientes,
      appBar: AppBar(
        backgroundColor: negroClientes,
        foregroundColor: textoClientes,
        title: const Text('Mis clientes'),
        actions: [
          IconButton(
            onPressed: _actualizarClientes,
            tooltip: 'Actualizar lista',
            icon: const Icon(Icons.refresh, color: doradoClientes),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _clientesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: doradoClientes),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar los clientes.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: textoClientes),
                ),
              ),
            );
          }

          final clientes = snapshot.data ?? [];

          if (clientes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: doradoClientes,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aún no tienes clientes registrados',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textoClientes,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Los clientes que guardes aparecerán aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secundarioClientes),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: doradoClientes,
            onRefresh: _actualizarClientes,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: clientes.length,
              itemBuilder: (context, index) {
                final cliente = clientes[index];

                return Card(
                  color: tarjetaClientes,
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
                      child: Icon(
                        Icons.person_outline,
                        color: doradoClientes,
                      ),
                    ),
                    title: Text(
                      cliente['nombre']?.toString() ?? 'Sin nombre',
                      style: const TextStyle(
                        color: textoClientes,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        cliente['telefono']?.toString() ?? '',
                        style: const TextStyle(color: secundarioClientes),
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: doradoClientes,
                      ),
                      color: tarjetaClientes,
                      onSelected: (opcion) {
                        if (opcion == 'detalle') {
                          _mostrarDetalle(cliente);
                        } else if (opcion == 'eliminar') {
                          _confirmarEliminar(cliente);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'detalle',
                          child: Text(
                            'Ver detalles',
                            style: TextStyle(color: textoClientes),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Text(
                            'Eliminar cliente',
                            style: TextStyle(color: textoClientes),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _mostrarDetalle(cliente),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
