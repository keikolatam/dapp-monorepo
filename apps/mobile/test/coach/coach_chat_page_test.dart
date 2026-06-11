import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keiko_app/coach/application/coach_repository.dart';
import 'package:keiko_app/coach/application/gap_analysis_service.dart';
import 'package:keiko_app/coach/domain/career_band.dart';
import 'package:keiko_app/coach/domain/competency_assessment.dart';
import 'package:keiko_app/coach/infrastructure/reactive_resume_parser.dart';
import 'package:keiko_app/coach/presentation/coach_chat_page.dart';
import 'package:keiko_ui/keiko_ui.dart';

/// Repo con lectura síncrona de los fixtures (dart:io): `rootBundle` se
/// cuelga bajo fake-async cuando más de un test del mismo proceso carga
/// assets, así que los widget tests inyectan este fake.
class _FakeRepository extends CoachRepository {
  const _FakeRepository();

  @override
  Future<CoachPlan> loadDemoPlan() async {
    Map<String, dynamic> load(String p) =>
        jsonDecode(File(p).readAsStringSync()) as Map<String, dynamic>;
    const parser = ReactiveResumeParser();
    final profile = parser.parse(load('assets/coach/candidate_profile.json'));
    final role =
        TargetRole.fromJson(load('assets/coach/target_role_rubric.json'));
    const service = GapAnalysisService();
    final assessment = service.assess(profile: profile, role: role);
    return service.buildPlan(assessment: assessment, profile: profile);
  }
}

void main() {
  testWidgets('gateway inaccesible: estado "Gateway no disponible" con '
      'Reintentar y el input deshabilitado', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        // Esquema inválido: el connect falla localmente (sin sockets reales),
        // por el mismo path de error que un gateway caído.
        home: CoachChatPage(
          repository: _FakeRepository(),
          wsUrl: 'foo://gateway-invalido',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gateway no disponible'), findsOneWidget);
    expect(find.textContaining('run-local.sh'), findsOneWidget);
    expect(find.textContaining('adb reverse'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
  });

  testWidgets('flujo completo con gateway mockeado: enviar → GenUI renderizada',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CoachChatPage(
          repository: const _FakeRepository(),
          wsUrl: '',
          streamTurn: (content) => Stream.value(
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
