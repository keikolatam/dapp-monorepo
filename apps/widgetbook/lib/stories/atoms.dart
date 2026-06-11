/// Stories de atoms — espeja `keiko_ui/lib/atoms/`.
library;

import 'package:flutter/material.dart';
import 'package:keiko_ui/keiko_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'story_scaffold.dart';

final atomsFolder = WidgetbookFolder(
  name: 'atoms',
  children: [
    WidgetbookComponent(
      name: 'KeikoSectionTitle',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => StoryScaffold(
            child: KeikoSectionTitle(
              context.knobs.string(
                label: 'text',
                initialValue: 'Brechas de competencia',
              ),
            ),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'KeikoPercentBadge',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => StoryScaffold(
            child: KeikoPercentBadge(
              value: context.knobs.int.slider(
                label: 'value',
                initialValue: 45,
                min: 0,
                max: 100,
              ),
              size: context.knobs.double.slider(
                label: 'size',
                initialValue: 72,
                min: 40,
                max: 160,
              ),
            ),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'KeikoStatusDot',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => StoryScaffold(
            child: KeikoStatusDot(
              status: context.knobs.object.dropdown(
                label: 'status',
                options: KeikoStatus.values,
                labelBuilder: (s) => s.name,
              ),
              size: context.knobs.double.slider(
                label: 'size',
                initialValue: 12,
                min: 6,
                max: 48,
              ),
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Semáforo (todos los estados)',
          builder: (context) => StoryScaffold(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final status in KeikoStatus.values) ...[
                  KeikoStatusDot(status: status, size: 20),
                  const SizedBox(width: 8),
                  Text(status.name),
                  const SizedBox(width: 24),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'KeikoTagChip',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => StoryScaffold(
            child: KeikoTagChip(
              label: context.knobs.string(
                label: 'label',
                initialValue: 'Parcial',
              ),
              icon: context.knobs.boolean(
                label: 'con icon',
                initialValue: false,
              )
                  ? Icons.menu_book
                  : null,
            ),
          ),
        ),
      ],
    ),
  ],
);
