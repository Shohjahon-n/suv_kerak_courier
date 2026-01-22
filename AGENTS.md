# Agent Guidelines

## Purpose
- This document guides automated agents working in this repo.
- Prefer existing patterns; keep changes small and consistent.

## Project Overview
- Flutter courier app targeting Android/iOS/web/desktop.
- State management: `flutter_bloc` + `Equatable` for state classes.
- Dependency injection: `get_it` via `lib/core/di/service_locator.dart`.
- Networking: `dio` with `talker` logging.
- Localization: ARB files in `lib/l10n/`, generated `app_localizations*.dart`.

## Project Structure
- Entry point: `lib/main.dart`.
- App wiring + router: `lib/app/`.
- Shared services/utilities: `lib/core/` (network, storage, theme, localization, logging, security).
- Features live in `lib/features/<feature>/` (home uses data/domain/presentation).
- Reusable UI: `lib/core/widgets/` and `lib/shared/widgets/`.
- Platform targets: `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`.

## Generated Files (Do Not Edit)
- `*.g.dart` from `json_serializable`.
- `lib/l10n/app_localizations*.dart` from `flutter gen-l10n`.

## Build, Lint, and Test Commands
**Bootstrap**
- `flutter pub get`
- `flutter clean` (only when toolchains are confused)

**Run**
- `flutter run`
- `flutter run -d <device_id>`

**Static Analysis + Formatting**
- `flutter analyze`
- `dart format .`
- `dart format lib test` (faster for targeted formatting)

**Code Generation**
- `dart run build_runner build --delete-conflicting-outputs`
- `dart run build_runner watch --delete-conflicting-outputs`
- `flutter gen-l10n` (after editing ARB files)

**Tests**
- `flutter test`
- `flutter test test/path/to/widget_test.dart` (single file)
- `flutter test --plain-name "test name"` (single test)
- `flutter test -r expanded` (more verbose output)
- `flutter test --update-goldens` (when adding goldens)

**Release Builds**
- `flutter build apk`
- `flutter build ios` (requires macOS)

## Import Style
- Order imports: `dart:` first, then `package:`, then relative.
- Separate import groups with a blank line.
- Use `package:suv_kerak_courier/l10n/app_localizations.dart` for l10n.
- Prefer relative imports for other app modules to match current files.
- Keep imports sorted alphabetically within each group.

## Formatting and Layout
- Run `dart format` before committing.
- Use 2-space indentation; rely on trailing commas for formatter output.
- Prefer `const` constructors for widgets and `const` collections.
- Use `final` for locals; `late final` for init-state values.
- Keep widgets small; move reusable pieces to `core/widgets` or `shared/widgets`.

## Naming Conventions
- Files: `lower_snake_case.dart`.
- Types: `UpperCamelCase` (classes, enums, typedefs).
- Members/variables: `lowerCamelCase`.
- Use enum names like `HomeStatus` and `HomeMessageKey`.
- Name Cubits/Blocs as `<Feature>Cubit` with `<Feature>State`.

## Types and Null Safety
- Avoid `dynamic`; use `Map<String, dynamic>` for JSON.
- Prefer explicit types for public fields and method signatures.
- Use `Future<void>` for async methods that do not return values.
- Avoid `!` unless the value is guaranteed; prefer null-aware operators.
- In async UI flows, check `context.mounted` before using `BuildContext`.

## Dependency Injection
- Register singletons/factories in `setupServiceLocator`.
- Access dependencies via `getIt<T>()` in cubits and app wiring.
- For tests, call `resetServiceLocator()` to clear registrations.

## State Management (Bloc/Cubit)
- Keep state classes immutable; use `copyWith`.
- States should extend `Equatable` and override `props`.
- Emit loading/success/failure status enums for networked flows.
- Keep side effects inside cubits; UI should only react to state.

## Routing
- Routing uses `go_router` and is defined in `lib/app/app_router.dart`.
- Prefer `context.go`/`context.push` instead of `Navigator`.
- Keep route names/paths centralized in the router.

## Networking and Data
- Use the shared `Dio` instance from `getIt` (see `DioClient`).
- Base URL comes from `AppConstants.apiBaseUrl`.
- Log network errors with `Talker` and include stack traces.
- When parsing JSON, use safe conversions (`int.tryParse`, etc.).
- Prefer `json_serializable` for new models.

## Error Handling and Logging
- Catch `DioException` separately from generic exceptions.
- Use `ErrorHandler.handleError` or `ErrorHandlingMixin` for UI surfaces.
- Avoid `print`; use `Talker` (`AppLogger`) for structured logs.
- Provide user-friendly messages; fallback to generic error text.

## Localization
- Add strings only to `lib/l10n/*.arb`; keep keys snake_case.
- Re-run `flutter gen-l10n` after editing ARB files.
- Use `AppLocalizations.of(context)` for all user-facing text.
- Keep locale files in sync; add the same keys for each locale.

## Themes and UI
- Theme source: `lib/core/theme/app_theme.dart`.
- Use `ThemeCubit` to toggle light/dark; do not hardcode colors.
- Prefer existing spacing helpers (`ResponsiveSpacing`, `AdaptiveGrid`).
- Shared UI bits belong in `core/widgets` or `shared/widgets`.

## Assets and Config
- Declare new assets in `pubspec.yaml` under `flutter/assets`.
- Keep asset paths lower_snake_case; prefer `assets/images/`.
- Update `flutter_launcher_icons` and `flutter_native_splash` configs when changing icons.

## Security and Platform Concerns
- Security flows are mediated by `SecurityGate` and `SecurityCubit`.
- Update `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`
  when adding platform permissions.

## Testing Guidelines
- Place tests under `test/` mirroring `lib/` structure.
- Name tests `*_test.dart`.
- Prefer unit tests for cubits/repositories, widget tests for UI flows.

## Repo/PR Notes
- Commit messages: clear, imperative, optional prefixes (`feat:`, `fix:`).
- PRs should include summary, testing notes, and screenshots for UI changes.

## Cursor / Copilot Rules
- No `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` found.

## When in Doubt
- Follow existing patterns in nearby files.
- Ask for clarification when behavior changes are ambiguous.
- Keep diffs focused and avoid reformatting unrelated code.
