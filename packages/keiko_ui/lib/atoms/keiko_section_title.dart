import 'package:flutter/material.dart';

/// Atom — section heading used to introduce a content block.
///
/// Renders [text] with `textTheme.headlineSmall` and a small bottom inset so
/// lists of cards/tiles can follow immediately.
class KeikoSectionTitle extends StatelessWidget {
  const KeikoSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
