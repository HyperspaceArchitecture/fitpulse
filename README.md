# FitPulse AI

FitPulse AI is a premium, cross-platform fitness, recovery, and nutrition
application built with Flutter and Material 3.

## Foundation

- Flutter stable with sound null safety
- Feature-first Clean Architecture
- Riverpod for dependency injection and state management
- GoRouter for declarative navigation
- Material 3 design tokens and reusable glass surfaces
- Persisted Volt Lime and Studio Lilac visual systems
- Responsive layouts for phones, tablets, foldables, web, and desktop
- Backend-agnostic boundaries; no backend SDK is currently installed

## Available screens

- `/` — premium landing experience
- `/sign-in` — validated sign-in presentation
- `/register` — account-creation presentation with consent state
- `/forgot-password` — password-recovery presentation
- `/onboarding` — offline-first fitness profile setup
- `/dashboard` — personalized daily training and recovery command centre
- `/today` — interactive daily-readiness preview
- `/progress` — combined exercise, sleep, nutrition, weight, and non-scale trends

Authentication screens are intentionally marked as previews until a backend is
selected. They validate locally and never transmit credentials.

## Project structure

```text
lib/
├── core/
│   ├── routing/       # Application navigation
│   └── theme/         # Design tokens, themes, and appearance state
├── features/
│   └── theme_preview/ # Feature-scoped presentation code
├── shared/
│   └── widgets/       # Reusable cross-feature components
├── app.dart           # Application composition root
└── main.dart          # Runtime entry point
```

Each future feature owns its domain, data, and presentation layers. Shared
contracts belong in `core`; reusable visual primitives belong in `shared`.

## Development

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

The selected visual system is stored locally and restored at launch. Use the
theme selector on the foundation screen to review Volt Lime and Studio Lilac.
