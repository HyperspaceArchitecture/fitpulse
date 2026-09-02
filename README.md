# FitPulse AI

FitPulse AI is a premium, cross-platform fitness, recovery, and nutrition
application built with Flutter and Material 3.

## Foundation

- Flutter stable with sound null safety
- Feature-first Clean Architecture
- Riverpod for dependency injection and state management
- GoRouter for declarative navigation
- Material 3 design tokens and reusable glass surfaces
- Persisted Graphite, Studio Lilac, and Soft Arcade visual systems
- Responsive layouts for phones, tablets, foldables, web, and desktop
- Persistent mobile navigation across Today, Train, Food, Progress, and Coach
- Backend-agnostic repository and service boundaries; no Firebase dependency
- Offline persistence for profile, appearance, workouts, nutrition, and progress
- Deny-by-default production admin access

## Available screens

- `/` — quiet startup with avatar, member name, rotating quote, growth line, and workout momentum needle
- `/welcome` — premium product introduction and authentication entry
- `/sign-in` — validated sign-in presentation
- `/register` — account-creation presentation with consent state
- `/forgot-password` — password-recovery presentation
- `/onboarding` — offline-first fitness profile setup
- `/dashboard` — personalized daily training and recovery command centre
- `/workouts` — structured workout plan and movement prescription
- `/workouts/session` — live set, rest timer, illustrated form guidance, and completion engine
- `/coach` — private offline coaching conversation and safety fallback
- `/nutrition` — food-photo diary with editable calorie drafts, macros, and hydration
- `/today` — interactive daily-readiness preview
- `/progress` — saved check-ins plus detailed exercise, sleep, nutrition, weight, and non-scale trends
- `/settings` — avatar selection and local privacy controls
- `/admin` — debug operations preview; production access is denied until server roles exist

Authentication screens are intentionally marked as previews until a non-Firebase
backend is selected. They validate locally and never transmit credentials. The
admin route is not client-unlockable in release builds: a future trusted server
must verify its role claim.

## Project structure

```text
lib/
├── core/
│   ├── routing/       # Application navigation
│   └── theme/         # Design tokens, themes, and appearance state
├── features/
│   ├── admin/         # Production-safe admin shell
│   ├── coach/         # Offline coaching service and conversation
│   ├── nutrition/     # Daily nutrition persistence and UI
│   ├── progress/      # Combined and detailed progress tracking
│   ├── settings/      # Avatar and privacy controls
│   └── workout/       # Plans, history, engine, and exercise media
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
theme selector to review Graphite, Studio Lilac, and Soft Arcade.

Append `?preview=phone` before the hash route when reviewing the web build to
render every screen in a consistent 390 × 844 phone canvas.

Dish photos can be captured with the camera or selected from the gallery. The
offline experience creates an explicitly low-confidence, editable nutrition
draft because a single image cannot measure portion mass, hidden ingredients,
or cooking oils. Both the compressed thumbnail and corrected diary values stay
on the device.

## Release boundary

The repository is a complete offline-first product slice. Cross-device accounts,
server-side AI, subscriptions, push delivery, analytics, and administrator role
claims require a separately selected backend. They are deliberately not faked
in client code. Repository and service interfaces isolate those integrations so
they can be added without replacing the feature UI.
