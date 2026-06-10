import 'package:flutter/material.dart';

import 'coach/presentation/coach_genui_page.dart';
import 'coach/presentation/coach_page.dart';

void main() => runApp(const KeikoApp());

class KeikoApp extends StatelessWidget {
  const KeikoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(keiko_ui): swap for keiko_ui's MaterialTheme once its BrandColors
    // palette is filled via /atomic-design-toolkit:generate. Today that palette
    // is an all-black placeholder, so we seed a usable M3 scheme here.
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF215278), // Keiko primary (from resume accent)
    );
    return MaterialApp(
      title: 'Keiko',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: scheme),
      home: const CoachHome(),
    );
  }
}

/// Home: the GenUI rendering, with a shortcut to the conventional view so the
/// demo can show both painting the very same [CoachPlan].
class CoachHome extends StatelessWidget {
  const CoachHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keiko · Coach de Carrera (GenUI)'),
        actions: [
          IconButton(
            tooltip: 'Ver versión clásica',
            icon: const Icon(Icons.view_agenda_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CoachPage()),
            ),
          ),
        ],
      ),
      body: const CoachGenUiPage(),
    );
  }
}
