import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._(this._prefs);

  static const _keyLocale = 'selected_locale';
  static const _keyThemeMode = 'theme_mode';
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserJson = 'user_json';
  static const _keyCourierId = 'courier_id';
  static const _keyBusinessId = 'business_id';
  static const _keyPinEnabled = 'pin_enabled';
  static const _keyPinHash = 'pin_hash';
  static const _keyBiometricEnabled = 'biometric_enabled';

  final SharedPreferences _prefs;

  static Future<AppPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences._(prefs);
  }

  bool get hasLocale => _prefs.containsKey(_keyLocale);
  bool get hasSession =>
      _prefs.containsKey(_keyCourierId) && _prefs.containsKey(_keyBusinessId);

  Locale? readLocale() {
    final raw = _prefs.getString(_keyLocale);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    if (raw.startsWith('uz_')) {
      final parts = raw.split('_');
      if (parts.length == 2 && parts[1].isNotEmpty) {
        return Locale.fromSubtags(languageCode: 'uz', scriptCode: parts[1]);
      }
    }
    return Locale(raw);
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_keyLocale, _localeKey(locale));
  }

  ThemeMode? readThemeMode() {
    final raw = _prefs.getString(_keyThemeMode);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
    }
    return null;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = mode == ThemeMode.dark ? 'dark' : 'light';
    await _prefs.setString(_keyThemeMode, value);
  }

  String? readAccessToken() => _prefs.getString(_keyAccessToken);

  Future<void> setAccessToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _prefs.remove(_keyAccessToken);
      return;
    }
    await _prefs.setString(_keyAccessToken, token);
  }

  String? readRefreshToken() => _prefs.getString(_keyRefreshToken);

  Future<void> setRefreshToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _prefs.remove(_keyRefreshToken);
      return;
    }
    await _prefs.setString(_keyRefreshToken, token);
  }

  String? readUserJson() => _prefs.getString(_keyUserJson);

  Future<void> setUserJson(String? json) async {
    if (json == null || json.isEmpty) {
      await _prefs.remove(_keyUserJson);
      return;
    }
    await _prefs.setString(_keyUserJson, json);
  }

  int? readCourierId() => _prefs.getInt(_keyCourierId);

  Future<void> setCourierId(int? id) async {
    if (id == null) {
      await _prefs.remove(_keyCourierId);
      return;
    }
    await _prefs.setInt(_keyCourierId, id);
  }

  int? readBusinessId() => _prefs.getInt(_keyBusinessId);

  Future<void> setBusinessId(int? id) async {
    if (id == null) {
      await _prefs.remove(_keyBusinessId);
      return;
    }
    await _prefs.setInt(_keyBusinessId, id);
  }

  bool readPinEnabled() => _prefs.getBool(_keyPinEnabled) ?? false;

  Future<void> setPinEnabled(bool enabled) async {
    await _prefs.setBool(_keyPinEnabled, enabled);
  }

  String? readPinHash() => _prefs.getString(_keyPinHash);

  Future<void> setPinHash(String? hash) async {
    if (hash == null || hash.isEmpty) {
      await _prefs.remove(_keyPinHash);
      return;
    }
    await _prefs.setString(_keyPinHash, hash);
  }

  bool readBiometricEnabled() => _prefs.getBool(_keyBiometricEnabled) ?? false;

  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_keyBiometricEnabled, enabled);
  }

  String _localeKey(Locale locale) {
    if (locale.languageCode == 'uz') {
      return 'uz_${locale.scriptCode ?? 'Latn'}';
    }
    return locale.languageCode;
  }
}
