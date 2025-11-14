# Architecture Migration Plan

## Goals

- Move from the current Bloc-heavy presentation layer to Riverpod while keeping the business rules testable and UI-agnostic.
- Enforce a clean architecture split so that prayer/profile/theming features grow independently and stay maintainable.
- Provide room for the upcoming profile onboarding, prayer tracking (including optional qada mode), theme customization, and alternate city visualisations.
- Keep existing production-ready widgets (e.g., main prayer circle) reusable outside the home screen.

## Target Layering

```
lib/
├── app/                # App entry, router, theme, localization wiring
├── presentation/       # Widgets + Riverpod consumers (feature-based folders)
├── application/        # Use cases + controllers (pure Dart, test-friendly)
├── domain/             # Entities, value objects, repository contracts
├── infrastructure/     # Data sources (Hive, shared_preferences, notifications, APIs)
└── shared/             # Cross-cutting utils (date helpers, validators, localization helpers)
```

### Layer contracts

- **Domain** exposes `Profile`, `PrayerRecord`, `TrackedCity`, `ThemeProfile`, plus repository interfaces.
- **Application** holds use-cases such as `GetActiveLocation`, `MarkPrayerCompleted`, `ToggleQadaMode`, `GetPrayerWidgetData`.
- **Infrastructure** implements the repositories by composing
  - Hive boxes (profile, historical prayers, qada records)
  - SharedPreferences (lightweight feature toggles, onboarding flag)
  - Local notifications (daily reminders, optional extra prayers)
  - Existing geolocation/geocoding services.
- **Presentation** should only depend on Application layer through Riverpod providers.

## Riverpod Structure

- `ProviderScope` wrapped in `main.dart`.
- **Core providers**
  - `appRouterProvider`, `appThemeProvider`, `localeProvider`.
  - `locationPermissionProvider` for GPS access state.
- **Feature providers** (all `AutoDisposeNotifier` or `StateNotifier` based):
  - `TrackedCitiesController` → orchestrates GPS/manual cities and exposes summaries for alternate layout.
  - `PrayerSummaryController` → feeds the main prayer circle widget with timers and handles animations.
  - `ProfileController` → handles onboarding fields (name, age, gender), prayer preferences, reminders.
  - `PrayerLogController` → stores individual fard/sunnah/nafl entries, calculates qada backlog, exports table data on demand.
  - `ThemeController` → holds theme palette set, accent overrides, persists per profile.

## Feature Rollout Plan

1. **Migration scaffolding**

   - Introduce the folder layout, create placeholder providers/controllers that bridge to existing Bloc logic to avoid regressions.
   - Gradually replace `BlocBuilder`/`BlocListener` in `homeContent.dart` and other screens with `ConsumerWidget` / `HookConsumerWidget`.

2. **Multi-city UI redesign**

   - Move manual city list to its own presentation module and route (e.g., `CitiesDashboardScreen`).
   - Keep home screen minimal: show only the main prayer circle + compact selector entry point.
   - Provide a reusable `PrayerCircleWidget` that receives `PrayerSummary` data via provider so it can be embedded elsewhere (including exported widget kits as requested).

3. **Profile and onboarding**

   - On first launch, show a profile creation flow (modal or dedicated page) capturing personal info and prayer style preferences.
   - Persist via `ProfileRepository` (Hive box) and expose via `ProfileController`.
   - Use the profile to preconfigure reminders, qada mode default, and theme selection.

4. **Prayer tracking & qada mode**

   - Define domain entities `PrayerRecord` and `QadaRecord`.
   - `PrayerLogController` writes to Hive and exposes filters for daily/weekly history.
   - Optional qada mode toggle stored in profile. When enabled, UI shows backlog table with export button (CSV/PDF using `printing` or `csv` package).
   - Integrate notification scheduling via a dedicated infrastructure service to alert for optional extra prayers the user subscribed to.

5. **Theming**

   - Build `ThemeProfile` entity with base palette + accent overrides.
   - Provide predefined themes (classic, night, minimal) and allow per-profile customization (accent color, typography weight) while keeping main motif consistent.
   - `ThemeController` updates a `ThemeData` provider consumed by `MaterialApp`.

6. **Exports & widgets**
   - Extract the existing home prayer circle into `presentation/widgets/prayer_circle.dart` with pure data inputs.
   - Provide a mini-package (or `WidgetBook` style gallery) inside `lib/presentation/widgets/exports/` so screens can embed the circle or qada table.
   - Implement export services for qada table (CSV/PDF) under `infrastructure/exports` triggered through `PrayerLogController`.

## Migration Phases & Dependencies

1. **Phase 0** – Add Riverpod and folder scaffolding without altering behavior. Keep Bloc running in parallel and adapter providers bridging to existing states.
2. **Phase 1** – Move location/prayer state management to Riverpod. Delete Bloc counterparts once parity tests pass.
3. **Phase 2** – Introduce profile onboarding + stored preferences.
4. **Phase 3** – Implement prayer tracking, qada mode, exports, and optional reminders.
5. **Phase 4** – Theme customization + final UI polish for multi-city dashboard.

Each phase should include:

- Unit tests for use-cases.
- Golden/widget tests for major presentation widgets.
- README update summarizing new capabilities.

## Testing & Tooling

- Continue to use `flutter test` for unit/widget coverage.
- Add `melos` or simple custom scripts later if modules grow.
- Maintain localization workflow with `flutter gen-l10n` and ensure new screens fetch localized strings from ARB files.
