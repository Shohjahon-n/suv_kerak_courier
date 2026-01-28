import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'app/app.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/di/service_locator.dart';
import 'core/logging/app_logger.dart';
import 'firebase_options.dart';

Future<void> main() async {
  final talker = AppLogger.create();

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Setup Crashlytics
      if (kReleaseMode) {
        // Production: send crashes to Firebase
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      }

      // Initialize Sentry
      await SentryFlutter.init(
        (options) {
          options.dsn = const String.fromEnvironment(
            'SENTRY_DSN',
            defaultValue: '', // Bo'sh qoldiring, keyin to'ldiramiz
          );
          options.tracesSampleRate = 1.0;
          options.environment = kReleaseMode ? 'production' : 'development';
        },
      );

      // Initialize dependency injection
      await setupServiceLocator(talker: talker);

      // Setup Bloc observer with Talker
      Bloc.observer = AppBlocObserver(getIt<Talker>());

      runApp(
        DevicePreview(
          enabled: !kReleaseMode,
          builder: (context) => const App(),
        ),
      );
    },
    (error, stackTrace) {
      talker.handle(error, stackTrace);

      // Send to Crashlytics in release mode
      if (kReleaseMode) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
      }

      // Send to Sentry
      Sentry.captureException(error, stackTrace: stackTrace);
    },
  );
}
