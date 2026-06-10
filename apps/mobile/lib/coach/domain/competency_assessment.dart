/// Domain — the keystone contract (ADR-0006).
///
/// [CompetencyAssessment] is consumed by the support-recommendation (C),
/// passport/xAPI (B) and job-matching (D) subsystems. [CoachPlan] bundles the
/// assessment with the two user-facing artifacts: a career roadmap and an
/// interview-prep plan.
library;

import 'career_band.dart';

/// How well the candidate meets a single requirement.
enum GapStatus {
  met,
  partial,
  gap;

  String get label => switch (this) {
        GapStatus.met => 'Cumplido',
        GapStatus.partial => 'Parcial',
        GapStatus.gap => 'Brecha',
      };
}

/// The evaluation of one [BandRequirement] against the candidate.
class Gap {
  const Gap({
    required this.requirement,
    required this.status,
    required this.evidenceFound,
    required this.rationale,
  });

  final BandRequirement requirement;
  final GapStatus status;

  /// Which of the requirement's evidence signals were found in the profile.
  final List<String> evidenceFound;
  final String rationale;

  SupportType get supportType => requirement.supportType;
  CoachDimension get dimension => requirement.dimension;
}

/// A time-bounded step on the path to the target band.
class RoadmapStep {
  const RoadmapStep({
    required this.order,
    required this.title,
    required this.description,
    required this.dimension,
    required this.horizon,
    required this.supportType,
  });

  final int order;
  final String title;
  final String description;
  final CoachDimension dimension;

  /// e.g. '0–3 meses', '3–6 meses', '6–12 meses'.
  final String horizon;
  final SupportType supportType;
}

/// A topic to prepare for the mock interview, grounded in a knowledge source.
class InterviewPrepItem {
  const InterviewPrepItem({
    required this.topic,
    required this.why,
    required this.source,
    required this.sampleQuestion,
  });

  final String topic;
  final String why;

  /// Citable knowledge-base reference, e.g. "The Kubernetes Book — Deployments".
  final String source;
  final String sampleQuestion;
}

/// The assessment itself: gaps + an overall readiness score.
class CompetencyAssessment {
  const CompetencyAssessment({
    required this.candidateName,
    required this.roleTitle,
    required this.currentBand,
    required this.targetBand,
    required this.gaps,
    required this.readiness,
  });

  final String candidateName;
  final String roleTitle;
  final CareerBand currentBand;
  final CareerBand targetBand;
  final List<Gap> gaps;

  /// Weighted fraction of requirements met (0.0–1.0).
  final double readiness;

  List<Gap> get unmet =>
      gaps.where((g) => g.status != GapStatus.met).toList();

  int get readinessPercent => (readiness * 100).round();
}

/// The full coach output: assessment + roadmap + interview prep.
class CoachPlan {
  const CoachPlan({
    required this.assessment,
    required this.roadmap,
    required this.interviewPrep,
  });

  final CompetencyAssessment assessment;
  final List<RoadmapStep> roadmap;
  final List<InterviewPrepItem> interviewPrep;
}
