/// Generador de la persona del Coach para agentic-core (ADR-0003).
///
/// Escribe `apps/coach-sidecar/agents/keiko-coach.yaml` con el system prompt
/// completo (persona + schemas A2UI del catálogo Keiko vía PromptBuilder.chat).
/// Se corre como test de Flutter porque el catálogo importa dart:ui:
///
///   cd apps/mobile && flutter test tool/generate_coach_persona.dart
///
/// Correlo de nuevo cada vez que cambie el catálogo (coach_catalog.dart) o la
/// persona (coach_chat_prompt.dart), y commiteá el yaml regenerado.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:keiko_app/coach/presentation/coach_catalog.dart';
import 'package:keiko_app/coach/presentation/coach_chat_prompt.dart';

void main() {
  test('genera apps/coach-sidecar/agents/keiko-coach.yaml', () {
    final prompt =
        buildCoachPersonaSystemPrompt(catalog: buildCoachCatalog());
    // Bloque literal YAML: cada línea del prompt indentada 2 espacios.
    final indented = prompt
        .split('\n')
        .map((l) => l.trim().isEmpty ? '' : '  $l')
        .join('\n');

    final yaml = '''
# GENERADO por apps/mobile/tool/generate_coach_persona.dart — NO editar a mano.
# Regenerar con: cd apps/mobile && flutter test tool/generate_coach_persona.dart
#
# Persona del Coach de Carrera para agentic-core (ADR-0003: el gateway LLM).
# model_config sigue el formato del provider nvidia de agentic-core (PR #74
# de better-microservices); la API key vive en el ENV del servicio
# (NVIDIA_API_KEY), jamás en este archivo ni en la app Flutter.
name: keiko-coach
role: "Coach de Carrera"
description: "Coach de Carrera de Keiko: brechas de competencia, roadmap e interview prep, renderizado como GenUI (A2UI)"
graph_template: react
tools: []
model_config:
  provider: nvidia
  model: nvidia/nemotron-3-ultra-550b-a55b
  temperature: 0.6
  max_tokens: 8192
  # api_key_env: NVIDIA_API_KEY        # default del provider nvidia
  fallback:
    - provider: nvidia
      model: nvidia/nemotron-3-super-120b-a12b
slo_targets:
  latency_p99_ms: 30000
  success_rate: 0.99
system_prompt: |
$indented
''';

    final out = File('../coach-sidecar/agents/keiko-coach.yaml')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(yaml);
    stdout.writeln('Escrito ${out.path} (${yaml.length} bytes)');
    expect(out.existsSync(), isTrue);
  });
}
