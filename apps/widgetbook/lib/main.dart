/// Catálogo Widgetbook de `packages/keiko_ui`.
///
/// Manual approach (sin codegen): las stories espejan la taxonomía Atomic
/// Design de `keiko_ui/lib/` — atoms → molecules → organisms — más una
/// sección Theme con las paletas. El addon de tema usa el MaterialTheme
/// compartido (light/dark), así cada story se ve con los tokens reales.
library;

import 'package:flutter/material.dart';
import 'package:keiko_ui/keiko_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'stories/atoms.dart';
import 'stories/molecules.dart';
import 'stories/organisms.dart';
import 'stories/theme.dart';

void main() => runApp(const KeikoWidgetbook());

class KeikoWidgetbook extends StatelessWidget {
  const KeikoWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    const materialTheme = MaterialTheme(TextTheme());
    return Widgetbook.material(
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: materialTheme.light()),
            WidgetbookTheme(name: 'Dark', data: materialTheme.dark()),
          ],
        ),
      ],
      directories: [
        atomsFolder,
        moleculesFolder,
        organismsFolder,
        themeFolder,
      ],
    );
  }
}
