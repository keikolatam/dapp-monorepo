/// Stories de molecules — espeja `keiko_ui/lib/molecules/`.
library;

import 'package:flutter/material.dart';
import 'package:keiko_ui/keiko_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'story_scaffold.dart';

final moleculesFolder = WidgetbookFolder(
  name: 'molecules',
  children: [
    WidgetbookComponent(
      name: 'KeikoProgressMeter',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => StoryScaffold(
            child: KeikoProgressMeter(
              label: context.knobs.string(
                label: 'label',
                initialValue: 'Preparación para Band 10',
              ),
              value: context.knobs.double.slider(
                label: 'value',
                initialValue: 0.45,
                min: 0,
                max: 1,
                divisions: 100,
              ),
              caption: context.knobs.stringOrNull(
                label: 'caption',
                initialValue: 'Desde Band 8 · SRE Senior',
              ),
            ),
          ),
        ),
      ],
    ),
    WidgetbookComponent(
      name: 'KeikoStepTile',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => StoryScaffold(
            child: KeikoStepTile(
              order: context.knobs.int.slider(
                label: 'order',
                initialValue: 1,
                min: 1,
                max: 9,
              ),
              title: context.knobs.string(
                label: 'title',
                initialValue: 'Diseñar un sistema distribuido end-to-end',
              ),
              description: context.knobs.string(
                label: 'description',
                initialValue:
                    'Liderar el diseño de un servicio con SLOs y multi-región.',
              ),
              tag: context.knobs.stringOrNull(
                label: 'tag',
                initialValue: '3 meses',
              ),
            ),
          ),
        ),
        WidgetbookUseCase(
          name: 'Roadmap (secuencia)',
          builder: (context) => const StoryScaffold(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KeikoStepTile(
                  order: 1,
                  title: 'Cerrar brecha de system design',
                  description: 'Mentoría + diseño real revisado por pares.',
                  tag: '0-3 meses',
                ),
                KeikoStepTile(
                  order: 2,
                  title: 'Liderar un postmortem de incidente mayor',
                  description: 'Facilitar el análisis y las acciones.',
                  tag: '3-6 meses',
                ),
                KeikoStepTile(
                  order: 3,
                  title: 'Preparar entrevistas Band 10',
                  description: 'Simulacros con rúbrica de entrevista.',
                  tag: '6-9 meses',
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ],
);
