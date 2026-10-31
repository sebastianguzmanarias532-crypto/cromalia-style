
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

const Color negroRegistro = Color(0xFF111111);
const Color tarjetaRegistro = Color(0xFF1C1C1C);
const Color doradoRegistro = Color(0xFFD4AF37);
const Color textoRegistro = Color(0xFFF5F5F5);
const Color textoSecundarioRegistro = Color(0xFFB8B8B8);

class RegistroClientePage extends StatefulWidget {
  const RegistroClientePage({super.key});

  @override
  State<RegistroClientePage> createState() =>
      _RegistroClientePageState();
}

class _RegistroClientePageState extends State<RegistroClientePage> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();
  final _observacionesController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  

Future<void> _guardarCliente() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final cliente = <String, String>{
    'nombre': _nombreController.text.trim(),
    'telefono': _telefonoController.text.trim(),
    'correo': _correoController.text.trim(),
    'observaciones': _observacionesController.text.trim(),
  };

  try {
    await DatabaseHelper.instance.insertarCliente(cliente);

    if (!mounted) return;

    Navigator.pop(context, cliente);
  } catch (error, stackTrace) {
    debugPrint('ERROR AL GUARDAR CLIENTE: $error');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al guardar: $error'),
        duration: const Duration(seconds: 8),
      ),
    );
  }
}

  InputDecoration _decoracion(String etiqueta, IconData icono) {
    return InputDecoration(
      labelText: etiqueta,
      labelStyle: const TextStyle(color: textoSecundarioRegistro),
      prefixIcon: Icon(icono, color: doradoRegistro),
      filled: true,
      fillColor: tarjetaRegistro,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF454545)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF454545)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: doradoRegistro, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: negroRegistro,
      appBar: AppBar(
        backgroundColor: negroRegistro,
        foregroundColor: textoRegistro,
        title: const Text('Registrar cliente'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.person_add_alt_1,
                    color: doradoRegistro,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'NUEVO CLIENTE',
                    style: TextStyle(
                      color: doradoRegistro,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Completa la información del cliente.',
                    style: TextStyle(color: textoSecundarioRegistro),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'INFORMACIÓN PERSONAL',
                  style: TextStyle(
                    color: doradoRegistro,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  style: const TextStyle(color: textoRegistro),
                  textCapitalization: TextCapitalization.words,
                  decoration: _decoracion(
                    'Nombre completo *',
                    Icons.person_outline,
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Ingresa el nombre del cliente';
                    }
                    if (valor.trim().length < 3) {
                      return 'Escribe un nombre válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonoController,
                  style: const TextStyle(color: textoRegistro),
                  keyboardType: TextInputType.phone,
                  decoration: _decoracion(
                    'Número de teléfono *',
                    Icons.phone_outlined,
                  ),
                  validator: (valor) {
                    final telefono = valor?.trim() ?? '';
                    if (telefono.isEmpty) {
                      return 'Ingresa el teléfono del cliente';
                    }
                    if (!RegExp(r'^[0-9+() -]{7,20}$')
                        .hasMatch(telefono)) {
                      return 'Revisa el número de teléfono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _correoController,
                  style: const TextStyle(color: textoRegistro),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _decoracion(
                    'Correo electrónico (opcional)',
                    Icons.email_outlined,
                  ),
                  validator: (valor) {
                    final correo = valor?.trim() ?? '';
                    if (correo.isNotEmpty &&
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(correo)) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observacionesController,
                  style: const TextStyle(color: textoRegistro),
                  maxLines: 4,
                  maxLength: 500,
                  decoration: _decoracion(
                    'Observaciones (opcional)',
                    Icons.notes_outlined,
                  ).copyWith(
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 58),
                      child: Icon(
                        Icons.notes_outlined,
                        color: doradoRegistro,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '* Campos obligatorios',
                  style: TextStyle(
                    color: textoSecundarioRegistro,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _guardarCliente,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('GUARDAR CLIENTE'),
                    style: FilledButton.styleFrom(
                      backgroundColor: doradoRegistro,
                      foregroundColor: negroRegistro,
                      padding: const EdgeInsets.symmetric(vertical: 17),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
