#!/usr/bin/env bash
# Corre los flows Maestro del Coach contra un device físico conectado por adb.
#
# REGLA: este script NUNCA lanza emuladores AVD ni VMs. Si no hay un device
# adb conectado y autorizado, falla con instrucciones.
#
# Uso:
#   tool/run_maestro.sh                  # todos los flows del workspace
#   tool/run_maestro.sh flows/coach_smoke.yaml   # un flow puntual
#
# Variables:
#   MAESTRO_DEVICE   serial adb explícito (default: primer device conectado)
#   MAESTRO_TAGS     tags a incluir, ej. "smoke" (maestro --include-tags)
#   MAESTRO_ANALYZE  =1 agrega --analyze (AI test analysis; requiere
#                    `maestro login` o MAESTRO_CLOUD_API_KEY)
set -euo pipefail

MOBILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$PATH:$HOME/.maestro/bin:$HOME/Android/Sdk/platform-tools"

if ! command -v maestro >/dev/null 2>&1; then
  echo "ERROR: maestro CLI no encontrado." >&2
  echo "Instalalo (sin sudo, queda en \$HOME/.maestro):" >&2
  echo '  curl -fsSL "https://get.maestro.mobile.dev" | bash' >&2
  exit 1
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "ERROR: adb no encontrado (esperado en ~/Android/Sdk/platform-tools)." >&2
  exit 1
fi

DEVICE="${MAESTRO_DEVICE:-$(adb devices | awk 'NR>1 && $2 == "device" {print $1; exit}')}"
if [ -z "$DEVICE" ]; then
  echo "ERROR: no hay device adb conectado y autorizado." >&2
  echo "Conectá el device físico por USB, habilitá depuración USB y aceptá" >&2
  echo "la huella RSA. Este script NO lanza emuladores." >&2
  adb devices >&2
  exit 1
fi

APP_ID="$(sed -n 's/^appId: //p' "$MOBILE_DIR/.maestro/flows/coach_smoke.yaml" | head -1)"
if ! adb -s "$DEVICE" shell pm list packages 2>/dev/null | grep -q "^package:${APP_ID}$"; then
  echo "ERROR: ${APP_ID} no está instalado en ${DEVICE}." >&2
  echo "Instalalo primero, p. ej.: (cd apps/mobile && flutter install -d ${DEVICE})" >&2
  exit 1
fi

ARGS=(test --device "$DEVICE")
if [ -n "${MAESTRO_TAGS:-}" ]; then
  ARGS+=(--include-tags "$MAESTRO_TAGS")
fi
if [ "${MAESTRO_ANALYZE:-0}" = "1" ]; then
  ARGS+=(--analyze)
fi

TARGET="${1:-$MOBILE_DIR/.maestro/}"
echo "maestro ${ARGS[*]} $TARGET  (device: $DEVICE)"
exec maestro "${ARGS[@]}" "$TARGET"
