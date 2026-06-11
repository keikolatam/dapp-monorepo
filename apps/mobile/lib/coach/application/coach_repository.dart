/// Application — loads the demo fixtures and runs the engine.
///
/// In production the profile would come from the user's uploaded CV and the
/// rubric from the selected vacancy; here both are bundled assets so the demo
/// is fully offline and reproducible.
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/career_band.dart';
import '../domain/competency_assessment.dart';
import '../infrastructure/reactive_resume_parser.dart';
import 'gap_analysis_service.dart';

class CoachRepository {
  const CoachRepository({
    this.profileAsset = 'assets/coach/candidate_profile.json',
    this.rubricAsset = 'assets/coach/target_role_rubric.json',
  });

  final String profileAsset;
  final String rubricAsset;

  Future<CoachPlan> loadDemoPlan() async {
    final profileJson = jsonDecode(await rootBundle.loadString(profileAsset))
        as Map<String, dynamic>;
    final rubricJson = jsonDecode(await rootBundle.loadString(rubricAsset))
        as Map<String, dynamic>;

    const parser = ReactiveResumeParser();
    final profile = parser.parse(profileJson);
    final role = TargetRole.fromJson(rubricJson);

    const service = GapAnalysisService();
    final assessment = service.assess(profile: profile, role: role);
    return service.buildPlan(assessment: assessment, profile: profile);
  }
}
