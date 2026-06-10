/// Presentation — the Keiko Coach de Carrera screen.
///
/// Renders a [CoachPlan]: readiness header → competency gaps → roadmap →
/// interview prep. This is the conventional Material 3 rendering; the GenUI
/// rendering (genui SurfaceController) reuses the very same [CoachPlan] via
/// [CoachA2uiBuilder] (see coach_a2ui_builder.dart).
library;

import 'package:flutter/material.dart';

import '../application/coach_repository.dart';
import '../domain/career_band.dart';
import '../domain/competency_assessment.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key, this.repository = const CoachRepository()});

  final CoachRepository repository;

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  late Future<CoachPlan> _plan;

  @override
  void initState() {
    super.initState();
    _plan = widget.repository.loadDemoPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keiko · Coach de Carrera')),
      body: FutureBuilder<CoachPlan>(
        future: _plan,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _PlanView(plan: snapshot.data!);
        },
      ),
    );
  }
}

class _PlanView extends StatelessWidget {
  const _PlanView({required this.plan});

  final CoachPlan plan;

  @override
  Widget build(BuildContext context) {
    final a = plan.assessment;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReadinessHeader(assessment: a),
        const SizedBox(height: 24),
        _SectionTitle('Brechas de competencia → ${a.targetBand.title}'),
        for (final g in a.gaps) _GapCard(gap: g),
        const SizedBox(height: 24),
        _SectionTitle('Roadmap sugerido'),
        for (final step in plan.roadmap) _RoadmapTile(step: step),
        const SizedBox(height: 24),
        _SectionTitle('Interview prep (de tus libros)'),
        for (final item in plan.interviewPrep) _PrepTile(item: item),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ReadinessHeader extends StatelessWidget {
  const _ReadinessHeader({required this.assessment});

  final CompetencyAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assessment.candidateName, style: text.titleLarge),
            const SizedBox(height: 4),
            Text(assessment.roleTitle, style: text.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                _BigPercent(value: assessment.readinessPercent, scheme: scheme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preparación para ${assessment.targetBand.expertiseLevel}',
                        style: text.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: assessment.readiness,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Desde ${assessment.currentBand.title}',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BigPercent extends StatelessWidget {
  const _BigPercent({required this.value, required this.scheme});

  final int value;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$value%',
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: scheme.onPrimaryContainer),
      ),
    );
  }
}

class _GapCard extends StatelessWidget {
  const _GapCard({required this.gap});

  final Gap gap;

  Color _statusColor(ColorScheme s) => switch (gap.status) {
        GapStatus.met => Colors.green,
        GapStatus.partial => Colors.orange,
        GapStatus.gap => s.error,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: _statusColor(scheme)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(gap.dimension.label, style: text.titleSmall),
                ),
                Chip(
                  label: Text(gap.status.label),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(gap.requirement.descriptor, style: text.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  gap.supportType == SupportType.tutor
                      ? Icons.menu_book
                      : Icons.handshake,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  gap.supportType == SupportType.tutor
                      ? 'Cierra con un Tutor'
                      : 'Cierra con un Mentor',
                  style: text.labelMedium,
                ),
              ],
            ),
            if (gap.status != GapStatus.met) ...[
              const SizedBox(height: 6),
              Text(gap.rationale, style: text.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoadmapTile extends StatelessWidget {
  const _RoadmapTile({required this.step});

  final RoadmapStep step;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.secondaryContainer,
        child: Text('${step.order}'),
      ),
      title: Text(step.title),
      subtitle: Text(step.description),
      trailing: Chip(
        label: Text(step.horizon),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _PrepTile extends StatelessWidget {
  const _PrepTile({required this.item});

  final InterviewPrepItem item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: ExpansionTile(
        title: Text(item.topic, style: text.titleSmall),
        subtitle: Text(item.source, style: text.bodySmall),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(item.why, style: text.bodyMedium),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('❓ ${item.sampleQuestion}', style: text.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}
