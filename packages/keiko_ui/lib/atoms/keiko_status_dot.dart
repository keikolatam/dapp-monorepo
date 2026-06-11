import 'package:flutter/material.dart';

import '../theme/semantic_colors.dart';

/// Semantic status of a [KeikoStatusDot] (and friends).
enum KeikoStatus { success, warning, error, neutral }

/// Atom — small colored dot conveying a semantic status.
///
/// Colors resolve through the theme ([KeikoSemanticColors] /
/// [ColorScheme]); nothing is hardcoded.
class KeikoStatusDot extends StatelessWidget {
  const KeikoStatusDot({super.key, required this.status, this.size = 12});

  final KeikoStatus status;
  final double size;

  Color _color(BuildContext context) {
    final semantic = KeikoSemanticColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      KeikoStatus.success => semantic.success,
      KeikoStatus.warning => semantic.warning,
      KeikoStatus.error => scheme.error,
      KeikoStatus.neutral => scheme.outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.circle, size: size, color: _color(context));
  }
}
