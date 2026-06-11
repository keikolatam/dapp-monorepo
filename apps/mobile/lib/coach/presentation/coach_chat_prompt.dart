/// Presentation — system prompt for the Coach chat over NVIDIA NIM.
///
/// Built with genui's [PromptBuilder.chat], which injects the A2UI schema and
/// the Keiko catalog (GapCard included) so the model composes the UI by NAME.
/// The Keiko fragments add the persona (Spanish) and the candidate's
/// [CompetencyAssessment] serialized as grounding context.
library;

import 'dart:convert';

import 'package:genui/genui.dart';

import '../domain/competency_assessment.dart';

const _persona = '''
Sos el Coach de Carrera de Keiko, una red social educativa que convierte el
aprendizaje en capital humano verificable. Acompañás al candidato a cerrar sus
brechas de competencia hacia su banda objetivo, recomendando tutores (brechas
de conocimiento) o mentores (brechas de experiencia, marca o criterio), según
Irby (2018).

Reglas:
- Respondé SIEMPRE en español.
- Basate en el CONTEXTO DEL CANDIDATO provisto: citá brechas, readiness y
  roadmap reales; no inventes datos del candidato.
- Componé tus respuestas como UI con el catálogo: usá `GapCard` para brechas o
  recomendaciones con semáforo, `Text` (admite markdown) para explicaciones,
  y `Card`/`Column` para agrupar.
- Sé concreto y accionable: cada respuesta debería dejarle al candidato un
  próximo paso claro.
''';

/// Serializes the assessment + plan into the JSON block the model grounds on.
String serializeCoachContext(CoachPlan plan) {
  final a = plan.assessment;
  return const JsonEncoder.withIndent('  ').convert({
    'candidateName': a.candidateName,
    'roleTitle': a.roleTitle,
    'currentBand': a.currentBand.title,
    'targetBand': a.targetBand.title,
    'readinessPercent': a.readinessPercent,
    'gaps': [
      for (final g in a.gaps)
        {
          'dimension': g.dimension.label,
          'status': g.status.name,
          'requirement': g.requirement.descriptor,
          'support': g.supportType.name,
          'rationale': g.rationale,
        },
    ],
    'roadmap': [
      for (final s in plan.roadmap)
        {
          'order': s.order,
          'title': s.title,
          'horizon': s.horizon,
          'description': s.description,
        },
    ],
    'interviewPrep': [
      for (final i in plan.interviewPrep)
        {'topic': i.topic, 'source': i.source, 'sampleQuestion': i.sampleQuestion},
    ],
  });
}

/// The full system prompt: persona + candidate context + A2UI/catalog schema.
String buildCoachChatSystemPrompt({
  required CoachPlan plan,
  required Catalog catalog,
}) {
  return PromptBuilder.chat(
    catalog: catalog,
    systemPromptFragments: [
      _persona,
      'CONTEXTO DEL CANDIDATO (CompetencyAssessment):\n'
          '${serializeCoachContext(plan)}',
      PromptFragments.acknowledgeUser(),
      PromptFragments.currentDate(),
      PromptFragments.uiGenerationRestriction(
        prefix: PromptBuilder.defaultImportancePrefix,
      ),
    ],
  ).systemPromptJoined();
}
