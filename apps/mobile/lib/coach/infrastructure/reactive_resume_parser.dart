/// Infrastructure — adapter from the Reactive Resume (rxresu.me) schema to the
/// domain [CandidateProfile].
///
/// This is the concrete proof of ADR-0007: the user keeps their own CV format;
/// the Coach only depends on its own domain shape. Swapping in a JSON Resume or
/// LinkedIn parser would not touch the domain or the gap engine.
library;

import '../domain/candidate_profile.dart';

class ReactiveResumeParser {
  const ReactiveResumeParser();

  /// Strips lightweight HTML so descriptions become plain evidence tokens.
  static String _stripHtml(String input) => input
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static List<String> _bullets(String html) {
    // Reactive Resume stores rich text as <ul><li>…</li></ul>.
    final matches = RegExp(r'<li>(.*?)</li>', dotAll: true).allMatches(html);
    if (matches.isEmpty) {
      final plain = _stripHtml(html);
      return plain.isEmpty ? const [] : [plain];
    }
    return matches.map((m) => _stripHtml(m.group(1) ?? '')).toList();
  }

  CandidateProfile parse(Map<String, dynamic> json) {
    final basics = (json['basics'] as Map<String, dynamic>?) ?? const {};
    final sections = (json['sections'] as Map<String, dynamic>?) ?? const {};

    List<Map<String, dynamic>> itemsOf(String section) {
      final node = sections[section] as Map<String, dynamic>?;
      final items = (node?['items'] as List<dynamic>?) ?? const [];
      return items.cast<Map<String, dynamic>>();
    }

    final skills = itemsOf('skills')
        .map(
          (s) => CandidateSkill(
            name: s['name'] as String? ?? '',
            level: (s['level'] as num?)?.toInt() ?? 0,
            keywords: ((s['keywords'] as List<dynamic>?) ?? const [])
                .map((e) => e as String)
                .toList(),
          ),
        )
        .toList();

    final experiences = itemsOf('experience').map((e) {
      // Highlights may arrive as a structured list or as an HTML description.
      final highlights = (e['highlights'] as List<dynamic>?)
              ?.map((h) => h as String)
              .toList() ??
          _bullets(e['description'] as String? ?? '');
      return CandidateExperience(
        company: e['company'] as String? ?? '',
        position: e['position'] as String? ?? '',
        period: e['period'] as String? ?? '',
        highlights: highlights,
        skills: ((e['skills'] as List<dynamic>?) ?? const [])
            .map((s) => s as String)
            .toList(),
      );
    }).toList();

    final communities = itemsOf('volunteer')
        .map(
          (c) => CandidateCommunity(
            organization: c['organization'] as String? ?? '',
            period: c['period'] as String? ?? '',
            description: _stripHtml(c['description'] as String? ?? ''),
          ),
        )
        .toList();

    final certifications = itemsOf('certifications')
        .map((c) => c['title'] as String? ?? '')
        .where((t) => t.isNotEmpty)
        .toList();

    final summaryNode = sections['summary'] as Map<String, dynamic>?;
    final summaryHtml = (json['summary'] as Map<String, dynamic>?)?['content'] ??
        summaryNode?['content'] ??
        '';

    return CandidateProfile(
      name: basics['name'] as String? ?? 'Candidato',
      headline: basics['headline'] as String? ?? '',
      summary: _stripHtml(summaryHtml as String),
      skills: skills,
      experiences: experiences,
      communities: communities,
      certifications: certifications,
    );
  }
}
