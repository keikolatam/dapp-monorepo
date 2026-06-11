/// Presentation — Keiko's custom GenUI catalog.
///
/// This is the GenUI extensibility story: domain-specific Material 3 widgets
/// registered as [CatalogItem]s with a JSON schema. The content generator
/// (today the deterministic engine, tomorrow an LLM via NIM/agentic-core)
/// composes the UI by referencing these by NAME in A2UI messages — it never
/// touches Flutter code.
library;

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

/// Semaphore palette for a gap status. Explicit colors (not scheme-derived)
/// because the semaphore IS the semantic: green/amber/red must read as such
/// in light and dark themes alike.
class _Semaphore {
  const _Semaphore(this.accent, this.container, this.onContainer);

  final Color accent;
  final Color container;
  final Color onContainer;

  static _Semaphore of(String status) => switch (status) {
        'met' => const _Semaphore(
            Color(0xFF2E7D32), Color(0xFFC8E6C9), Color(0xFF1B5E20)),
        'partial' => const _Semaphore(
            Color(0xFFEF6C00), Color(0xFFFFE0B2), Color(0xFF7A4F00)),
        _ => const _Semaphore(
            Color(0xFFC62828), Color(0xFFFFCDD2), Color(0xFF8E0000)),
      };
}

/// `GapCard` — Material 3 card for one competency gap / recommendation,
/// with a semaphore color bar + status chip instead of emojis.
final CatalogItem keikoGapCard = CatalogItem(
  name: 'GapCard',
  dataSchema: S.object(
    description:
        'Material 3 card for a competency gap or recommendation. Renders a '
        'semaphore color (met=green, partial=amber, gap=red), a status chip, '
        'the requirement text, and which support type closes the gap.',
    properties: {
      'title': S.string(description: 'Competency dimension or short title.'),
      'status': S.string(
        description: 'Semaphore status.',
        enumValues: ['met', 'partial', 'gap'],
      ),
      'statusLabel': S.string(description: 'Human label for the status chip.'),
      'body': S.string(description: 'Requirement descriptor text.'),
      'support': S.string(
        description: 'Irby (2018) support type that closes this gap.',
        enumValues: ['tutor', 'mentor'],
      ),
      'supportLabel': S.string(description: 'Human label for the support row.'),
      'rationale': S.string(description: 'Optional evidence rationale.'),
    },
    required: ['title', 'status', 'statusLabel', 'body'],
  ),
  exampleData: [
    () => '''
      [
        {
          "id": "root",
          "component": "GapCard",
          "title": "Conocimiento técnico",
          "status": "met",
          "statusLabel": "Cumplido",
          "body": "In-depth multi-cloud knowledge.",
          "support": "tutor",
          "supportLabel": "Cierra con un Tutor"
        }
      ]
    ''',
  ],
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, Object?>;
    final status = data['status'] as String? ?? 'gap';
    final sem = _Semaphore.of(status);
    final theme = Theme.of(itemContext.buildContext);
    final support = data['support'] as String?;
    final rationale = data['rationale'] as String?;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra semáforo
            Container(width: 6, color: sem.accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data['title'] as String? ?? '',
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        Chip(
                          label: Text(data['statusLabel'] as String? ?? ''),
                          backgroundColor: sem.container,
                          labelStyle: theme.textTheme.labelMedium
                              ?.copyWith(color: sem.onContainer),
                          side: BorderSide(color: sem.accent),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['body'] as String? ?? '',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (support != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            support == 'tutor'
                                ? Icons.menu_book
                                : Icons.handshake,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            data['supportLabel'] as String? ?? '',
                            style: theme.textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ],
                    if (rationale != null && rationale.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(rationale, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
);

/// The catalog the Coach surfaces render with: genui built-ins + Keiko's
/// custom items. The generator references these by name.
Catalog buildCoachCatalog() => BasicCatalogItems.asCatalog()
    .copyWith(newItems: [keikoGapCard], catalogId: 'keiko-coach');
