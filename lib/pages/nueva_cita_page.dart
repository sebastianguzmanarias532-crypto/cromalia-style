
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

const Color negroCitas = Color(0xFF121212);
const Color tarjetaCitas = Color(0xFF1E1E1E);
const Color doradoCitas = Color(0xFFD4AF37);
const Color textoCitas = Color(0xFFF5F5F5);
const Color secundarioCitas = Color(0xFFBDBDBD);

class NuevaCitaPage extends StatefulWidget {
  const NuevaCitaPage({super.key});

  @override
  State<NuevaCitaPage> createState() => _NuevaCitaPageState();
}

class _NuevaCitaPageState extends State<NuevaCitaPage> {
  final _formKey = GlobalKey<FormState>();
  final _precioController = TextEditingController();
  final _observacionesController = TextEditingController();

  List<Map<String, dynamic>> _clientes = [];
  int? _clienteSeleccionado;
  String? _servicioSeleccionado;
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  bool _cargandoClientes = true;
  bool _guardando = false;

  final List<String> _servicios = [
    'Corte de cabello',
    'Tinte',
    'Mechas',
    'Peinado',
    'Tratamiento capilar',
    'Alisado',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  @override
  void dispose() {
    _precioController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _cargarClientes() async {
    try {
      final clientes =
          await DatabaseHelper.instance.obtenerClientes();

      if (!mounted) return;

      setState(() {
        _clientes = clientes;
        _cargandoClientes = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargandoClientes = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar clientes: $e')),
      );
    }
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ??
          DateTime(hoy.year, hoy.month, hoy.day),
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
      lastDate: DateTime(hoy.year + 3),
      helpText: 'Selecciona la fecha de la cita',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (fecha != null && mounted) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
      helpText: 'Selecciona la hora de la cita',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (hora != null && mounted) {
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  String _formatearHora(TimeOfDay hora) {
    return hora.format(context);
  }

  Future<void> _guardarCita() async {
    if (!_formKey.currentState!.validate()) return;

    if (_clienteSeleccionado == null ||
        _servicioSeleccionado == null ||
        _fechaSeleccionada == null ||
        _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos obligatorios.'),
        ),
      );
      return;
    }

    final fecha = _fechaSeleccionada!;
    final hora = _horaSeleccionada!;

    final fechaTexto =
        '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
        

    final horaTexto =
        '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';

    final horarioOcupado =
        await DatabaseHelper.instance.existeCitaEnHorario(
      fecha: fechaTexto,
      hora: horaTexto,
    );

    if (horarioOcupado) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este horario ya está ocupado. Elige otra hora.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await DatabaseHelper.instance.insertarCita({
        'cliente_id': _clienteSeleccionado!,
        'servicio': _servicioSeleccionado!,
        'fecha': fechaTexto,
        'hora': horaTexto,
        'precio': double.parse(
          _precioController.text
              .trim()
              .replaceAll('.', '')
              .replaceAll(',', '.'),
        ),
        'estado': 'Pendiente',
        'observaciones': _observacionesController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cita guardada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo guardar la cita: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  InputDecoration _decoracion(String etiqueta, IconData icono) {
    return InputDecoration(
      labelText: etiqueta,
      prefixIcon: Icon(icono, color: doradoCitas),
      labelStyle: const TextStyle(color: secundarioCitas),
      filled: true,
      fillColor: tarjetaCitas,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: doradoCitas, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: negroCitas,
      appBar: AppBar(
        backgroundColor: negroCitas,
        foregroundColor: doradoCitas,
        title: const Text(
          'Nueva cita',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: doradoCitas),
      ),
      body: _cargandoClientes
          ? const Center(
              child: CircularProgressIndicator(color: doradoCitas),
            )
          : _clientes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_add_alt_1,
                          size: 60,
                          color: doradoCitas,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Primero debes registrar un cliente.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textoCitas,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Volver'),
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Text(
                          'PROGRAMAR SERVICIO',
                          style: TextStyle(
                            color: doradoCitas,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Completa los datos para agendar una cita.',
                          style: TextStyle(color: secundarioCitas),
                        ),
                        const SizedBox(height: 24),

                        DropdownButtonFormField<int>(
                          initialValue: _clienteSeleccionado,
                          isExpanded: true,
                          dropdownColor: tarjetaCitas,
                          style: const TextStyle(color: textoCitas),
                          decoration: _decoracion(
                            'Cliente *',
                            Icons.person_outline,
                          ),
                          items: _clientes.map((cliente) {
                            return DropdownMenuItem<int>(
                              value: cliente['id'] as int,
                              child: Text(
                                cliente['nombre'].toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (valor) {
                            setState(() {
                              _clienteSeleccionado = valor;
                            });
                          },
                          validator: (valor) =>
                              valor == null ? 'Selecciona un cliente' : null,
                        ),

                        const SizedBox(height: 18),

                        DropdownButtonFormField<String>(
                          initialValue: _servicioSeleccionado,
                          isExpanded: true,
                          dropdownColor: tarjetaCitas,
                          style: const TextStyle(color: textoCitas),
                          decoration: _decoracion(
                            'Servicio *',
                            Icons.content_cut,
                          ),
                          items: _servicios.map((servicio) {
                            return DropdownMenuItem<String>(
                              value: servicio,
                              child: Text(servicio),
                            );
                          }).toList(),
                          onChanged: (valor) {
                            setState(() {
                              _servicioSeleccionado = valor;
                            });
                          },
                          validator: (valor) =>
                              valor == null ? 'Selecciona un servicio' : null,
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _seleccionarFecha,
                                icon: const Icon(
                                  Icons.calendar_month,
                                  color: doradoCitas,
                                ),
                                label: Text(
                                  _fechaSeleccionada == null
                                      ? 'Elegir fecha *'
                                      : _formatearFecha(_fechaSeleccionada!),
                                  style: const TextStyle(color: textoCitas),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(
                                    color: doradoCitas,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _seleccionarHora,
                                icon: const Icon(
                                  Icons.access_time,
                                  color: doradoCitas,
                                ),
                                label: Text(
                                  _horaSeleccionada == null
                                      ? 'Elegir hora *'
                                      : _formatearHora(_horaSeleccionada!),
                                  style: const TextStyle(color: textoCitas),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: const BorderSide(
                                    color: doradoCitas,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        TextFormField(
                          controller: _precioController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(color: textoCitas),
                          decoration: _decoracion(
                            'Precio en pesos *',
                            Icons.payments_outlined,
                          ),
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Ingresa el precio';
                            }

                            final precio = double.tryParse(
                              valor.trim().replaceAll(',', '.'),
                            );

                            if (precio == null || precio < 0) {
                              return 'Ingresa un precio válido';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        TextFormField(
                          controller: _observacionesController,
                          maxLines: 3,
                          style: const TextStyle(color: textoCitas),
                          decoration: _decoracion(
                            'Observaciones (opcional)',
                            Icons.notes,
                          ),
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _guardando ? null : _guardarCita,
                            icon: _guardando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: negroCitas,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              _guardando ? 'GUARDANDO...' : 'GUARDAR CITA',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: doradoCitas,
                              foregroundColor: negroCitas,
                              disabledBackgroundColor: Colors.grey,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
    );
  }
}
