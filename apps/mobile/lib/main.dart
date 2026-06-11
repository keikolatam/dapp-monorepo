import 'package:flutter/material.dart';
import 'package:keiko_ui/keiko_ui.dart';

import 'coach/presentation/coach_genui_page.dart';
import 'coach/presentation/coach_page.dart';

void main() => runApp(const KeikoApp());

class KeikoApp extends StatelessWidget {
  const KeikoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema compartido de keiko_ui (Atomic Design + M3, seed #215278).
    const materialTheme = MaterialTheme(TextTheme());
    return MaterialApp(
      title: 'Keiko',
      debugShowCheckedModeBanner: false,
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
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
