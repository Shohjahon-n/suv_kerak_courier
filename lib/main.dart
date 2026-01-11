import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'app/app.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/logging/app_logger.dart';
import 'core/network/dio_client.dart';
import 'core/storage/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final talker = AppLogger.create();
  final dio = DioClient.create(talker: talker);
  final preferences = await AppPreferences.create();

  Bloc.observer = AppBlocObserver(talker);

  await runTalkerZonedGuarded(
    talker,
    () => runApp(App(talker: talker, dio: dio, preferences: preferences)),
    (error, stackTrace) {},
  );
}
