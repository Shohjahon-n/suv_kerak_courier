import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';
import '../localization/locale_cubit.dart';
import '../logging/app_logger.dart';
import '../network/dio_client.dart';
import '../security/security_cubit.dart';
import '../storage/app_preferences.dart';
import '../theme/theme_cubit.dart';

final getIt = GetIt.instance;

/// Initializes dependency injection
/// Call this before runApp()
Future<void> setupServiceLocator({Talker? talker}) async {
  // Register core services as singletons
  await _registerCoreServices(talker: talker);

  // Register repositories
  _registerRepositories();

  // Register Cubits as factories
  _registerCubits();
}

/// Register core singleton services
Future<void> _registerCoreServices({Talker? talker}) async {
  // Logging
  if (!getIt.isRegistered<Talker>()) {
    if (talker != null) {
      getIt.registerSingleton<Talker>(talker);
    } else {
      getIt.registerLazySingleton<Talker>(() => AppLogger.create());
    }
  }

  // Network
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(
      () => DioClient.create(
        talker: getIt<Talker>(),
        preferences: getIt<AppPreferences>(),
      ),
    );
  }

  // Storage - must be async
  if (!getIt.isRegistered<AppPreferences>()) {
    final preferences = await AppPreferences.create();
    getIt.registerSingleton<AppPreferences>(preferences);
  }
}

/// Register repositories as singletons
void _registerRepositories() {
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      dio: getIt<Dio>(),
      preferences: getIt<AppPreferences>(),
      talker: getIt<Talker>(),
    ),
  );
}

/// Register Cubits as factories (new instance each time)
void _registerCubits() {
  // Global Cubits
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit(getIt<AppPreferences>()));

  getIt.registerFactory<LocaleCubit>(
    () => LocaleCubit(getIt<AppPreferences>()),
  );

  getIt.registerFactory<SecurityCubit>(
    () => SecurityCubit(getIt<AppPreferences>(), getIt<Dio>(), getIt<Talker>()),
  );

  // Feature Cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      authRepository: getIt<AuthRepository>(),
      talker: getIt<Talker>(),
    ),
  );

  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(getIt<Dio>(), getIt<AppPreferences>(), getIt<Talker>()),
  );
}

/// Reset all registrations (useful for testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
}
