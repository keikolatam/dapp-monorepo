import 'package:flutter/material.dart';

/// Atom — circular badge displaying a percentage (e.g. readiness score).
class KeikoPercentBadge extends StatelessWidget {
  const KeikoPercentBadge({super.key, required this.value, this.size = 72});

  /// Percent in `0..100`.
  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$value%',
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: scheme.onPrimaryContainer),
      ),
    );
  }
}
