/// Application — the interview-prep knowledge base.
///
/// Topics are grounded in real study material the candidate owns, processed
/// offline with Microsoft markitdown into Markdown:
///   • The Kubernetes Book (Poulton, 2024)
///   • Argo CD: Up & Running
/// Each entry cites its source so the generated interview prep is auditable —
/// not invented. (The book text itself is NOT bundled; only the topic index.)
library;

import '../domain/competency_assessment.dart';

class KnowledgeTopic {
  const KnowledgeTopic({
    required this.topic,
    required this.source,
    required this.why,
    required this.sampleQuestion,
    required this.signals,
  });

  final String topic;
  final String source;
  final String why;
  final String sampleQuestion;

  /// Profile tokens that make this topic relevant for the candidate.
  final List<String> signals;

  InterviewPrepItem toPrepItem() => InterviewPrepItem(
        topic: topic,
        why: why,
        source: source,
        sampleQuestion: sampleQuestion,
      );
}

/// Curated topic index. Ordered roughly by interview weight for a senior SRE.
const List<KnowledgeTopic> sreKnowledgeBase = [
  KnowledgeTopic(
    topic: 'GitOps con Argo CD: sync waves, hooks y App-of-Apps',
    source: 'Argo CD: Up & Running — Cap. 4 (Synchronizing) & Cap. 9 (At Scale)',
    why: 'Vos desplegaste upgrades de MAS con ArgoCD en IBM. Band 10 espera '
        'que expliques orquestación a escala, no solo "hice sync".',
    sampleQuestion: '¿Cómo coordinás el orden de despliegue de 30 microservicios '
        'dependientes con Argo CD sin acoplarlos, y qué pasa si una sync wave falla?',
    signals: ['argocd', 'gitops', 'helm'],
  ),
  KnowledgeTopic(
    topic: 'ApplicationSets y multi-cluster a escala',
    source: 'Argo CD: Up & Running — Cap. 8 (Multiple Clusters) & ApplicationSets',
    why: 'Administraste OpenShift en múltiples clusters AWS. El salto a Band 10 '
        'es diseñar la estrategia multi-cluster, no operarla.',
    sampleQuestion: '¿Cómo generarías una Application por cada cluster/región con '
        'un solo ApplicationSet y cómo manejás drift entre entornos?',
    signals: ['openshift', 'kubernetes', 'multi-cloud', 'aws'],
  ),
  KnowledgeTopic(
    topic: 'RBAC y multi-tenancy en Argo CD / Kubernetes',
    source: 'Argo CD: Up & Running — Cap. 7 (RBAC); The Kubernetes Book — RBAC',
    why: 'Seguridad y least-privilege son señal de madurez senior (alineado con '
        'tu trabajo de hardening en Dojo OS).',
    sampleQuestion: '¿Cómo das acceso self-service a equipos de producto sin que '
        'puedan tocar infra compartida?',
    signals: ['rbac', 'security', 'openshift'],
  ),
  KnowledgeTopic(
    topic: 'Modelo de Pods, Deployments y self-healing',
    source: 'The Kubernetes Book (Poulton 2024) — Pods, Deployments',
    why: 'Base no-negociable. Band 10 lo asume; te evalúan los bordes '
        '(probes, PodDisruptionBudgets, rollout strategies).',
    sampleQuestion: '¿Diferencia entre liveness, readiness y startup probes, y un '
        'caso donde una mala readiness probe causó un outage?',
    signals: ['kubernetes', 'openshift'],
  ),
  KnowledgeTopic(
    topic: 'Golden signals, SLOs y error-budget burn rate',
    source: 'Google SRE Workbook (referencia) + tu stack Instana/Grafana',
    why: 'El rubric Band 10 mide MTTR, Availability y % incidents detected by '
        'monitoring. Hay que razonar en error budgets, no en CPU.',
    sampleQuestion: '¿Cómo definís una alerta multi-window multi-burn-rate y por '
        'qué es mejor que alertar sobre un umbral fijo de latencia?',
    signals: ['instana', 'grafana', 'slo', 'mttr', 'observability'],
  ),
  KnowledgeTopic(
    topic: 'Incident command y postmortems sin culpa',
    source: 'Práctica SRE + tu experiencia con PagerDuty / On Call Manager',
    why: 'Band 10 = "leads incident response" y "transforms how the org learns '
        'from failures". Es comportamiento + comunicación, no solo técnico.',
    sampleQuestion: 'Contame un incidente P0 que lideraste: ¿cómo estructuraste el '
        'postmortem para que produjera un cambio sistémico, no un parche?',
    signals: ['pagerduty', 'incident response', 'mttr'],
  ),
];

/// Returns the prep items whose signals intersect the candidate's corpus,
/// capped so the plan stays focused (Microsoft's "ended with 5, not 100").
List<InterviewPrepItem> interviewPrepFor(String evidenceCorpus, {int max = 5}) {
  final relevant = sreKnowledgeBase
      .where((t) => t.signals.any(evidenceCorpus.contains))
      .toList();
  final chosen = (relevant.isEmpty ? sreKnowledgeBase : relevant).take(max);
  return chosen.map((t) => t.toPrepItem()).toList();
}
