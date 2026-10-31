
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CapturaFotosPruebaPage extends StatefulWidget {
  final int clienteId;
  final String nombreCliente;

  const CapturaFotosPruebaPage({
    super.key,
    required this.clienteId,
    required this.nombreCliente,
  });

  @override
  State<CapturaFotosPruebaPage> createState() =>
      _CapturaFotosPruebaPageState();
}

class _CapturaFotosPruebaPageState
    extends State<CapturaFotosPruebaPage> {
  static const Color negro = Color(0xFF111111);
  static const Color tarjeta = Color(0xFF1C1C1C);
  static const Color dorado = Color(0xFFD4AF37);
  static const Color texto = Color(0xFFF5F5F5);
  static const Color textoSecundario = Color(0xFFB8B8B8);

  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> _vistas = [
    {
      'clave': 'frontal',
      'titulo': 'Vista frontal',
      'descripcion':
          'Mira directamente a la cámara y mantén el rostro despejado.',
    },
    {
      'clave': 'izquierda',
      'titulo': 'Lateral izquierda',
      'descripcion':
          'Gira la cabeza hacia la izquierda para mostrar el perfil.',
    },
    {
      'clave': 'derecha',
      'titulo': 'Lateral derecha',
      'descripcion':
          'Gira la cabeza hacia la derecha para mostrar el perfil.',
    },
    {
      'clave': 'posterior',
      'titulo': 'Vista posterior',
      'descripcion':
          'Colócate de espaldas para mostrar la parte trasera del cabello.',
    },
  ];

  final Map<String, XFile> _fotos = {};

  bool _tomandoFoto = false;
  int _indiceActual = 0;

  Future<void> _tomarFoto() async {
    if (_tomandoFoto) return;

    setState(() => _tomandoFoto = true);

    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxWidth: 2000,
      );

      if (!mounted) return;

      if (imagen != null) {
        final clave = _vistas[_indiceActual]['clave']!;

        setState(() {
          _fotos[clave] = imagen;

          // Avanza a la siguiente vista que falte.
          final siguiente = _vistas.indexWhere(
            (vista) => !_fotos.containsKey(vista['clave']),
          );

          if (siguiente != -1) {
            _indiceActual = siguiente;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo abrir la cámara. Comprueba sus permisos.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _tomandoFoto = false);
      }
    }
  }

  void _seleccionarVista(int indice) {
    setState(() => _indiceActual = indice);
  }

  void _finalizarCaptura() {
    if (_fotos.length != _vistas.length) return;

    // Devuelve las imágenes a la pantalla anterior.
    // Todavía no se guardan en la base de datos.
    Navigator.pop(context, Map<String, XFile>.from(_fotos));
  }

  @override
  Widget build(BuildContext context) {
    final vista = _vistas[_indiceActual];
    final clave = vista['clave']!;
    final fotoActual = _fotos[clave];
    final completas = _fotos.length == _vistas.length;

    return Scaffold(
      backgroundColor: negro,
      appBar: AppBar(
        backgroundColor: negro,
        foregroundColor: dorado,
        title: const Text(
          'Prueba virtual',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CAPTURA DE FOTOGRAFÍAS',
                      style: TextStyle(
                        color: dorado,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.nombreCliente,
                      style: const TextStyle(
                        color: texto,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Necesitamos cuatro vistas para preparar '
                      'la experiencia de cambio de look.',
                      style: TextStyle(
                        color: textoSecundario,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Progreso de las cuatro fotografías.
                    Row(
                      children: List.generate(_vistas.length, (i) {
                        final completada = _fotos.containsKey(
                          _vistas[i]['clave'],
                        );

                        return Expanded(
                          child: Container(
                            height: 5,
                            margin: EdgeInsets.only(
                              right: i == _vistas.length - 1 ? 0 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: completada
                                  ? dorado
                                  : Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_fotos.length} de 4 fotografías completadas',
                      style: const TextStyle(
                        color: textoSecundario,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Vista seleccionada.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: tarjeta,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: dorado.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vista['titulo']!,
                            style: const TextStyle(
                              color: dorado,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            vista['descripcion']!,
                            style: const TextStyle(
                              color: textoSecundario,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Previsualización de la foto seleccionada.
                          Container(
                            width: double.infinity,
                            height: 300,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: negro,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: fotoActual != null
                                ? Image.file(
                                    File(fotoActual.path),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) =>
                                        const Center(
                                      child: Text(
                                        'No se pudo mostrar la foto.',
                                        style: TextStyle(color: texto),
                                      ),
                                    ),
                                  )
                                : const Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        color: dorado,
                                        size: 64,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Fotografía pendiente',
                                        style: TextStyle(
                                          color: textoSecundario,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _tomandoFoto ? null : _tomarFoto,
                              icon: Icon(
                                fotoActual == null
                                    ? Icons.camera_alt
                                    : Icons.refresh,
                              ),
                              label: Text(
                                _tomandoFoto
                                    ? 'Abriendo cámara...'
                                    : fotoActual == null
                                        ? 'Tomar fotografía'
                                        : 'Repetir fotografía',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: dorado,
                                foregroundColor: negro,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    const Text(
                      'VISTAS',
                      style: TextStyle(
                        color: texto,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Permite revisar cualquiera de las cuatro vistas.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_vistas.length, (i) {
                        final item = _vistas[i];
                        final seleccionada = i == _indiceActual;
                        final completada = _fotos.containsKey(
                          item['clave'],
                        );

                        return OutlinedButton(
                          onPressed: () => _seleccionarVista(i),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: seleccionada
                                ? dorado.withValues(alpha: 0.12)
                                : tarjeta,
                            foregroundColor:
                                completada ? dorado : texto,
                            side: BorderSide(
                              color: seleccionada || completada
                                  ? dorado
                                  : Colors.white24,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                completada
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                size: 17,
                              ),
                              const SizedBox(width: 6),
                              Text(item['titulo']!),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Las fotografías se mantienen en archivos '
                      'locales temporales durante este paso. '
                      'Todavía no se envían a un servicio de IA.',
                      style: TextStyle(
                        color: textoSecundario,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botón inferior.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: tarjeta,
                border: Border(
                  top: BorderSide(color: Colors.white12),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: completas ? _finalizarCaptura : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dorado,
                    foregroundColor: negro,
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: textoSecundario,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    completas
                        ? 'Confirmar fotografías'
                        : 'Completa las 4 fotografías',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
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
