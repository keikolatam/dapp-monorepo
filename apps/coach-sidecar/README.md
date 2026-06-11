# coach-sidecar — gateway LLM del Coach de Carrera (ADR-0003)

Primer ladrillo del sidecar del ADR-0003: **la app Flutter nunca habla con el
LLM directamente**. El flujo es:

```
apps/mobile (Flutter) ──WebSocket A2UI──▶ agentic-core ──HTTPS──▶ NVIDIA NIM (nemotron)
        KEIKO_AGENT_WS                     NVIDIA_API_KEY
        (sin secretos)                     (solo en el env del servicio)
```

Este directorio versiona lo que es de Keiko: las **personas** que agentic-core
sirve y el script para correr el gateway localmente. El runtime de
agentic-core vive en `chimeranext/better-microservices` (no se forkea).

## Correr el gateway local

```bash
export NVIDIA_API_KEY=<key de build.nvidia.com>
./run-local.sh
```

Levanta `ws://localhost:8080/ws` con las personas de `agents/`. La key se
inyecta en un `studio_config.json` efímero fuera del repo (`XDG_RUNTIME_DIR`,
permisos 600, borrado al salir) porque el WS proxy de agentic-core lee el
provider de ahí; jamás se commitea ni llega a la app.

Requisitos: `uv` y un checkout de agentic-core con el provider nvidia
(PR #74 de better-microservices); ruta configurable con `AGENTIC_CORE_DIR`.
Sin minikube ni docker: entrypoint python directo (el bootstrap degrada a
stubs in-memory si no hay redis/postgres/falkordb).

## Correr la app contra el gateway

```bash
cd ../mobile
flutter run --dart-define=KEIKO_AGENT_WS=ws://localhost:8080/ws
```

Para un device físico por USB (Xiaomi), el localhost del teléfono debe llegar
al host:

```bash
adb reverse tcp:8080 tcp:8080
```

Sin `KEIKO_AGENT_WS` la página de chat muestra un estado vacío con la
instrucción; si el gateway no responde, el error queda como mensaje en el
chat (no se rompe).

## Personas

`agents/keiko-coach.yaml` es **generado** — el `system_prompt` embebe la
persona del Coach más los schemas A2UI del catálogo GenUI de Keiko
(GapCard, etc.). Regenerar cuando cambie el catálogo o la persona:

```bash
cd ../mobile && flutter test tool/generate_coach_persona.dart
```

`model_config` declara `provider: nvidia`, `nemotron-3-ultra` con fallback
`super-120b` (formato del provider nvidia de agentic-core).

## Evals: dónde enganchar

Cada turno del chat queda trazado del lado servicio — ahí es donde un harness
de evals (hamel.dev/evals, rubrics estilo LangChain) debe leer, sin tocar la
app:

- **Langfuse**: el WS handler (`src/agentic_core/adapters/primary/http_api.py`,
  `websocket_handler`) registra cada generación con `record_generation`
  (modelo, tokens, `session_id`, `persona_id`). Se habilita con las env
  `AGENTIC_OBSERVABILITY__LANGFUSE_*` del servicio (ver
  `src/agentic_core/config/settings.py`).
- **OpenTelemetry + structlog**: `bootstrap()` inicializa `otel_adapter` y
  logging estructurado; cada request WS queda en los logs del proceso
  (`run-local.sh` los deja en stdout).

El punto de enganche recomendado: consumir las generaciones desde Langfuse
(input = persona + content del turno, output = stream completo) y correr las
rúbricas offline contra pares (prompt, A2UI emitido). **No** se construyó el
framework de evals aquí — solo queda documentado el seam.

## Limitaciones actuales

- El WS proxy de agentic-core arma cada turno como `system + human` sin
  memoria de sesión server-side; la app compensa enviando el historial
  reciente dentro del content del turno.
- El `model_config` de la persona todavía no es usado por el WS proxy (usa el
  provider del `studio_config.json`); queda declarado para cuando el sidecar
  use el pipeline completo de personas.
