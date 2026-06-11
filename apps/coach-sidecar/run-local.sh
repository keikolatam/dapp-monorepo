#!/usr/bin/env bash
# Levanta agentic-core como gateway LLM local del Coach (ADR-0003).
#
#   NVIDIA_API_KEY=... ./run-local.sh
#
# - La key vive SOLO en el env del servicio: este script la inyecta en un
#   studio_config.json EFÍMERO (XDG_RUNTIME_DIR, chmod 600, borrado al salir).
#   Jamás se escribe dentro del repo ni la ve la app Flutter.
# - Las personas de este directorio (agents/*.yaml) se copian al runtime dir
#   y agentic-core las sirve por ws://localhost:8080/ws.
# - Sin minikube ni docker: entrypoint python directo con uv (el bootstrap
#   degrada a stubs in-memory si no hay redis/postgres/falkordb).
set -euo pipefail

AGENTIC_CORE_DIR="${AGENTIC_CORE_DIR:-$HOME/Documentos/GitHub/chimeranext/better-microservices/.claude/worktrees/nim-nemotron/services/agentic-core}"
SIDECAR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/keiko-coach-sidecar"
NIM_BASE_URL="${NIM_BASE_URL:-https://integrate.api.nvidia.com/v1}"
NIM_MODEL="${NIM_MODEL:-nvidia/nemotron-3-ultra-550b-a55b}"

if [[ -z "${NVIDIA_API_KEY:-}" ]]; then
  echo "ERROR: exportá NVIDIA_API_KEY antes de correr este script." >&2
  exit 1
fi
if [[ ! -d "$AGENTIC_CORE_DIR" ]]; then
  echo "ERROR: no encuentro agentic-core en $AGENTIC_CORE_DIR (seteá AGENTIC_CORE_DIR)." >&2
  exit 1
fi

umask 077
rm -rf "$RUNTIME_DIR"
mkdir -p "$RUNTIME_DIR/agents"
cp "$SIDECAR_DIR"/agents/*.yaml "$RUNTIME_DIR/agents/"

# studio_config.json en el parent del personas_dir (contrato de http_api.py).
# python para serializar la key sin riesgos de escaping/inyección en el JSON.
python3 - "$RUNTIME_DIR/studio_config.json" "$NIM_BASE_URL" "$NIM_MODEL" <<'PYEOF'
import json, os, sys
path, base_url, model = sys.argv[1:4]
cfg = {
    "onboarded": True,
    "providers": [{
        "name": "NVIDIA NIM",
        "type": "openai",
        "model": model,
        "baseUrl": base_url,
        "apiKey": os.environ["NVIDIA_API_KEY"],
        "status": "active",
    }],
    "default_agent": None,
}
with open(path, "w") as f:
    json.dump(cfg, f)
os.chmod(path, 0o600)
PYEOF
trap 'rm -f "$RUNTIME_DIR/studio_config.json"' EXIT

echo "Gateway: ws://localhost:8080/ws — personas: $(ls "$RUNTIME_DIR/agents")"
echo "Para el Xiaomi por USB: adb reverse tcp:8080 tcp:8080"

cd "$AGENTIC_CORE_DIR"
exec env AGENTIC_MODE=standalone \
  AGENTIC_PERSONAS_DIR="$RUNTIME_DIR/agents" \
  uv run python -m agentic_core.runtime
