import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/app_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._preferences)
    : super(_preferences.readThemeMode() ?? ThemeMode.light);

  final AppPreferences _preferences;

  Future<void> toggle() async {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setMode(next);
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _preferences.setThemeMode(mode);
  }
}
