import 'package:flutter/material.dart';

import '../atoms/keiko_tag_chip.dart';

/// Molecule — numbered step in a sequence (roadmaps, checklists).
///
/// Leading circled [order], [title] + [description], and an optional
/// trailing [tag] chip (e.g. a time horizon).
class KeikoStepTile extends StatelessWidget {
  const KeikoStepTile({
    super.key,
    required this.order,
    required this.title,
    required this.description,
    this.tag,
  });

  final int order;
  final String title;
  final String description;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.secondaryContainer,
        child: Text('$order'),
      ),
      title: Text(title),
      subtitle: Text(description),
      trailing: tag == null ? null : KeikoTagChip(label: tag!),
    );
  }
}
