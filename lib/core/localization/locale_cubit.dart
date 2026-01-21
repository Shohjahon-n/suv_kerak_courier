import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suv_kerak_courier/l10n/app_localizations.dart';

import '../storage/app_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._preferences)
      : super(
          _resolveLocale(
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
    emit(_resolveLocale(saved));
  }

  Future<void> setLocale(Locale locale) async {
    final resolved = _resolveLocale(locale);
    await _preferences.setLocale(resolved);
    emit(resolved);
  }
}

Locale _resolveLocale(Locale locale) {
  if (locale.languageCode == 'uz' && locale.scriptCode == null) {
    return const Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn');
  }

  for (final supported in AppLocalizations.supportedLocales) {
    if (_isSameLocale(supported, locale)) {
      return supported;
    }
  }
  return AppLocalizations.supportedLocales.first;
}

bool _isSameLocale(Locale a, Locale b) {
  if (a.languageCode != b.languageCode) {
    return false;
  }
  if (a.scriptCode != null || b.scriptCode != null) {
    return a.scriptCode == b.scriptCode;
  }
  return true;
}
