/// Stories de Theme — paletas de `keiko_ui/lib/theme/`.
///
/// Muestra las rampas tonales de [BrandColors] (100→900) y los roles
/// semánticos de [KeikoSemanticColors] resueltos contra el tema activo,
/// para auditar contraste en light/dark desde el addon.
library;

import 'package:flutter/material.dart';
import 'package:keiko_ui/keiko_ui.dart';
import 'package:widgetbook/widgetbook.dart';

final themeFolder = WidgetbookFolder(
  name: 'theme',
  children: [
    WidgetbookComponent(
      name: 'Colors',
      useCases: [
        WidgetbookUseCase(
          name: 'BrandColors (rampas tonales)',
          builder: (context) => const _BrandRampsStory(),
        ),
        WidgetbookUseCase(
          name: 'KeikoSemanticColors',
          builder: (context) => const _SemanticColorsStory(),
        ),
      ],
    ),
  ],
);

const _ramps = <String, List<Color>>{
  'primary': [
    BrandColors.primary100,
    BrandColors.primary200,
    BrandColors.primary300,
    BrandColors.primary400,
    BrandColors.primary500,
    BrandColors.primary600,
    BrandColors.primary700,
    BrandColors.primary800,
    BrandColors.primary900,
  ],
  'secondary': [
    BrandColors.secondary100,
    BrandColors.secondary200,
    BrandColors.secondary300,
    BrandColors.secondary400,
    BrandColors.secondary500,
    BrandColors.secondary600,
    BrandColors.secondary700,
    BrandColors.secondary800,
    BrandColors.secondary900,
  ],
  'accent': [
    BrandColors.accent100,
    BrandColors.accent200,
    BrandColors.accent300,
    BrandColors.accent400,
    BrandColors.accent500,
    BrandColors.accent600,
    BrandColors.accent700,
    BrandColors.accent800,
    BrandColors.accent900,
  ],
  'warning': [
    BrandColors.warning100,
    BrandColors.warning200,
    BrandColors.warning300,
    BrandColors.warning400,
    BrandColors.warning500,
    BrandColors.warning600,
    BrandColors.warning700,
    BrandColors.warning800,
    BrandColors.warning900,
  ],
  'error': [
    BrandColors.error100,
    BrandColors.error200,
    BrandColors.error300,
    BrandColors.error400,
    BrandColors.error500,
    BrandColors.error600,
    BrandColors.error700,
    BrandColors.error800,
    BrandColors.error900,
  ],
};

class _BrandRampsStory extends StatelessWidget {
  const _BrandRampsStory();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('BrandColors — seed #215278', style: text.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Rampas 100 (claro) → 900 (oscuro), alineadas a tonos M3.',
            style: text.bodySmall,
          ),
          const SizedBox(height: 16),
          for (final entry in _ramps.entries) ...[
            Text(entry.key, style: text.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final (i, color) in entry.value.indexed)
                  Expanded(
                    child: _Swatch(label: '${(i + 1) * 100}', color: color),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final luminance = color.computeLuminance();
    return Container(
      height: 56,
      color: color,
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: luminance > 0.4 ? Colors.black87 : Colors.white,
        ),
      ),
    );
  }
}

class _SemanticColorsStory extends StatelessWidget {
  const _SemanticColorsStory();

  @override
  Widget build(BuildContext context) {
    final semantic = KeikoSemanticColors.of(context);
    final text = Theme.of(context).textTheme;
    final roles = <String, (Color, Color)>{
      'success': (semantic.success, semantic.onSuccess),
      'successContainer': (
        semantic.successContainer,
        semantic.onSuccessContainer,
      ),
      'warning': (semantic.warning, semantic.onWarning),
      'warningContainer': (
        semantic.warningContainer,
        semantic.onWarningContainer,
      ),
    };
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('KeikoSemanticColors', style: text.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'ThemeExtension para roles que M3 no cubre (success/warning). '
            'Cambia con el addon de tema light/dark.',
            style: text.bodySmall,
          ),
          const SizedBox(height: 16),
          for (final entry in roles.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: 56,
                color: entry.value.$1,
                alignment: Alignment.center,
                child: Text(
                  entry.key,
                  style: TextStyle(color: entry.value.$2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
