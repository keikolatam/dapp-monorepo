import 'package:flutter/material.dart';

/// Envoltorio común de stories: surface del tema activo + padding, para que
/// cada componente se vea sobre el fondo real (light/dark) y centrado.
class StoryScaffold extends StatelessWidget {
  const StoryScaffold({super.key, required this.child, this.maxWidth = 480});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    );
  }
}
