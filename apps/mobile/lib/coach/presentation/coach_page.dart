/// Presentation — the Keiko Coach de Carrera screen.
///
/// Renders a [CoachPlan]: readiness header → competency gaps → roadmap →
/// interview prep. This is the conventional Material 3 rendering; the GenUI
/// rendering (genui SurfaceController) reuses the very same [CoachPlan] via
/// [CoachA2uiBuilder] (see coach_a2ui_builder.dart).
library;

import 'package:flutter/material.dart';
import 'package:keiko_ui/keiko_ui.dart';

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
    // Edge-to-edge: padding inferior dinámico para no quedar detrás de la
    // barra de navegación del sistema.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      children: [
        KeikoMetricHeaderCard(
          title: a.candidateName,
          subtitle: a.roleTitle,
          percent: a.readinessPercent,
          progressLabel: 'Preparación para ${a.targetBand.expertiseLevel}',
          progressCaption: 'Desde ${a.currentBand.title}',
        ),
        const SizedBox(height: 24),
        KeikoSectionTitle('Brechas de competencia → ${a.targetBand.title}'),
        for (final g in a.gaps) _GapCard(gap: g),
        const SizedBox(height: 24),
        const KeikoSectionTitle('Roadmap sugerido'),
        for (final step in plan.roadmap)
          KeikoStepTile(
            order: step.order,
            title: step.title,
            description: step.description,
            tag: step.horizon,
          ),
        const SizedBox(height: 24),
        const KeikoSectionTitle('Interview prep (de tus libros)'),
        for (final item in plan.interviewPrep) _PrepTile(item: item),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _GapCard extends StatelessWidget {
  const _GapCard({required this.gap});

  final Gap gap;

  KeikoStatus get _status => switch (gap.status) {
        GapStatus.met => KeikoStatus.success,
        GapStatus.partial => KeikoStatus.warning,
        GapStatus.gap => KeikoStatus.error,
      };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                KeikoStatusDot(status: _status),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(gap.dimension.label, style: text.titleSmall),
                ),
                KeikoTagChip(label: gap.status.label),
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

