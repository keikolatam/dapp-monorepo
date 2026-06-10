import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:keiko_app/coach/application/gap_analysis_service.dart';
import 'package:keiko_app/coach/domain/career_band.dart';
import 'package:keiko_app/coach/domain/competency_assessment.dart';
import 'package:keiko_app/coach/infrastructure/reactive_resume_parser.dart';

void main() {
  // flutter test runs with CWD = package root (apps/mobile).
  Map<String, dynamic> loadJson(String path) =>
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

  late TargetRole role;
  late CompetencyAssessment assessment;
  late CoachPlan plan;

  setUp(() {
    const parser = ReactiveResumeParser();
    final profile =
        parser.parse(loadJson('assets/coach/candidate_profile.json'));
    role = TargetRole.fromJson(loadJson('assets/coach/target_role_rubric.json'));

    const service = GapAnalysisService();
    assessment = service.assess(profile: profile, role: role);
    plan = service.buildPlan(assessment: assessment, profile: profile);
  });

  test('parser stays schema-agnostic (reads rxresu.me without imposing it)', () {
    const parser = ReactiveResumeParser();
    final profile =
        parser.parse(loadJson('assets/coach/candidate_profile.json'));
    expect(profile.name, 'Andrés Peña Castillo');
    expect(profile.skills, isNotEmpty);
    expect(profile.experiences.first.company, 'IBM');
    expect(profile.communities, isNotEmpty);
  });

  test('technical knowledge is recognized as met (ArgoCD/OpenShift evidence)',
      () {
    final knowledge = assessment.gaps
        .firstWhere((g) => g.dimension == CoachDimension.knowledge &&
            g.requirement.descriptor.contains('multi-cloud'));
    expect(knowledge.status, GapStatus.met);
    expect(knowledge.evidenceFound, contains('ArgoCD'));
  });

  test('L3 certification is a hard gap (no evidence in profile)', () {
    final cert = assessment.gaps.firstWhere(
        (g) => g.requirement.descriptor.contains('TLRB'));
    expect(cert.status, GapStatus.gap);
    expect(cert.supportType, SupportType.tutor);
  });

  test('readiness is a believable mid-range (technical strong, brand/cert weak)',
      () {
    expect(assessment.readinessPercent, inInclusiveRange(35, 80));
  });

  test('roadmap leads with hard gaps and pairs each with tutor/mentor', () {
    expect(plan.roadmap, isNotEmpty);
    expect(plan.roadmap.first.order, 1);
    // Every unmet requirement becomes exactly one roadmap step.
    expect(plan.roadmap.length, assessment.unmet.length);
  });

  test('interview prep is grounded in the converted books and capped', () {
    expect(plan.interviewPrep, isNotEmpty);
    expect(plan.interviewPrep.length, lessThanOrEqualTo(5));
    expect(
      plan.interviewPrep.any((i) => i.source.contains('Argo CD')),
      isTrue,
    );
  });
}
