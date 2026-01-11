# Repository Guidelines

## Project Structure & Module Organization
- `lib/main.dart` is the app entry point; `lib/app/` wires the root widget, routing, and top-level providers.
- `lib/core/` holds shared services and utilities such as `network/`, `storage/`, `theme/`, `localization/`, `security/`, `logging/`, `constants/`, and `bloc/`.
- `lib/features/<feature>/` contains feature modules. `home/` follows `data/`, `domain/`, and `presentation/` (with `bloc/` and `pages/`), while other features currently focus on `presentation/pages/`.
- Localization strings live in `lib/l10n/*.arb` (for example, `app_en.arb`, `app_ru.arb`).
- Platform targets are in `android/`, `ios/`, `web/`, `linux/`, `macos/`, and `windows/`.
- Generated files like `*.g.dart` are created by build tools and should not be edited manually.

## Build, Test, and Development Commands
- `flutter pub get` installs dependencies.
- `flutter run` launches the app on a connected device or emulator.
- `flutter analyze` runs static analysis using `analysis_options.yaml`.
- `dart format .` formats all Dart sources consistently.
- `dart run build_runner build --delete-conflicting-outputs` regenerates JSON serializers (for example, `user_model.g.dart`).
- `flutter test` runs unit/widget tests (add tests as the suite grows).
- `flutter build apk` builds a release APK (adjust target per platform).

## Coding Style & Naming Conventions
- Use Dart defaults: 2-space indentation and formatting via `dart format`.
- File names are `lower_snake_case.dart`; classes use `UpperCamelCase`; methods/variables use `lowerCamelCase`.
- Keep Cubit/Bloc naming consistent (for example, `HomeCubit` with `HomeState`).
- Follow `flutter_lints` configured in `analysis_options.yaml`.

## Testing Guidelines
- `flutter_test` is available, but there is no `test/` directory yet.
- Add tests under `test/`, mirroring the `lib/` structure, and name them `*_test.dart`.
- Prefer unit tests for cubits and repositories, and widget tests for UI flows.

## Commit & Pull Request Guidelines
- Git history currently includes only an “Initial project commit,” so there is no established convention yet.
- Until a convention is agreed, use clear, imperative subjects with optional prefixes (for example, `feat: add login flow`, `fix: handle null token`).
- PRs should include a concise summary, testing notes, and screenshots for UI changes; link related issues/tasks when available.

## Configuration & Security Tips
- Update platform permissions in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` when adding platform features.
- Avoid committing secrets; use local environment configuration or platform-specific settings.
- When editing `lib/l10n/*.arb`, rebuild/run the app so generated localization files stay in sync.
