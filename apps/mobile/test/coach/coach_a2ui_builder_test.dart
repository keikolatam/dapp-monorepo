import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:keiko_app/coach/application/gap_analysis_service.dart';
import 'package:keiko_app/coach/domain/career_band.dart';
import 'package:keiko_app/coach/domain/competency_assessment.dart';
import 'package:keiko_app/coach/infrastructure/reactive_resume_parser.dart';
import 'package:keiko_app/coach/presentation/coach_a2ui_builder.dart';
import 'package:keiko_app/coach/presentation/coach_genui_page.dart';

CoachPlan _demoPlan() {
  Map<String, dynamic> load(String p) =>
      jsonDecode(File(p).readAsStringSync()) as Map<String, dynamic>;
  const parser = ReactiveResumeParser();
  final profile = parser.parse(load('assets/coach/candidate_profile.json'));
  final role = TargetRole.fromJson(load('assets/coach/target_role_rubric.json'));
  const service = GapAnalysisService();
  final assessment = service.assess(profile: profile, role: role);
  return service.buildPlan(assessment: assessment, profile: profile);
}

void main() {
  test('A2UI surface is referentially sound (root exists, refs resolve)', () {
    final catalog =
        BasicCatalogItems.asCatalog().copyWith(catalogId: 'keiko-coach');
    final messages = const CoachA2uiBuilder().build(_demoPlan(), catalog: catalog);

    final byId = {for (final c in messages.update.components) c.id: c};

    // Root contract.
    expect(byId.containsKey('root'), isTrue);
    expect(byId['root']!.type, 'Column');

    // catalogId matches the catalog the surface will be rendered with.
    expect(messages.create.catalogId, 'keiko-coach');

    // Every child id referenced by the root resolves to a real component.
    final rootChildren =
        (byId['root']!.properties['children']! as List).cast<String>();
    expect(rootChildren, isNotEmpty);
    for (final childId in rootChildren) {
      expect(byId.containsKey(childId), isTrue, reason: 'dangling ref $childId');
    }

    // Every Card child id also resolves.
    for (final c in messages.update.components.where((c) => c.type == 'Card')) {
      expect(byId.containsKey(c.properties['child']), isTrue);
    }
  });

  testWidgets('GenUI page renders the surface without throwing',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CoachGenUiPage())),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(Surface), findsOneWidget);
    // The SDK assembled at least some text from the A2UI messages.
    expect(find.byType(Text), findsWidgets);
  });
}
