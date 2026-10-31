
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class FichasCapilaresPage extends StatefulWidget {
  const FichasCapilaresPage({super.key});

  @override
  State<FichasCapilaresPage> createState() =>
      _FichasCapilaresPageState();
}

class _FichasCapilaresPageState extends State<FichasCapilaresPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _tratamientosController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _recomendacionesController = TextEditingController();
  final _buscadorController = TextEditingController();

  final Color negro = const Color(0xFF111111);
  final Color tarjeta = const Color(0xFF1C1C1C);
  final Color dorado = const Color(0xFFD4AF37);
  final Color texto = const Color(0xFFF5F5F5);
  final Color secundario = const Color(0xFFB8B8B8);

  late final TabController _tabController;

  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _fichas = [];

  int? _clienteId;
  int? _fichaEditandoId;

  String? _textura;
  String? _grosor;
  String? _estado;
  String? _elasticidad;

  bool _cargando = true;
  bool _guardando = false;

  String _busqueda = '';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _buscadorController.addListener(_actualizarBusqueda);

    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tratamientosController.dispose();
    _observacionesController.dispose();
    _recomendacionesController.dispose();

    _buscadorController.removeListener(_actualizarBusqueda);
    _buscadorController.dispose();

    super.dispose();
  }

  void _actualizarBusqueda() {
    setState(() {
      _busqueda = _buscadorController.text.trim().toLowerCase();
    });
  }

  Future<void> _cargarDatos() async {
    try {
      final clientes =
          await DatabaseHelper.instance.obtenerClientes();

      final fichas =
          await DatabaseHelper.instance.obtenerFichasCapilares();

      if (!mounted) return;

      setState(() {
        _clientes = clientes;
        _fichas = fichas;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _cargando = false);
      _mostrarMensaje('No se pudieron cargar los datos: $e');
    }
  }

  InputDecoration _decoracion(String etiqueta) {
    return InputDecoration(
      labelText: etiqueta,
      labelStyle: TextStyle(color: secundario),
      filled: true,
      fillColor: tarjeta,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dorado),
      ),
    );
  }

  Widget _selector({
    required String etiqueta,
    required String? valor,
    required List<String> opciones,
    required ValueChanged<String?> alCambiar,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      isExpanded: true,
      dropdownColor: tarjeta,
      style: TextStyle(color: texto),
      decoration: _decoracion(etiqueta),
      iconEnabledColor: dorado,
      items: opciones.map((opcion) {
        return DropdownMenuItem<String>(
          value: opcion,
          child: Text(opcion),
        );
      }).toList(),
      onChanged: alCambiar,
      validator: (valor) =>
          valor == null ? 'Selecciona una opción' : null,
    );
  }

  Widget _campoTexto({
    required String etiqueta,
    required TextEditingController controlador,
    int maxLineas = 1,
    bool obligatorio = false,
  }) {
    return TextFormField(
      controller: controlador,
      maxLines: maxLineas,
      style: TextStyle(color: texto),
      decoration: _decoracion(etiqueta),
      validator: obligatorio
          ? (valor) =>
              valor == null || valor.trim().isEmpty
                  ? 'Este campo es obligatorio'
                  : null
          : null,
    );
  }

  Future<void> _guardarFicha() async {
    if (_guardando) return;

    final formularioValido =
        _formKey.currentState?.validate() ?? false;

    if (!formularioValido) return;

    if (_clienteId == null) {
      _mostrarMensaje('Selecciona un cliente.');
      return;
    }

    setState(() => _guardando = true);

    try {
      final clienteExiste =
          await DatabaseHelper.instance.obtenerClientePorId(
        _clienteId!,
      );

      if (clienteExiste == null) {
        throw Exception('El cliente seleccionado ya no existe.');
      }

      final ficha = <String, dynamic>{
        'cliente_id': _clienteId,
        'textura': _textura,
        'grosor': _grosor,
        'estado_cabello': _estado,
        'elasticidad': _elasticidad,
        'tratamientos_anteriores':
            _tratamientosController.text.trim(),
        'observaciones_profesional':
            _observacionesController.text.trim(),
        'recomendaciones':
            _recomendacionesController.text.trim(),
      };

      final estabaEditando = _fichaEditandoId != null;

      if (estabaEditando) {
        await DatabaseHelper.instance.actualizarFichaCapilar(
          _fichaEditandoId!,
          ficha,
        );
      } else {
        await DatabaseHelper.instance.insertarFichaCapilar(ficha);
      }

      if (!mounted) return;

      _limpiarFormulario();
      await _cargarDatos();

      if (!mounted) return;

      _tabController.animateTo(1);

      _mostrarMensaje(
        estabaEditando
            ? 'Ficha capilar actualizada correctamente.'
            : 'Ficha capilar guardada correctamente.',
      );
    } catch (e) {
      if (mounted) {
        _mostrarMensaje('No se pudo guardar la ficha: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();

    setState(() {
      _fichaEditandoId = null;
      _clienteId = null;
      _textura = null;
      _grosor = null;
      _estado = null;
      _elasticidad = null;

      _tratamientosController.clear();
      _observacionesController.clear();
      _recomendacionesController.clear();
    });
  }

  void _editarFicha(Map<String, dynamic> ficha) {
    final idCliente = ficha['cliente_id'] is int
        ? ficha['cliente_id'] as int
        : int.tryParse(ficha['cliente_id']?.toString() ?? '');

    final idFicha = ficha['id'] is int
        ? ficha['id'] as int
        : int.tryParse(ficha['id']?.toString() ?? '');

    if (idFicha == null) {
      _mostrarMensaje('No se pudo identificar la ficha.');
      return;
    }

    setState(() {
      _fichaEditandoId = idFicha;
      _clienteId = idCliente;
      _textura = ficha['textura']?.toString();
      _grosor = ficha['grosor']?.toString();
      _estado = ficha['estado_cabello']?.toString();
      _elasticidad = ficha['elasticidad']?.toString();

      _tratamientosController.text =
          ficha['tratamientos_anteriores']?.toString() ?? '';

      _observacionesController.text =
          ficha['observaciones_profesional']?.toString() ?? '';

      _recomendacionesController.text =
          ficha['recomendaciones']?.toString() ?? '';
    });

    _tabController.animateTo(0);
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: tarjeta,
      ),
    );
  }

  String _fechaLegible(dynamic valor) {
    if (valor == null) return 'Sin fecha';

    final fecha = DateTime.tryParse(valor.toString());

    if (fecha == null) return valor.toString();

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        titulo,
        style: TextStyle(
          color: dorado,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _construirFicha(Map<String, dynamic> ficha) {
    return Card(
      color: tarjeta,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: dorado.withValues(alpha: 0.35),
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
                Expanded(
                  child: Text(
                    ficha['nombre_cliente']?.toString() ??
                        'Cliente sin nombre',
                    style: TextStyle(
                      color: dorado,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Editar ficha',
                  onPressed: () => _editarFicha(ficha),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: dorado,
                  ),
                ),
              ],
            ),
            if ((ficha['telefono_cliente'] ?? '')
                .toString()
                .isNotEmpty)
              Text(
                'Teléfono: ${ficha['telefono_cliente']}',
                style: TextStyle(color: secundario),
              ),
            const SizedBox(height: 6),
            Text(
              'Evaluación: '
              '${_fechaLegible(ficha['fecha_evaluacion'])}',
              style: TextStyle(color: secundario),
            ),
            const Divider(color: Colors.white24),
            Text(
              'Textura: ${ficha['textura']} · '
              'Grosor: ${ficha['grosor']}',
              style: TextStyle(color: texto),
            ),
            const SizedBox(height: 5),
            Text(
              'Estado: ${ficha['estado_cabello']}',
              style: TextStyle(color: texto),
            ),
            const SizedBox(height: 5),
            Text(
              'Elasticidad: ${ficha['elasticidad']}',
              style: TextStyle(color: texto),
            ),
            if ((ficha['tratamientos_anteriores'] ?? '')
                .toString()
                .isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Tratamientos anteriores: '
                '${ficha['tratamientos_anteriores']}',
                style: TextStyle(color: secundario),
              ),
            ],
            if ((ficha['observaciones_profesional'] ?? '')
                .toString()
                .isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Observaciones: '
                '${ficha['observaciones_profesional']}',
                style: TextStyle(color: secundario),
              ),
            ],
            if ((ficha['recomendaciones'] ?? '')
                .toString()
                .isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Recomendaciones: ${ficha['recomendaciones']}',
                style: TextStyle(color: secundario),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Evaluación capilar: conserva el formulario existente.
  Widget _construirEvaluacion() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(
            Icons.spa_outlined,
            color: dorado,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'EVALUACIÓN CAPILAR',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dorado,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registra las características del cabello '
            'y el historial de tratamientos del cliente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secundario),
          ),
          const SizedBox(height: 28),
          _seccion('Datos del cliente'),
          DropdownButtonFormField<int>(
            initialValue: _clienteId,
            isExpanded: true,
            dropdownColor: tarjeta,
            style: TextStyle(color: texto),
            decoration: _decoracion('Seleccionar cliente'),
            iconEnabledColor: dorado,
            items: _clientes.map((cliente) {
              final id = cliente['id'] as int;
              final nombre =
                  cliente['nombre']?.toString() ?? 'Sin nombre';
              final telefono =
                  cliente['telefono']?.toString() ?? '';

              return DropdownMenuItem<int>(
                value: id,
                child: Text('$nombre · $telefono'),
              );
            }).toList(),
            onChanged: _clientes.isEmpty
                ? null
                : (valor) {
                    setState(() => _clienteId = valor);
                  },
            validator: (valor) =>
                valor == null ? 'Selecciona un cliente' : null,
          ),
          if (_clientes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Todavía no hay clientes registrados. '
                'Registra uno antes de crear una ficha.',
                style: TextStyle(color: secundario),
              ),
            ),
          const SizedBox(height: 24),
          _seccion('Características del cabello'),
          _selector(
            etiqueta: 'Textura según la forma',
            valor: _textura,
            opciones: [
              'Liso',
              'Ondulado',
              'Rizado',
              'Crespo',
            ],
            alCambiar: (valor) {
              setState(() => _textura = valor);
            },
          ),
          const SizedBox(height: 16),
          _selector(
            etiqueta: 'Grosor del cabello',
            valor: _grosor,
            opciones: ['Fino', 'Medio', 'Grueso'],
            alCambiar: (valor) {
              setState(() => _grosor = valor);
            },
          ),
          const SizedBox(height: 16),
          _selector(
            etiqueta: 'Estado del cabello',
            valor: _estado,
            opciones: [
              'Saludable',
              'Seco',
              'Dañado',
              'Quebradizo',
              'Graso',
              'Mixto',
              'Otro',
            ],
            alCambiar: (valor) {
              setState(() => _estado = valor);
            },
          ),
          const SizedBox(height: 16),
          _selector(
            etiqueta: 'Elasticidad',
            valor: _elasticidad,
            opciones: [
              'Normal',
              'Baja',
              'Excesiva',
              'Por evaluar',
            ],
            alCambiar: (valor) {
              setState(() => _elasticidad = valor);
            },
          ),
          const SizedBox(height: 24),
          _seccion('Historial y evaluación'),
          _campoTexto(
            etiqueta: 'Tratamientos anteriores',
            controlador: _tratamientosController,
            maxLineas: 3,
          ),
          const SizedBox(height: 16),
          _campoTexto(
            etiqueta: 'Observaciones del profesional',
            controlador: _observacionesController,
            maxLineas: 3,
          ),
          const SizedBox(height: 16),
          _campoTexto(
            etiqueta: 'Recomendaciones',
            controlador: _recomendacionesController,
            maxLineas: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _guardando || _clientes.isEmpty
                ? null
                : _guardarFicha,
            icon: _guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    _fichaEditandoId == null
                        ? Icons.save_outlined
                        : Icons.edit_outlined,
                  ),
            label: Text(
              _guardando
                  ? 'Guardando...'
                  : _fichaEditandoId == null
                      ? 'Guardar ficha capilar'
                      : 'Actualizar ficha capilar',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: dorado,
              foregroundColor: negro,
              disabledBackgroundColor:
                  dorado.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_fichaEditandoId != null) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _guardando
                  ? null
                  : () {
                      _limpiarFormulario();
                      _mostrarMensaje('Edición cancelada.');
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: dorado,
                side: BorderSide(color: dorado),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Cancelar edición'),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // El buscador solo aparece en Perfiles capilares.
  // Está fuera de la lista desplazable para permanecer arriba.
  Widget _construirPerfiles() {
    final fichasFiltradas = _fichas.where((ficha) {
      final nombre =
          (ficha['nombre_cliente'] ?? '').toString().toLowerCase();
      final telefono =
          (ficha['telefono_cliente'] ?? '').toString().toLowerCase();

      return nombre.contains(_busqueda) ||
          telefono.contains(_busqueda);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: TextField(
            controller: _buscadorController,
            style: TextStyle(color: texto),
            decoration:
                _decoracion('Buscar por nombre o teléfono').copyWith(
              prefixIcon: Icon(Icons.search, color: dorado),
              suffixIcon: _busqueda.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda',
                      onPressed: _buscadorController.clear,
                      icon: Icon(Icons.close, color: secundario),
                    ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: dorado,
            onRefresh: _cargarDatos,
            child: fichasFiltradas.isEmpty
                ? ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        _fichas.isEmpty
                            ? Icons.folder_open_outlined
                            : Icons.search_off,
                        color: secundario,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _fichas.isEmpty
                            ? 'Todavía no hay perfiles capilares guardados.'
                            : 'No se encontraron perfiles con esa búsqueda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secundario),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      20,
                    ),
                    itemCount: fichasFiltradas.length,
                    itemBuilder: (context, index) {
                      return _construirFicha(
                        fichasFiltradas[index],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: negro,
      appBar: AppBar(
        backgroundColor: negro,
        foregroundColor: dorado,
        title: const Text('Fichas capilares'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: dorado,
          labelColor: dorado,
          unselectedLabelColor: secundario,
          tabs: const [
            Tab(
              icon: Icon(Icons.spa_outlined),
              text: 'Evaluación capilar',
            ),
            Tab(
              icon: Icon(Icons.people_outline),
              text: 'Perfiles capilares',
            ),
          ],
        ),
      ),
      body: _cargando
          ? Center(
              child: CircularProgressIndicator(color: dorado),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _construirEvaluacion(),
                _construirPerfiles(),
              ],
            ),
    );
  }
}
