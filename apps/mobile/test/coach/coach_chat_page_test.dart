import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keiko_app/coach/presentation/coach_chat_page.dart';
import 'package:keiko_ui/keiko_ui.dart';

void main() {
  testWidgets('sin NVIDIA_API_KEY muestra el estado vacío y el input '
      'deshabilitado', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CoachChatPage(apiKey: '')),
    );
    await tester.pump();

    expect(find.text('Configurá NVIDIA_API_KEY'), findsOneWidget);
    expect(find.textContaining('--dart-define=NVIDIA_API_KEY'), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
  });

  testWidgets('flujo completo con NIM mockeado: enviar → GenUI renderizada',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CoachChatPage(
          apiKey: '',
          streamCompletion: (history) => Stream.value(
            '```json\n{"version":"v0.9","createSurface":'
            '{"surfaceId":"model-1","catalogId":"keiko-coach"}}\n```\n'
            '```json\n{"version":"v0.9","updateComponents":'
            '{"surfaceId":"model-1","components":[{"id":"root",'
            '"component":"Text","text":"Enfocate en Kubernetes."}]}}\n```',
          ),
        ),
      ),
    );
    // initState carga el plan demo (assets) y arma la sesión.
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '¿qué estudio primero?');
    await tester.tap(find.byTooltip('Enviar'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Burbuja del usuario + respuesta del modelo como surface GenUI.
    expect(find.text('¿qué estudio primero?'), findsOneWidget);
    expect(find.textContaining('Enfocate en Kubernetes'), findsOneWidget);
  });

  group('KeikoChatInputBar', () {
    testWidgets('envía el texto trimmed y limpia el campo', (tester) async {
      String? sent;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeikoChatInputBar(onSend: (t) => sent = t),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '  hola coach  ');
      await tester.tap(find.byTooltip('Enviar'));
      await tester.pump();

      expect(sent, 'hola coach');
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty);
    });

    testWidgets('no envía vacío ni durante isLoading', (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeikoChatInputBar(onSend: (_) => calls++, isLoading: true),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'mensaje');
      await tester.tap(find.byTooltip('Enviar'), warnIfMissed: false);
      await tester.pump();
      expect(calls, 0);
    });
  });
}
