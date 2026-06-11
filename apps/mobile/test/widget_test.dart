// Smoke test: la app arranca con el tema keiko_ui y muestra el home GenUI.

import 'package:flutter_test/flutter_test.dart';

import 'package:keiko_app/main.dart';

void main() {
  testWidgets('KeikoApp arranca y muestra el home del Coach', (tester) async {
    await tester.pumpWidget(const KeikoApp());

    expect(find.text('Keiko · Coach de Carrera (GenUI)'), findsOneWidget);
  });
}
