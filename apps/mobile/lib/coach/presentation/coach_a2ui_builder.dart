/// Presentation — translates a [CoachPlan] into A2UI v0.9 messages.
///
/// This is the GenUI seam: instead of hand-laying Flutter widgets, the Coach
/// emits the SAME protocol an LLM would stream (https://a2ui.org). A
/// [SurfaceController] with the built-in catalog then assembles the live UI.
///
/// For the demo this runs deterministically (no model, no API key); swapping in
/// the agentic-core sidecar later means replacing *who produces these messages*,
/// not the rendering.
library;

import 'package:genui/genui.dart';

import '../domain/career_band.dart';
import '../domain/competency_assessment.dart';

/// The two messages that paint the Coach surface, in order.
class CoachSurfaceMessages {
  const CoachSurfaceMessages({required this.create, required this.update});

  final CreateSurface create;
  final UpdateComponents update;
}

class CoachA2uiBuilder {
  const CoachA2uiBuilder();

  /// Builds the A2UI messages for [plan] against [catalog] on [surfaceId].
  CoachSurfaceMessages build(
    CoachPlan plan, {
    required Catalog catalog,
    String surfaceId = 'coach',
  }) {
    final components = <Component>[];
    final rootChildren = <String>[];
    var seq = 0;
    String nextId(String prefix) => '$prefix-${seq++}';

    // Helper: append a Text component and return its id.
    String text(String value, {String variant = 'body'}) {
      final id = nextId('txt');
      components.add(
        Component(
          id: id,
          type: 'Text',
          properties: {'text': value, 'variant': variant},
        ),
      );
      return id;
    }

    void divider() {
      final id = nextId('div');
      components.add(Component(id: id, type: 'Divider', properties: const {}));
      rootChildren.add(id);
    }

    void section(String value) =>
        rootChildren.add(text(value, variant: 'h3'));

    // Wraps a child component id in a Card and adds it to the root.
    void card(String childId) {
      final id = nextId('card');
      components.add(
        Component(id: id, type: 'Card', properties: {'child': childId}),
      );
      rootChildren.add(id);
    }

    final a = plan.assessment;

    // --- Header ---
    rootChildren.add(text(a.candidateName, variant: 'h1'));
    rootChildren.add(text(a.roleTitle, variant: 'caption'));
    rootChildren.add(
      text(
        '**${a.readinessPercent}%** preparación · '
        '${a.currentBand.title} → ${a.targetBand.title}',
        variant: 'h2',
      ),
    );
    divider();

    // --- Gaps ---
    section('Brechas de competencia');
    for (final g in a.gaps) {
      final mark = switch (g.status) {
        GapStatus.met => '🟢',
        GapStatus.partial => '🟠',
        GapStatus.gap => '🔴',
      };
      final support = g.supportType == SupportType.tutor
          ? '📖 Tutor'
          : '🤝 Mentor';
      final body = text(
        '$mark **${g.dimension.label}** · ${g.status.label} · $support\n\n'
        '${g.requirement.descriptor}',
      );
      card(body);
    }
    divider();

    // --- Roadmap ---
    section('Roadmap sugerido');
    for (final s in plan.roadmap) {
      rootChildren.add(
        text('**${s.order}. ${s.title}** — _${s.horizon}_\n\n${s.description}'),
      );
    }
    divider();

    // --- Interview prep ---
    section('Interview prep (de tus libros)');
    for (final i in plan.interviewPrep) {
      final body = text(
        '**${i.topic}**\n\n_${i.source}_\n\n${i.why}\n\n❓ ${i.sampleQuestion}',
      );
      card(body);
    }

    // Root must have id 'root' (Surface convention).
    components.add(
      Component(
        id: 'root',
        type: 'Column',
        properties: {'children': rootChildren, 'align': 'start'},
      ),
    );

    return CoachSurfaceMessages(
      create: CreateSurface(
        surfaceId: surfaceId,
        catalogId: catalog.catalogId ?? 'keiko-coach',
      ),
      update: UpdateComponents(surfaceId: surfaceId, components: components),
    );
  }
}
