/// Domain — the candidate's career profile.
///
/// Schema-agnostic by design (ADR-0007): the profile is a small, stable shape
/// the rest of the Coach reasons about. Adapters (e.g. the Reactive Resume
/// parser) translate whatever CV schema the user happens to have into this.
library;

/// A single skill with a self-reported proficiency level (1–5).
class CandidateSkill {
  const CandidateSkill({
    required this.name,
    required this.level,
    this.keywords = const [],
  });

  final String name;
  final int level;
  final List<String> keywords;
}

/// One professional experience entry.
class CandidateExperience {
  const CandidateExperience({
    required this.company,
    required this.position,
    required this.period,
    this.highlights = const [],
    this.skills = const [],
  });

  final String company;
  final String position;
  final String period;
  final List<String> highlights;
  final List<String> skills;
}

/// A community / giveback involvement — relevant to leadership & brand signals.
class CandidateCommunity {
  const CandidateCommunity({
    required this.organization,
    required this.period,
    this.description = '',
  });

  final String organization;
  final String period;
  final String description;
}

/// The aggregate the Coach reasons about.
class CandidateProfile {
  const CandidateProfile({
    required this.name,
    required this.headline,
    required this.summary,
    this.skills = const [],
    this.experiences = const [],
    this.communities = const [],
    this.certifications = const [],
  });

  final String name;
  final String headline;
  final String summary;
  final List<CandidateSkill> skills;
  final List<CandidateExperience> experiences;
  final List<CandidateCommunity> communities;
  final List<String> certifications;

  /// The full bag of lowercased evidence tokens used to match rubric signals.
  ///
  /// Flattening everything (skills, keywords, experience highlights, community
  /// descriptions, certs) into one searchable corpus is what lets the gap
  /// engine stay schema-agnostic: it never needs to know *where* a signal came
  /// from, only whether the candidate demonstrates it somewhere.
  String get evidenceCorpus {
    final parts = <String>[
      headline,
      summary,
      for (final s in skills) ...[s.name, ...s.keywords],
      for (final e in experiences) ...[
        e.company,
        e.position,
        ...e.highlights,
        ...e.skills,
      ],
      for (final c in communities) ...[c.organization, c.description],
      ...certifications,
    ];
    return parts.join('  ').toLowerCase();
  }
}
