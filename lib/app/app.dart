import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:suv_kerak_courier/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'app_router.dart';
import '../core/di/service_locator.dart';
import '../core/localization/locale_cubit.dart';
import '../core/security/security_cubit.dart';
import '../core/security/security_gate.dart';
import '../core/storage/app_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../core/widgets/connectivity_banner.dart';
import '../features/auth/data/repositories/auth_repository.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.create(preferences: getIt<AppPreferences>());
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Dio>(create: (context) => getIt<Dio>()),
        RepositoryProvider<AppPreferences>(
          create: (context) => getIt<AppPreferences>(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => getIt<AuthRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => getIt<ThemeCubit>()),
          BlocProvider(create: (context) => getIt<LocaleCubit>()),
          BlocProvider(create: (context) => getIt<SecurityCubit>()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<LocaleCubit, Locale>(
              builder: (context, locale) {
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context).appTitle,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  locale: locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  routerConfig: _router,
                  builder: (context, child) {
                    final content = TalkerWrapper(
                      talker: getIt<Talker>(),
                      child: child ?? const SizedBox.shrink(),
                    );
                    return ConnectivityBanner(
                      child: SecurityGate(child: content),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
