import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_localizations.dart';
import '../storage/app_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._preferences)
      : super(
          AppLocalizations.resolveLocale(
            WidgetsBinding.instance.platformDispatcher.locale,
          ),
        ) {
    _loadSavedLocale();
  }

  final AppPreferences _preferences;

  Future<void> _loadSavedLocale() async {
    final saved = _preferences.readLocale();
    if (saved == null) {
      return;
    }
    emit(AppLocalizations.resolveLocale(saved));
  }

  Future<void> setLocale(Locale locale) async {
    final resolved = AppLocalizations.resolveLocale(locale);
    await _preferences.setLocale(resolved);
    emit(resolved);
  }
}
