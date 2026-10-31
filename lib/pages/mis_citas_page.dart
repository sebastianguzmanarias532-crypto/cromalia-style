
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

const Color negroMisCitas = Color(0xFF111111);
const Color tarjetaMisCitas = Color(0xFF1C1C1C);
const Color doradoMisCitas = Color(0xFFD4AF37);
const Color textoMisCitas = Color(0xFFF5F5F5);
const Color secundarioMisCitas = Color(0xFFB8B8B8);

class MisCitasPage extends StatefulWidget {
  const MisCitasPage({super.key});

  @override
  State<MisCitasPage> createState() => _MisCitasPageState();
}

class _MisCitasPageState extends State<MisCitasPage> {
  late Future<List<Map<String, dynamic>>> _citasFuture;
  bool _mostrarCalendario = false;
  DateTime _mesSeleccionado = DateTime.now();
  DateTime _fechaSeleccionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  void _cargarCitas() {
    _citasFuture = DatabaseHelper.instance.obtenerCitas();
  }

  Future<void> _actualizarLista() async {
    setState(_cargarCitas);
    await _citasFuture;
  }

  String _formatearFecha(String fecha) {
    final partes = fecha.split('-');

    if (partes.length != 3) return fecha;

    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
        return Colors.blueAccent;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.redAccent;
      default:
        return doradoMisCitas;
    }
  }

  Future<void> _cambiarEstado(Map<String, dynamic> cita) async {
    final estados = [
      'Pendiente',
      'Confirmada',
      'Completada',
      'Cancelada',
    ];

    final estadoActual = cita['estado']?.toString() ?? 'Pendiente';

    final nuevoEstado = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          backgroundColor: tarjetaMisCitas,
          title: const Text(
            'Estado de la cita',
            style: TextStyle(color: doradoMisCitas),
          ),
          children: estados.map((estado) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, estado),
              child: Row(
                children: [
                  Icon(
                    estado == estadoActual
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _colorEstado(estado),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    estado,
                    style: const TextStyle(color: textoMisCitas),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );

    if (nuevoEstado == null || nuevoEstado == estadoActual) return;

    try {
      await DatabaseHelper.instance.actualizarEstadoCita(
        cita['id'] as int,
        nuevoEstado,
      );

      if (!mounted) return;

      setState(_cargarCitas);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cita actualizada: $nuevoEstado')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la cita: $e')),
      );
    }
  }

  Future<void> _eliminarCita(Map<String, dynamic> cita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: tarjetaMisCitas,
          title: const Text(
            'Eliminar cita',
            style: TextStyle(color: doradoMisCitas),
          ),
          content: const Text(
            '¿Seguro que deseas eliminar esta cita? Esta acción no se puede deshacer.',
            style: TextStyle(color: textoMisCitas),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await DatabaseHelper.instance.eliminarCita(cita['id'] as int);

      if (!mounted) return;

      setState(_cargarCitas);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita eliminada correctamente')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la cita: $e')),
      );
    }
  }

  void _mostrarOpciones(Map<String, dynamic> cita) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: tarjetaMisCitas,
      builder: (contextHoja) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit_calendar,
                  color: doradoMisCitas,
                ),
                title: const Text(
                  'Cambiar estado',
                  style: TextStyle(color: textoMisCitas),
                ),
                onTap: () {
                  Navigator.pop(contextHoja);
                  _cambiarEstado(cita);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Eliminar cita',
                  style: TextStyle(color: textoMisCitas),
                ),
                onTap: () {
                  Navigator.pop(contextHoja);
                  _eliminarCita(cita);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  
  Widget _construirCalendario(List<Map<String, dynamic>> citas) {
    final primerDia = DateTime(
      _mesSeleccionado.year,
      _mesSeleccionado.month,
      1,
    );

    final diasDelMes = DateTime(
      _mesSeleccionado.year,
      _mesSeleccionado.month + 1,
      0,
    ).day;

    final desplazamiento = primerDia.weekday - 1;

    final citasDelDia = citas.where((cita) {
      return cita['fecha'] ==
          '${_fechaSeleccionada.year.toString().padLeft(4, '0')}-'
          '${_fechaSeleccionada.month.toString().padLeft(2, '0')}-'
          '${_fechaSeleccionada.day.toString().padLeft(2, '0')}';
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _mesSeleccionado = DateTime(
                    _mesSeleccionado.year,
                    _mesSeleccionado.month - 1,
                  );
                });
              },
              icon: const Icon(
                Icons.chevron_left,
                color: doradoMisCitas,
              ),
            ),
            Text(
              '${_nombreMes(_mesSeleccionado.month)} '
              '${_mesSeleccionado.year}',
              style: const TextStyle(
                color: doradoMisCitas,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _mesSeleccionado = DateTime(
                    _mesSeleccionado.year,
                    _mesSeleccionado.month + 1,
                  );
                });
              },
              icon: const Icon(
                Icons.chevron_right,
                color: doradoMisCitas,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final dia in ['L', 'M', 'X', 'J', 'V', 'S', 'D'])
              Center(
                child: Text(
                  dia,
                  style: const TextStyle(
                    color: secundarioMisCitas,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            for (int i = 0; i < desplazamiento; i++)
              const SizedBox.shrink(),
            for (int dia = 1; dia <= diasDelMes; dia++)
              _construirDiaCalendario(dia, citas),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Citas del ${_formatearFecha(
            '${_fechaSeleccionada.year.toString().padLeft(4, '0')}-'
            '${_fechaSeleccionada.month.toString().padLeft(2, '0')}-'
            '${_fechaSeleccionada.day.toString().padLeft(2, '0')}',
          )}',
          style: const TextStyle(
            color: doradoMisCitas,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (citasDelDia.isEmpty)
          const Text(
            'No hay citas para esta fecha.',
            style: TextStyle(color: secundarioMisCitas),
          )
        else
          ...citasDelDia.map(_construirTarjeta),
      ],
    );
  }

  Widget _construirDiaCalendario(
    int dia,
    List<Map<String, dynamic>> citas,
  ) {
    final fecha = DateTime(
      _mesSeleccionado.year,
      _mesSeleccionado.month,
      dia,
    );

    final fechaTexto =
        '${fecha.year.toString().padLeft(4, '0')}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';

    final tieneCitas = citas.any(
      (cita) => cita['fecha'] == fechaTexto,
    );

    final seleccionado =
        fecha.year == _fechaSeleccionada.year &&
        fecha.month == _fechaSeleccionada.month &&
        fecha.day == _fechaSeleccionada.day;

    return InkWell(
      onTap: () {
        setState(() {
          _fechaSeleccionada = fecha;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: seleccionado
              ? doradoMisCitas
              : tarjetaMisCitas,
          borderRadius: BorderRadius.circular(10),
          border: tieneCitas
              ? Border.all(color: doradoMisCitas)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dia',
              style: TextStyle(
                color: seleccionado
                    ? negroMisCitas
                    : textoMisCitas,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (tieneCitas)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: seleccionado
                      ? negroMisCitas
                      : doradoMisCitas,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
  String _nombreMes(int mes) {
    const meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return meses[mes - 1];
  }
  Widget _construirTarjeta(Map<String, dynamic> cita) {
    final estado = cita['estado']?.toString() ?? 'Pendiente';
    final nombre = cita['nombre_cliente']?.toString() ?? 'Cliente';
    final servicio = cita['servicio']?.toString() ?? 'Servicio';
    final fecha = cita['fecha']?.toString() ?? '';
    final hora = cita['hora']?.toString() ?? '';
    final precio = (cita['precio'] as num?)?.toDouble() ?? 0;
    debugPrint('CITA COMPLETA: $cita');
    final telefono = cita['telefono_cliente']?.toString() ?? '';

    return Card(
      color: tarjetaMisCitas,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: doradoMisCitas.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: doradoMisCitas.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: doradoMisCitas,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          color: textoMisCitas,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        servicio,
                        style: const TextStyle(
                          color: doradoMisCitas,
                          fontSize: 14,
                        ),
                      ),
                      if (telefono.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          telefono,
                          style: const TextStyle(
                            color: secundarioMisCitas,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _mostrarOpciones(cita),
                  icon: const Icon(
                    Icons.more_vert,
                    color: textoMisCitas,
                  ),
                  tooltip: 'Opciones de la cita',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: doradoMisCitas,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatearFecha(fecha),
                  style: const TextStyle(color: textoMisCitas),
                ),
                const SizedBox(width: 18),
                const Icon(
                  Icons.access_time,
                  color: doradoMisCitas,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  hora,
                  style: const TextStyle(color: textoMisCitas),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '\$${precio.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'\B(?=(\d{3})+(?!\d))'),
                      (match) => '.',
                    )} COP',
                    style: const TextStyle(
                      color: doradoMisCitas,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _colorEstado(estado).withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _colorEstado(estado).withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    estado,
                    style: TextStyle(
                      color: _colorEstado(estado),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if ((cita['observaciones']?.toString() ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Observaciones: ${cita['observaciones']}',
                style: const TextStyle(
                  color: secundarioMisCitas,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: negroMisCitas,
      appBar: AppBar(
        backgroundColor: negroMisCitas,
        foregroundColor: doradoMisCitas,
        title: const Text(
          'Mis citas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _actualizarLista,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar citas',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: false,
                  label: Text('Lista'),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Calendario'),
                  icon: Icon(Icons.calendar_month),
                ),
              ],
              selected: {_mostrarCalendario},
              onSelectionChanged: (seleccion) {
                setState(() {
                  _mostrarCalendario = seleccion.first;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _citasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: doradoMisCitas,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No se pudieron cargar las citas:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: textoMisCitas,
                        ),
                      ),
                    ),
                  );
                }

                final citas = snapshot.data ?? [];

                if (_mostrarCalendario) {
                  return _construirCalendario(citas);
                }

                if (citas.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.event_busy,
                            size: 72,
                            color: doradoMisCitas,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Todavía no tienes citas registradas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textoMisCitas,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Cuando agendes una cita, aparecerá aquí.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: secundarioMisCitas,
                            ),
                          ),
                          const SizedBox(height: 18),
                          OutlinedButton.icon(
                            onPressed: _actualizarLista,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Actualizar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _actualizarLista,
                  color: doradoMisCitas,
                  backgroundColor: tarjetaMisCitas,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'CITAS REGISTRADAS: ${citas.length}',
                        style: const TextStyle(
                          color: doradoMisCitas,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...citas.map(_construirTarjeta),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}