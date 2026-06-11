/// Application — the gap-analysis engine.
///
/// Pure, deterministic, dependency-free: given a [CandidateProfile] and a
/// [TargetRole], it produces the keystone [CompetencyAssessment] and a
/// [CoachPlan]. No Flutter, no network — so it is trivially unit-testable and
/// can later run behind the agentic-core sidecar unchanged.
library;

import '../domain/candidate_profile.dart';
import '../domain/career_band.dart';
import '../domain/competency_assessment.dart';
import 'knowledge_base.dart';

class GapAnalysisService {
  const GapAnalysisService();

  /// Evaluate every requirement of the target band against the profile.
  CompetencyAssessment assess({
    required CandidateProfile profile,
    required TargetRole role,
  }) {
    final corpus = profile.evidenceCorpus;
    final target = role.targetBand;

    final gaps = <Gap>[];
    var weightedScore = 0.0;
    var weightTotal = 0.0;

    for (final req in target.requirements) {
      final found = req.evidenceSignals
          .where((s) => corpus.contains(s.toLowerCase()))
          .toList();
      final ratio =
          req.evidenceSignals.isEmpty ? 0.0 : found.length / req.evidenceSignals.length;

      final status = switch (ratio) {
        >= 0.5 => GapStatus.met,
        > 0.0 => GapStatus.partial,
        _ => GapStatus.gap,
      };

      weightedScore += req.weight * switch (status) {
            GapStatus.met => 1.0,
            GapStatus.partial => 0.5,
            GapStatus.gap => 0.0,
          };
      weightTotal += req.weight;

      gaps.add(
        Gap(
          requirement: req,
          status: status,
          evidenceFound: found,
          rationale: _rationale(status, req, found),
        ),
      );
    }

    return CompetencyAssessment(
      candidateName: profile.name,
      roleTitle: role.roleTitle,
      currentBand: role.currentBand,
      targetBand: target,
      gaps: gaps,
      readiness: weightTotal == 0 ? 0 : weightedScore / weightTotal,
    );
  }

  /// Build the user-facing plan from an assessment.
  CoachPlan buildPlan({
    required CompetencyAssessment assessment,
    required CandidateProfile profile,
  }) {
    // Order unmet requirements: hard gaps before partials, then heavier weight,
    // so the most leverage shows first.
    final unmet = [...assessment.unmet]..sort((a, b) {
        final byStatus = a.status.index.compareTo(b.status.index);
        if (byStatus != 0) return -byStatus; // gap(2) before partial(1)
        return b.requirement.weight.compareTo(a.requirement.weight);
      });

    const horizons = ['0–3 meses', '3–6 meses', '6–12 meses'];
    final roadmap = <RoadmapStep>[];
    for (var i = 0; i < unmet.length; i++) {
      final g = unmet[i];
      roadmap.add(
        RoadmapStep(
          order: i + 1,
          title: _stepTitle(g),
          description: g.requirement.descriptor,
          dimension: g.dimension,
          horizon: horizons[(i * horizons.length ~/ unmet.length)
              .clamp(0, horizons.length - 1)],
          supportType: g.supportType,
        ),
      );
    }

    return CoachPlan(
      assessment: assessment,
      roadmap: roadmap,
      interviewPrep: interviewPrepFor(profile.evidenceCorpus),
    );
  }

  String _rationale(GapStatus status, BandRequirement req, List<String> found) {
    return switch (status) {
      GapStatus.met =>
        'Evidencia suficiente: ${found.join(", ")}.',
      GapStatus.partial =>
        'Evidencia parcial (${found.join(", ")}). Falta formalizar o ampliar '
            'vía ${req.supportType.label.toLowerCase()}.',
      GapStatus.gap =>
        'Sin evidencia en el perfil. Brecha a cerrar con '
            '${req.supportType.label.toLowerCase()}.',
    };
  }

  String _stepTitle(Gap g) {
    final verb = g.supportType == SupportType.tutor ? 'Aprender' : 'Demostrar';
    return '$verb · ${g.dimension.label}';
  }
}
