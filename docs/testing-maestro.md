# Testing E2E con Maestro — Coach de Carrera

E2E de la app Flutter (`apps/mobile`) con [Maestro](https://docs.maestro.dev), corriendo **contra un device Android físico vía adb**. Por política del equipo, este workflow **nunca lanza emuladores AVD** (agotan la RAM de las laptops de desarrollo); el runner falla con instrucciones si no hay un device conectado.

Workstream: [issue #11](https://github.com/keikolatam/dapp-monorepo/issues/11), sobre el vertical slice GenUI del Coach (#3).

## Cómo funciona Maestro con Flutter

Maestro es black-box: no inyecta código Dart ni depende de `pubspec.yaml`. Lee el **árbol de semántica** (accesibilidad) que Flutter expone al sistema operativo:

- Los widgets `Text` exponen su texto automáticamente → se seleccionan por texto (exacto o regex).
- Los `IconButton` exponen su `tooltip` como label de accesibilidad (así tapeamos "Ver versión clásica").
- Para widgets sin texto habría que agregar `Semantics(identifier: …)` (Flutter ≥ 3.19); los flows actuales no lo necesitan.

## Estructura

```
apps/mobile/
├── .maestro/
│   ├── config.yaml              # workspace: descubrimiento de flows, orden, tags
│   └── flows/
│       ├── coach_smoke.yaml     # tag: smoke, coach
│       ├── coach_gaps.yaml      # tag: coach, gaps
│       └── coach_prep_expand.yaml  # tag: coach, prep
└── tool/run_maestro.sh          # runner: exige device físico adb
```

Los selectores son el **texto real de la UI** (en español), tomado de `apps/mobile/lib/main.dart`, `lib/coach/presentation/*.dart` y los labels de dominio (`GapStatus.label`: Cumplido / Parcial / Brecha). Los datos del demo son deterministas (fixtures en `assets/coach/`), verificables con `dart run tool/dump_assessment.dart`: readiness 45 %, Band 8 — Experienced → Band 10 — Thought Leader.

### Flows

| Flow | Qué verifica |
|---|---|
| `coach_smoke` | La app lanza, el AppBar "Keiko · Coach de Carrera (GenUI)" está visible y la superficie A2UI pinta el header de readiness ("45 % preparación…", "Band 10 — Thought Leader"). Usa `extendedWaitUntil` porque la superficie GenUI se construye async. |
| `coach_gaps` | Navega a la vista clásica (tooltip "Ver versión clásica"), scrollea las cards de brechas y asserta los tres chips de estado: **Cumplido**, **Parcial** y **Brecha**. |
| `coach_prep_expand` | En la vista clásica, scrollea hasta el primer topic de interview prep ("GitOps con Argo CD…"), expande el `ExpansionTile` y asserta la pregunta de ejemplo (el texto con ❓). |

Nota sobre selectores: en Maestro el texto es un regex que debe matchear el texto completo del elemento. Por eso el smoke usa `.*Keiko · Coach de Carrera.*GenUI.*` (los paréntesis de "(GenUI)" son metacaracteres) y el chip `Brecha` no colisiona con el título "Brechas de competencia…".

## Requisitos

1. **Maestro CLI** (sin sudo, queda en `$HOME/.maestro`):
   ```bash
   make dev-mobile-maestro-install
   # o: curl -fsSL "https://get.maestro.mobile.dev" | bash
   ```
2. **Device físico** con depuración USB habilitada y huella RSA aceptada (`adb devices` debe listarlo como `device`).
3. **La app instalada** en el device (`com.keikolatam.keiko_app`, build debug):
   ```bash
   cd apps/mobile && flutter install -d <serial>
   ```

## Cómo correr

```bash
make dev-mobile-maestro-test     # los 3 flows, en el orden del config.yaml
make dev-mobile-maestro-smoke    # solo tag smoke
make dev-mobile-maestro-analyze  # + AI test analysis (ver abajo)
make dev-mobile-maestro-studio   # Maestro Studio (inspector interactivo en el browser)
```

El runner (`apps/mobile/tool/run_maestro.sh`) acepta:

- `MAESTRO_DEVICE=<serial>` para elegir device si hay varios (default: el primero de `adb devices`).
- `MAESTRO_TAGS=smoke` → `--include-tags`.
- `MAESTRO_ANALYZE=1` → `--analyze`.
- Un argumento posicional para correr un flow puntual: `tool/run_maestro.sh .maestro/flows/coach_smoke.yaml`.

## AI test analysis

`maestro test --analyze` (beta) genera insights con IA sobre el resultado (regresiones visuales, errores de ortografía, problemas de layout) y produce un reporte HTML. Requiere autenticarse contra Maestro Cloud (cuenta gratuita):

```bash
maestro login            # o export MAESTRO_CLOUD_API_KEY=<key>
make dev-mobile-maestro-analyze
```

Las variables `MAESTRO_CLI_AI_KEY` / `MAESTRO_CLI_AI_MODEL` de versiones viejas ya no se usan. Para silenciar la notificación del análisis: `export MAESTRO_CLI_ANALYSIS_NOTIFICATION_DISABLED=true`.

## Maestro Studio

`maestro studio` abre una UI web conectada al device vía adb para inspeccionar el árbol de semántica, probar selectores y grabar comandos. Útil para depurar un selector antes de fijarlo en un flow.

## Estado de verificación (honesto)

| Qué | Estado |
|---|---|
| Sintaxis YAML de config + 3 flows | ✅ Validada (parser YAML; sintaxis según docs oficiales de Maestro 2.6.0) |
| `coach_smoke` contra Xiaomi 25028RN03L (físico) | ⏳ Pendiente — requiere la app instalada en el device |
| `coach_gaps` contra Xiaomi (físico) | ⏳ Pendiente |
| `coach_prep_expand` contra Xiaomi (físico) | ⏳ Pendiente |
| AI test analysis (`--analyze`) | ⏳ No ejecutado — requiere `maestro login` (cuenta Maestro Cloud) |
| Emuladores AVD | 🚫 Fuera de alcance por política (solo device físico) |

> Actualizar esta tabla cuando los flows corran contra el device real: fecha, serial, resultado por flow.
