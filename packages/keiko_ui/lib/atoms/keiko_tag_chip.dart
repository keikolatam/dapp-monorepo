import 'package:flutter/material.dart';

/// Atom — compact chip for short labels (statuses, horizons, tags).
///
/// Wraps [Chip] with compact density; colors/typography come from the
/// ambient [ChipThemeData].
class KeikoTagChip extends StatelessWidget {
  const KeikoTagChip({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: icon == null ? null : Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
