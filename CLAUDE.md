# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter-based courier delivery application for Suv Kerak business, supporting water bottle delivery operations with order management, cash reporting, bottle tracking, and map integration.

## Development Commands

### Dependency Management
- `flutter pub get` - Install dependencies
- `dart run build_runner build --delete-conflicting-outputs` - Regenerate JSON serializers (*.g.dart files)

### Running & Building
- `flutter run` - Launch app on connected device/emulator
- `flutter build apk` - Build Android release APK
- `flutter build ios` - Build iOS release (requires macOS)

### Code Quality
- `flutter analyze` - Run static analysis
- `dart format .` - Format all Dart code
- `flutter test` - Run tests (no tests currently exist)

## Architecture

### Application Bootstrap (lib/main.dart → lib/app/app.dart)

The app initializes core services before widget creation:
1. **AppLogger** (Talker) - Centralized logging for errors, network, and Bloc events
2. **DioClient** - HTTP client with Talker integration for request/response logging
3. **AppPreferences** - SharedPreferences wrapper for persistent storage
4. **AppBlocObserver** - Global Bloc observer that logs all state changes

These services are provided via `RepositoryProvider` to the entire widget tree.

### State Management (BLoC/Cubit)

Three global Cubits are created at app root:
- **ThemeCubit** - Manages light/dark theme (persisted via AppPreferences)
- **LocaleCubit** - Manages app locale (en, ru, uz_Latn, uz_Cyrl)
- **SecurityCubit** - Manages PIN/biometric authentication and lock state

Feature-specific Cubits are created locally:
- **HomeCubit** - Loads dashboard data from API using courier_id

### Security System

The security layer wraps the entire app via `SecurityGate` widget:

1. **SecurityGate** (lib/core/security/security_gate.dart) - Overlays lock screen when app requires auth
2. **SecurityCubit** (lib/core/security/security_cubit.dart) - Manages lock state based on:
   - Session existence (courier_id + business_id in preferences)
   - PIN enabled/disabled state
   - Biometric enabled/disabled state
   - Current unlock status
3. **SecurityLockScreen** - Displays PIN pad and biometric prompt when locked
4. Lifecycle integration - Locks on app backgrounding if security is enabled

Key security methods:
- `enablePin(pin)` / `disablePin()` - Store SHA256 hash of 4-digit PIN
- `verifyPin(pin)` - Compare against stored hash, unlock if match
- `authenticateWithBiometrics(reason)` - Use local_auth for biometric unlock
- `lockIfNeeded()` - Lock if session active and security enabled
- `refreshSession()` - Check session state on app resume

### Routing (go_router)

AppRouter (lib/app/app_router.dart) defines navigation with redirect logic:

**Redirect chain:**
1. No locale → `/language` (onboarding)
2. Has locale + no session → `/login`
3. Has locale + has session → `/home`

**Route structure:**
- Auth: `/login`, `/forgot-password`, `/forgot-password/otp/:courierId`
- Main: `/home` (dashboard with menu tiles)
- Orders: `/orders`, `/orders/pending`, `/orders/delivered-range`, `/orders/map`
- Reports: `/cash-report`, `/cash-report/periodic`, `/cash-report/online`
- Bottles: `/bottle-balance`, `/bottle-balance/empty`, `/bottle-balance/full-water`
- Settings: `/settings`, `/security`, `/about`

Routes passing data use `state.extra` for type-safe parameter objects.

### Network Layer

**DioClient** (lib/core/network/dio_client.dart):
- Base URL: `https://suv-kerak-backend-eu-d9af752240af.herokuapp.com`
- 20-second connect/receive timeouts
- TalkerDioLogger intercepts all requests/responses for debugging

API calls typically use courier_id from AppPreferences. Error handling extracts `detail` field from DioException responses.

### Session Management

Session is defined as having both:
- `courier_id` (int)
- `business_id` (int)

Stored in SharedPreferences via AppPreferences. Additional session data:
- `access_token` / `refresh_token` (currently unused)
- `user_json` (serialized user data)

`clearSession()` removes all session data including security settings.

### Localization

Supported locales:
- English (en)
- Russian (ru)
- Uzbek Latin (uz_Latn)
- Uzbek Cyrillic (uz_Cyrl)

ARB files in `lib/l10n/*.arb` generate AppLocalizations class. Uzbek locales use script code differentiation.

After editing ARB files, restart app to regenerate localization files.

### Feature Structure

Most features use simplified presentation-only structure:
- `lib/features/<feature>/presentation/pages/` - UI screens
- `lib/features/<feature>/presentation/widgets/` - Reusable widgets

**Home feature** follows full clean architecture:
- `data/` - Models, data sources, repository implementations
- `domain/` - Entities, repository interfaces
- `presentation/` - Bloc, pages, widgets

Use home feature as reference when adding clean architecture to other features.

### Shared Utilities

**lib/core/widgets/** (recently added):
- `adaptive_grid.dart` - Responsive grid layout
- `key_value_row.dart` - Common key-value display pattern

**lib/core/constants/app_constants.dart**:
- `StringFormatExtension.toUzsFormat()` - Formats numbers as "123 456.78 UZS"

## Code Generation

Models using `json_serializable` require:
1. Import `package:json_annotation/json_annotation.dart`
2. Add `part 'filename.g.dart';` directive
3. Annotate class with `@JsonSerializable()`
4. Run `dart run build_runner build --delete-conflicting-outputs`

Generated files (*.g.dart) should not be edited manually.

## Platform Configuration

When adding features requiring permissions:
- Android: Update `android/app/src/main/AndroidManifest.xml`
- iOS: Update `ios/Runner/Info.plist`

Current permissions configured:
- Location (geolocator)
- Biometric authentication (local_auth)

## Formatting & Linting

- 2-space indentation (Dart default)
- File names: `lower_snake_case.dart`
- Classes: `UpperCamelCase`
- Methods/variables: `lowerCamelCase`
- Cubit naming: `FeatureCubit` with `FeatureState`
- Follows `package:flutter_lints/flutter.yaml` rules
