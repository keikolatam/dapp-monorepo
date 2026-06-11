/// Presentation — the GenUI rendering of the Coach.
///
/// Same [CoachPlan] as [CoachPage], but assembled at runtime through the A2UI
/// protocol and the genui [SurfaceController] + built-in [Catalog]. This is the
/// hackathon-facing path: the interface is data (A2UI messages), not code.
library;

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../application/coach_repository.dart';
import 'coach_a2ui_builder.dart';
import 'coach_catalog.dart';

class CoachGenUiPage extends StatefulWidget {
  const CoachGenUiPage({super.key, this.repository = const CoachRepository()});

  final CoachRepository repository;

  @override
  State<CoachGenUiPage> createState() => _CoachGenUiPageState();
}

class _CoachGenUiPageState extends State<CoachGenUiPage> {
  static const _surfaceId = 'coach';

  // Catálogo Keiko: built-ins de genui + componentes custom (GapCard M3).
  final Catalog _catalog = buildCoachCatalog();
  late final SurfaceController _controller =
      SurfaceController(catalogs: [_catalog]);

  Object? _error;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    try {
      final plan = await widget.repository.loadDemoPlan();
      const builder = CoachA2uiBuilder();
      final messages =
          builder.build(plan, catalog: _catalog, surfaceId: _surfaceId);
      // Drive the surface directly — the "non-LLM backend / static content"
      // path from the genui design docs.
      _controller
        ..handleMessage(messages.create)
        ..handleMessage(messages.update);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    // Edge-to-edge: el scroll fluye detrás de la barra de navegación del
    // sistema, pero el final del contenido queda legible sobre ella.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Surface(
        surfaceContext: _controller.contextFor(_surfaceId),
        defaultBuilder: (_) => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
