import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1E6FD9),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD6ECFF),
    onPrimaryContainer: Color(0xFF0B1B2B),
    secondary: Color(0xFF2CB6C7),
    onSecondary: Color(0xFF00343D),
    secondaryContainer: Color(0xFFCFF1F4),
    onSecondaryContainer: Color(0xFF0A2C34),
    tertiary: Color(0xFFFF8A00),
    onTertiary: Color(0xFF2B1400),
    tertiaryContainer: Color(0xFFFFE2C2),
    onTertiaryContainer: Color(0xFF3A1B00),
    error: Color(0xFFD32F2F),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0E2A3A),
    surfaceContainerHighest: Color(0xFFE8F0F7),
    onSurfaceVariant: Color(0xFF405465),
    outline: Color(0xFFC7D4E4),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFF1C2A35),
    onInverseSurface: Color(0xFFE8F0F7),
    inversePrimary: Color(0xFF6FB4FF),
  );

  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF6FB4FF),
    onPrimary: Color(0xFF0B1B2B),
    primaryContainer: Color(0xFF0F3D73),
    onPrimaryContainer: Color(0xFFD6ECFF),
    secondary: Color(0xFF4FD0DD),
    onSecondary: Color(0xFF081E23),
    secondaryContainer: Color(0xFF0C3C45),
    onSecondaryContainer: Color(0xFFCFF1F4),
    tertiary: Color(0xFFFFB156),
    onTertiary: Color(0xFF2B1400),
    tertiaryContainer: Color(0xFF5A2A00),
    onTertiaryContainer: Color(0xFFFFE2C2),
    error: Color(0xFFEF5350),
    onError: Color(0xFF300000),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0F1922),
    onSurface: Color(0xFFE1E8EE),
    surfaceContainerHighest: Color(0xFF1C2A35),
    onSurfaceVariant: Color(0xFFB5C4D1),
    outline: Color(0xFF3A4A58),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFFE8F0F7),
    onInverseSurface: Color(0xFF0E2A3A),
    inversePrimary: Color(0xFF1E6FD9),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: _lightColorScheme.surface,
    appBarTheme: const AppBarTheme(centerTitle: false),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1E6FD9),
      foregroundColor: Color(0xFFFFFFFF),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: _darkColorScheme.surface,
    appBarTheme: const AppBarTheme(centerTitle: false),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6FB4FF),
      foregroundColor: Color(0xFF0B1B2B),
    ),
  );
}
