// Dev utility: prints Andrés's assessment to the console (no Flutter needed).
// Run: dart run tool/dump_assessment.dart
import 'dart:convert';
import 'dart:io';

import 'package:keiko_app/coach/application/gap_analysis_service.dart';
import 'package:keiko_app/coach/domain/career_band.dart';
import 'package:keiko_app/coach/infrastructure/reactive_resume_parser.dart';

void main() {
  Map<String, dynamic> load(String p) =>
      jsonDecode(File(p).readAsStringSync()) as Map<String, dynamic>;

  const parser = ReactiveResumeParser();
  final profile = parser.parse(load('assets/coach/candidate_profile.json'));
  final role = TargetRole.fromJson(load('assets/coach/target_role_rubric.json'));
  const service = GapAnalysisService();
  final a = service.assess(profile: profile, role: role);
  final plan = service.buildPlan(assessment: a, profile: profile);

  stdout.writeln('Readiness: ${a.readinessPercent}%  '
      '(${a.currentBand.title} → ${a.targetBand.title})');
  stdout.writeln('--- Gaps ---');
  for (final g in a.gaps) {
    stdout.writeln('[${g.status.label.padRight(8)}] '
        '${g.dimension.label.padRight(24)} ${g.supportType.label}');
  }
  stdout.writeln('--- Roadmap (${plan.roadmap.length} pasos) ---');
  for (final s in plan.roadmap) {
    stdout.writeln('${s.order}. ${s.title}  (${s.horizon})');
  }
  stdout.writeln('--- Interview prep (${plan.interviewPrep.length}) ---');
  for (final i in plan.interviewPrep) {
    stdout.writeln('• ${i.topic}');
  }
}
