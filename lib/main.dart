
import 'package:flutter/material.dart';

import 'pages/registro_cliente_page.dart';
import 'pages/mis_clientes_page.dart' as mis_clientes_page;
import 'pages/nueva_cita_page.dart';
import 'pages/mis_citas_page.dart';
import 'pages/prueba_virtual_page.dart';
import 'pages/fichas_capilares_page.dart';

void main() {
  runApp(const CromaliaStyleApp());
}

const Color negro = Color(0xFF111111);
const Color negroSuave = Color(0xFF1C1C1C);
const Color dorado = Color(0xFFD4AF37);
const Color textoClaro = Color(0xFFF5F5F5);
const Color textoSecundario = Color(0xFFB8B8B8);

class CromaliaStyleApp extends StatelessWidget {
  const CromaliaStyleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cromalia Style',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: negro,
        colorScheme: const ColorScheme.dark(
          primary: dorado,
          surface: negroSuave,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: negro,
          foregroundColor: textoClaro,
        ),
      ),
      home: const InicioPage(),
    );
  }
}

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  void mostrarMensaje(BuildContext context, String mensaje) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: negroSuave,
          icon: const Icon(
            Icons.info_outline,
            color: dorado,
            size: 36,
          ),
          title: const Text(
            'Cromalia Style',
            style: TextStyle(
              color: dorado,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textoClaro,
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'ENTENDIDO',
                style: TextStyle(
                  color: dorado,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.content_cut, color: dorado, size: 27),
            SizedBox(width: 10),
            Text(
              'CROMALIA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: textoClaro,
              ),
            ),
            SizedBox(width: 6),
            Text(
              'STYLE',
              style: TextStyle(
                color: dorado,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => mostrarMensaje(
              context,
              'El perfil estará disponible en una próxima etapa.',
            ),
            icon: const Icon(Icons.account_circle_outlined),
            color: dorado,
            tooltip: 'Mi perfil',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: negroSuave,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: dorado.withValues(alpha: 0.55),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: dorado.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: dorado,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'TU TALENTO, TU ESTILO',
                      style: TextStyle(
                        color: dorado,
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tu creatividad,\nsin límites.',
                      style: TextStyle(
                        color: textoClaro,
                        fontSize: 32,
                        height: 1.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gestiona tus clientes y descubre '
                      'nuevas posibilidades para cada estilo.',
                      style: TextStyle(
                        color: textoSecundario,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final cliente =
                              await Navigator.push<Map<String, String>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegistroClientePage(),
                            ),
                          );

                          if (!context.mounted || cliente == null) {
                            return;
                          }

                          mostrarMensaje(
                            context,
                            'Formulario completado para '
                            '${cliente['nombre']}. '
                            'Todavía falta guardar el cliente '
                            'permanentemente.',
                          );
                        },
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('REGISTRAR CLIENTE'),
                        style: FilledButton.styleFrom(
                          backgroundColor: dorado,
                          foregroundColor: negro,
                          padding: const EdgeInsets.symmetric(
                            vertical: 17,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.7,
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
              const SizedBox(height: 30),
              const Text(
                'TU ESPACIO DE TRABAJO',
                style: TextStyle(
                  color: dorado,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Qué deseas hacer hoy?',
                style: TextStyle(
                  color: textoClaro,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.08,
                children: [
                  _OpcionCard(
                    icono: Icons.people_outline,
                    titulo: 'Mis clientes',
                    descripcion: 'Gestiona tu clientela',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const mis_clientes_page.MisClientesPage(),
                        ),
                      );
                    },
                  ),
                  _OpcionCard(
                    icono: Icons.calendar_month,
                    titulo: 'Agendar cita',
                    descripcion: 'Programa servicios',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NuevaCitaPage(),
                        ),
                      );
                    },
                  ),
                  _OpcionCard(
                    icono: Icons.event_note,
                    titulo: 'Mis citas',
                    descripcion: 'Consulta tus reservas',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MisCitasPage(),
                        ),
                      );
                    },
                  ),
                  _OpcionCard(
                    icono: Icons.palette_outlined,
                    titulo: 'Estilos',
                    descripcion: 'Explora nuevos looks',
                    onTap: () => mostrarMensaje(
                      context,
                      'Próximamente: catálogo de estilos.',
                    ),
                  ),
                  _OpcionCard(
                    icono: Icons.face_retouching_natural,
                    titulo: 'Prueba virtual',
                    descripcion: 'Visualiza nuevos cambios',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PruebaVirtualPage(),
                        ),
                      );
                    },
                  ),
                  _OpcionCard(
                    icono: Icons.assignment_outlined,
                    titulo: 'Fichas capilares',
                    descripcion: 'Consulta el historial',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const FichasCapilaresPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF383838),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_outlined,
                      color: dorado,
                      size: 30,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cromalia Style',
                            style: TextStyle(
                              color: textoClaro,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tu arte. Tu identidad. Tu estilo.',
                            style: TextStyle(
                              color: textoSecundario,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpcionCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  const _OpcionCard({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: negroSuave,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF383838),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, color: dorado, size: 32),
              const SizedBox(height: 14),
              Text(
                titulo,
                style: const TextStyle(
                  color: textoClaro,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                descripcion,
                style: const TextStyle(
                  color: textoSecundario,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
