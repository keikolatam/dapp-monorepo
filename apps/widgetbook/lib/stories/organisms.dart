/// Stories de organisms — espeja `keiko_ui/lib/organisms/`.
library;

import 'package:keiko_ui/keiko_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'story_scaffold.dart';

final organismsFolder = WidgetbookFolder(
  name: 'organisms',
  children: [
    WidgetbookComponent(
      name: 'KeikoMetricHeaderCard',
      useCases: [
        WidgetbookUseCase(
          name: 'Default',
          builder: (context) => StoryScaffold(
            child: KeikoMetricHeaderCard(
              title: context.knobs.string(
                label: 'title',
                initialValue: 'Andrés Peña',
              ),
              subtitle: context.knobs.string(
                label: 'subtitle',
                initialValue: 'Site Reliability Engineer · objetivo Band 10',
              ),
              percent: context.knobs.int.slider(
                label: 'percent',
                initialValue: 45,
                min: 0,
                max: 100,
              ),
              progressLabel: context.knobs.string(
                label: 'progressLabel',
                initialValue: 'Preparación para Staff level',
              ),
              progressCaption: context.knobs.stringOrNull(
                label: 'progressCaption',
                initialValue: 'Desde Band 8 · SRE Senior',
              ),
            ),
          ),
        ),
      ],
    ),
  ],
);
