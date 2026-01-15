import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'app_router.dart';
import '../core/localization/app_localizations.dart';
import '../core/localization/locale_cubit.dart';
import '../core/security/security_cubit.dart';
import '../core/security/security_gate.dart';
import '../core/storage/app_preferences.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    required this.talker,
    required this.dio,
    required this.preferences,
  });

  final Talker talker;
  final Dio dio;
  final AppPreferences preferences;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.create(preferences: widget.preferences);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.talker),
        RepositoryProvider.value(value: widget.dio),
        RepositoryProvider.value(value: widget.preferences),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ThemeCubit(
              context.read<AppPreferences>(),
            ),
          ),
          BlocProvider(create: (context) => LocaleCubit(
                context.read<AppPreferences>(),
              )),
          BlocProvider(
            create: (context) => SecurityCubit(
              context.read<AppPreferences>(),
              context.read<Dio>(),
              context.read<Talker>(),
            ),
          ),
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
                      talker: widget.talker,
                      child: child ?? const SizedBox.shrink(),
                    );
                    return SecurityGate(child: content);
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
