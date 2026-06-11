/// Presentation — prompt pieces for the Coach chat over agentic-core.
///
/// Two halves, two homes (ADR-0003: agentic-core is the LLM gateway):
/// - The PERSONA system prompt (Coach persona + A2UI/catalog schemas from
///   genui's [PromptBuilder.chat]) lives server-side in
///   `apps/coach-sidecar/agents/keiko-coach.yaml`, regenerated with
///   `flutter test tool/generate_coach_persona.dart`.
/// - The CANDIDATE context ([serializeCoachContext]) is per-user/runtime
///   data, so the app prepends it to the first chat turn instead.
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
- El primer mensaje del usuario incluye un bloque "CONTEXTO DEL CANDIDATO"
  en JSON: basate en esos datos reales (brechas, readiness, roadmap); no
  inventes datos del candidato.
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

/// The persona system prompt: Coach persona + A2UI/catalog schemas.
/// Consumed by `tool/generate_coach_persona.dart`; deliberately excludes
/// per-user context and the current date (the persona file is static).
String buildCoachPersonaSystemPrompt({required Catalog catalog}) {
  return PromptBuilder.chat(
    catalog: catalog,
    systemPromptFragments: [
      _persona,
      PromptFragments.acknowledgeUser(),
      PromptFragments.uiGenerationRestriction(
        prefix: PromptBuilder.defaultImportancePrefix,
      ),
    ],
  ).systemPromptJoined();
}
