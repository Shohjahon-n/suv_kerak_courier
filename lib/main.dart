import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'app/app.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/di/service_locator.dart';
import 'core/logging/app_logger.dart';

Future<void> main() async {
  final talker = AppLogger.create();
  await runTalkerZonedGuarded(
    talker,
    () async {
      WidgetsFlutterBinding.ensureInitialized();

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
    (error, stackTrace) {},
  );
}
