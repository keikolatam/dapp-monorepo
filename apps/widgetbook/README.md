# apps/widgetbook

Catálogo de componentes Flutter ([Widgetbook](https://pub.dev/packages/widgetbook)) para `packages/keiko_ui` — stories organizadas con la taxonomía Atomic Design (atoms → molecules → organisms) sobre Material 3, más una sección `theme` con las paletas. Convención compartida con vertivo/altrupets/aduanext (`apps/widgetbook`).

## Correr local

```bash
flutter pub get
flutter run -d chrome
```

O servir el build estático:

```bash
flutter build web
python3 -m http.server 8787 --directory build/web
# http://127.0.0.1:8787
```

## Estructura

- `lib/main.dart` — `Widgetbook.material` con `MaterialThemeAddon` (light/dark del `MaterialTheme` de keiko_ui).
- `lib/stories/atoms.dart` — KeikoSectionTitle, KeikoPercentBadge, KeikoStatusDot, KeikoTagChip.
- `lib/stories/molecules.dart` — KeikoProgressMeter, KeikoStepTile.
- `lib/stories/organisms.dart` — KeikoMetricHeaderCard.
- `lib/stories/theme.dart` — rampas tonales de `BrandColors` y roles de `KeikoSemanticColors`.

Manual approach (sin codegen): al agregar un componente a `keiko_ui`, espejar su story en la carpeta atómica correspondiente.

> `GapCard` (catálogo GenUI del Coach) vive en `apps/mobile/lib/coach/presentation/coach_catalog.dart` y queda fuera de este catálogo: `keiko_app` arrastra dependencias sin soporte web (jitsi). Si se promueve a `keiko_ui`, agregar su story en `organisms`.

## Deploy (Vercel)

`vercel.json` apunta el output a `build/web`. El proyecto se conecta desde el dashboard de Vercel con root directory `apps/widgetbook` (requiere Flutter en el build image o un build prearmado). El deploy es un gate manual — no se automatiza desde CI todavía.
