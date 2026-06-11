import 'package:flutter/material.dart';

/// Molecule — labeled linear progress with an optional caption underneath.
///
/// Used for readiness/completion meters: `label` on top, the bar in the
/// middle, `caption` (e.g. the starting point) at the bottom.
class KeikoProgressMeter extends StatelessWidget {
  const KeikoProgressMeter({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.minHeight = 8,
  });

  final String label;

  /// Progress in `0.0..1.0`.
  final double value;
  final String? caption;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.titleMedium),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: value, minHeight: minHeight),
        if (caption != null) ...[
          const SizedBox(height: 8),
          Text(caption!, style: text.bodySmall),
        ],
      ],
    );
  }
}
