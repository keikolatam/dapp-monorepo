/// Domain — the target role expressed as a band rubric (the "vacancy").
///
/// Vacancy-first (ADR-0007): the role the candidate aims at is the source of
/// truth. Here it is an IBM SRE band, but the shape is generic — any job
/// description can be encoded as a [TargetRole] with weighted [BandRequirement]s.
library;

/// The competency axes the rubric measures. Mirrors the IBM SRE band doc:
/// Outcomes/KPIs, Skills-Knowledge, Skills-Proficiency, Behaviors, Scope.
enum CoachDimension {
  outcomes,
  knowledge,
  proficiency,
  behaviors,
  scope;

  static CoachDimension fromString(String raw) =>
      CoachDimension.values.firstWhere(
        (d) => d.name == raw,
        orElse: () => CoachDimension.knowledge,
      );

  /// Human label (Spanish, for the UI).
  String get label => switch (this) {
        CoachDimension.outcomes => 'Resultados / KPIs',
        CoachDimension.knowledge => 'Conocimiento técnico',
        CoachDimension.proficiency => 'Dominio / certificación',
        CoachDimension.behaviors => 'Comportamientos / marca',
        CoachDimension.scope => 'Alcance de influencia',
      };
}

/// Irby (2018): a knowledge gap is closed by a *tutor*; an experience, brand,
/// or judgment gap is closed by a *mentor*. This drives the support
/// recommendation (the "C" subsystem) downstream.
enum SupportType {
  tutor,
  mentor;

  static SupportType fromString(String raw) => SupportType.values.firstWhere(
        (s) => s.name == raw,
        orElse: () => SupportType.mentor,
      );

  String get label => this == SupportType.tutor ? 'Tutor' : 'Mentor';
}

/// One requirement the target band expects the candidate to demonstrate.
class BandRequirement {
  const BandRequirement({
    required this.dimension,
    required this.descriptor,
    required this.evidenceSignals,
    required this.supportType,
    this.weight = 1,
  });

  factory BandRequirement.fromJson(Map<String, dynamic> json) {
    return BandRequirement(
      dimension: CoachDimension.fromString(json['dimension'] as String),
      descriptor: json['descriptor'] as String,
      evidenceSignals: (json['evidenceSignals'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      supportType: SupportType.fromString(json['supportType'] as String),
      weight: (json['weight'] as num?)?.toInt() ?? 1,
    );
  }

  final CoachDimension dimension;
  final String descriptor;
  final List<String> evidenceSignals;
  final SupportType supportType;

  /// Relative importance (1–3). Heavier requirements move readiness more and
  /// surface earlier in the roadmap.
  final int weight;
}

/// A band within the role's progression ladder.
class CareerBand {
  const CareerBand({
    required this.id,
    required this.title,
    required this.expertiseLevel,
    this.requirements = const [],
  });

  factory CareerBand.fromJson(Map<String, dynamic> json) {
    return CareerBand(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      expertiseLevel: json['expertiseLevel'] as String? ?? '',
      requirements: ((json['requirements'] as List<dynamic>?) ?? [])
          .map((e) => BandRequirement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final String title;
  final String expertiseLevel;
  final List<BandRequirement> requirements;
}

/// The full target role: a ladder of bands plus the current/target pointers.
class TargetRole {
  const TargetRole({
    required this.roleId,
    required this.roleTitle,
    required this.currentBandId,
    required this.targetBandId,
    required this.bands,
  });

  factory TargetRole.fromJson(Map<String, dynamic> json) {
    return TargetRole(
      roleId: json['roleId'] as String,
      roleTitle: json['roleTitle'] as String,
      currentBandId: (json['currentBandId'] as num).toInt(),
      targetBandId: (json['targetBandId'] as num).toInt(),
      bands: (json['bands'] as List<dynamic>)
          .map((e) => CareerBand.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String roleId;
  final String roleTitle;
  final int currentBandId;
  final int targetBandId;
  final List<CareerBand> bands;

  CareerBand bandById(int id) =>
      bands.firstWhere((b) => b.id == id, orElse: () => bands.last);

  CareerBand get currentBand => bandById(currentBandId);
  CareerBand get targetBand => bandById(targetBandId);
}
