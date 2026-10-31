
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AutorizacionPruebaPage extends StatefulWidget {
  final int clienteId;

  const AutorizacionPruebaPage({
    super.key,
    required this.clienteId,
  });

  @override
  State<AutorizacionPruebaPage> createState() =>
      _AutorizacionPruebaPageState();
}

class _AutorizacionPruebaPageState
    extends State<AutorizacionPruebaPage> {
  static const Color negro = Color(0xFF121212);
  static const Color tarjeta = Color(0xFF1C1C1C);
  static const Color dorado = Color(0xFFD4AF37);
  static const Color texto = Color(0xFFF5F5F5);
  static const Color secundario = Color(0xFFB8B8B8);

  bool _aceptaTratamiento = false;

  
bool _guardando = false;

Future<void> _continuar() async {
  if (!_aceptaTratamiento) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Debes aceptar la autorización para continuar.',
        ),
      ),
    );
    return;
  }

  if (_guardando) return;

  setState(() {
    _guardando = true;
  });

  try {
    await DatabaseHelper.instance.registrarAutorizacionPrueba(
      clienteId: widget.clienteId,
      versionTexto: '1.0',
      finalidad:
          'Generar simulaciones de cortes, peinados y colores '
          'mediante inteligencia artificial.',
      textoAutorizacion:
          'El cliente autorizó el tratamiento de sus fotografías '
          'para generar simulaciones de cortes, peinados y colores '
          'mediante inteligencia artificial. La autorización '
          'no incluye uso publicitario ni publicación de las fotos.',
    );
    
    final autorizaciones =
        await DatabaseHelper.instance.obtenerAutorizacionesPrueba();

    debugPrint('AUTORIZACIONES GUARDADAS: $autorizaciones');    

    if (!mounted) return;

     Navigator.pop(context, true);
     } catch (e) {
      if (!mounted) return;

     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text(
           'No se pudo guardar la autorización: $e',
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: negro,
      appBar: AppBar(
        backgroundColor: negro,
        foregroundColor: dorado,
        title: const Text(
          'Autorización de datos',
          style: TextStyle(
            color: dorado,
            fontWeight: FontWeight.bold,
          ),
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
                    const Center(
                      child: Icon(
                        Icons.shield_outlined,
                        color: dorado,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'PROTEGEMOS TU PRIVACIDAD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: dorado,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Antes de iniciar tu prueba virtual, '
                      'lee la siguiente información.',
                      style: TextStyle(
                        color: texto,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _seccion(
                      '1. Finalidad',
                      'Tus fotografías se utilizarán para generar '
                      'una simulación de cortes, peinados o colores '
                      'mediante inteligencia artificial.',
                    ),
                    _seccion(
                      '2. Uso de las fotografías',
                      'Las imágenes podrán ser procesadas por un '
                      'proveedor de inteligencia artificial. Antes '
                      'de enviar fotografías a dicho proveedor, '
                      'Cromalia Style deberá identificarlo e informar '
                      'las condiciones aplicables al tratamiento.',
                    ),
                    _seccion(
                      '3. Conservación y eliminación',
                      'La política prevista es eliminar las fotografías '
                      'originales y las simulaciones al terminar la '
                      'prueba o cuando selecciones el trabajo deseado. '
                      'La eliminación deberá aplicarse también a las '
                      'copias gestionadas por el proveedor, según sus '
                      'condiciones y las obligaciones legales aplicables.',
                    ),
                    _seccion(
                      '4. Tus derechos',
                      'Puedes solicitar información sobre tus datos, '
                      'conocerlos, actualizarlos, rectificarlos y '
                      'ejercer los demás derechos previstos en la '
                      'normativa colombiana de protección de datos. '
                      'También puedes revocar la autorización o '
                      'solicitar la supresión cuando sea procedente.',
                    ),
                    _seccion(
                      '5. Responsable del tratamiento',
                      'Antes de usar esta función en producción, '
                      'se deben completar aquí el nombre o razón '
                      'social del responsable, sus datos de contacto '
                      'y el canal para consultas o reclamaciones.',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: tarjeta,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF454545),
                        ),
                      ),
                      child: CheckboxListTile(
                        value: _aceptaTratamiento,
                        onChanged: (valor) {
                          setState(() {
                            _aceptaTratamiento = valor ?? false;
                          });
                        },
                        activeColor: dorado,
                        checkColor: negro,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity:
                            ListTileControlAffinity.leading,
                        title: const Text(
                          'He leído esta información y autorizo '
                          'el tratamiento de mis fotografías para '
                          'la finalidad descrita.',
                          style: TextStyle(
                            color: texto,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'La autorización no permite usar tus fotos '
                      'para publicidad ni publicarlas.',
                      style: TextStyle(
                        color: secundario,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _guardando ? null : _continuar,
                  style: FilledButton.styleFrom(
                    backgroundColor: dorado,
                    foregroundColor: negro,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _guardando
                      ? const CircularProgressIndicator(color: negro)
                      : const Text(
                          'ACEPTAR Y CONTINUAR',
                          style: TextStyle(
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

  Widget _seccion(String titulo, String contenido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: dorado,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            contenido,
            style: const TextStyle(
              color: texto,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
