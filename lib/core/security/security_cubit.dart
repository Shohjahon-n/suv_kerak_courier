import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../storage/app_preferences.dart';

class SecurityState extends Equatable {
  const SecurityState({
    required this.sessionActive,
    required this.pinEnabled,
    required this.biometricEnabled,
    required this.isUnlocked,
    this.isAuthenticating = false,
  });

  final bool sessionActive;
  final bool pinEnabled;
  final bool biometricEnabled;
  final bool isUnlocked;
  final bool isAuthenticating;

  bool get requiresAuth => sessionActive && (pinEnabled || biometricEnabled);

  SecurityState copyWith({
    bool? sessionActive,
    bool? pinEnabled,
    bool? biometricEnabled,
    bool? isUnlocked,
    bool? isAuthenticating,
  }) {
    return SecurityState(
      sessionActive: sessionActive ?? this.sessionActive,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    );
  }

  @override
  List<Object?> get props => [
    sessionActive,
    pinEnabled,
    biometricEnabled,
    isUnlocked,
    isAuthenticating,
  ];
}

class SecurityCubit extends Cubit<SecurityState> {
  SecurityCubit(
    this._preferences,
    this._dio,
    this._talker, {
    LocalAuthentication? localAuth,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       super(_initialState(_preferences));

  final AppPreferences _preferences;
  final Dio _dio;
  final Talker _talker;
  final LocalAuthentication _localAuth;

  static SecurityState _initialState(AppPreferences preferences) {
    final pinHash = preferences.readPinHash();
    final pinEnabled = preferences.readPinEnabled() && pinHash != null;
    final biometricEnabled = preferences.readBiometricEnabled();
    final sessionActive = preferences.hasSession;
    final requiresAuth = sessionActive && (pinEnabled || biometricEnabled);
    return SecurityState(
      sessionActive: sessionActive,
      pinEnabled: pinEnabled,
      biometricEnabled: biometricEnabled,
      isUnlocked: !requiresAuth,
    );
  }

  void refreshSession() {
    final sessionActive = _preferences.hasSession;
    final requiresAuth =
        sessionActive && (state.pinEnabled || state.biometricEnabled);
    emit(
      state.copyWith(
        sessionActive: sessionActive,
        isUnlocked: requiresAuth ? state.isUnlocked : true,
      ),
    );
  }

  void activateSession() {
    final sessionActive = _preferences.hasSession;
    emit(state.copyWith(sessionActive: sessionActive, isUnlocked: true));
  }

  void reset() {
    emit(_initialState(_preferences));
  }

  void lockIfNeeded() {
    if (!state.requiresAuth) {
      return;
    }
    if (!state.isUnlocked) {
      return;
    }
    emit(state.copyWith(isUnlocked: false));
  }

  Future<void> enablePin(String pin) async {
    if (pin.length != 4) {
      return;
    }

    // Send PIN to backend
    final businessId = _preferences.readBusinessId();
    final courierId = _preferences.readCourierId();

    if (businessId != null && courierId != null) {
      try {
        final locale = _preferences.readLocale();
        final lang = _localeToLang(locale);

        await _dio.post(
          '/couriers/set-pin-code/',
          data: {
            'business_id': businessId,
            'kuryer_id': courierId,
            'pin_value': pin,
            'lang': lang,
          },
        );
      } catch (error, stackTrace) {
        // If backend fails, still save locally
        _talker.warning(
          'Failed to sync PIN to backend, saving locally only',
          error,
          stackTrace,
        );
      }
    }

    final hash = _hashPin(pin);
    await _preferences.setPinHash(hash);
    await _preferences.setPinEnabled(true);
    emit(state.copyWith(pinEnabled: true, isUnlocked: true));
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    if (oldPin.length != 4 || newPin.length != 4) {
      return false;
    }

    // Verify old PIN first
    final storedHash = _preferences.readPinHash();
    if (storedHash == null || storedHash != _hashPin(oldPin)) {
      return false;
    }

    // Send PIN change to backend
    final businessId = _preferences.readBusinessId();
    final courierId = _preferences.readCourierId();

    if (businessId != null && courierId != null) {
      try {
        await _dio.post(
          '/couriers/change-pin/',
          data: {
            'business_id': businessId,
            'kuryer_id': courierId,
            'old_pin': oldPin,
            'new_pin': newPin,
          },
        );
      } catch (error, stackTrace) {
        // If backend fails, don't proceed
        _talker.error('Failed to change PIN on backend', error, stackTrace);
        return false;
      }
    }

    // Save new PIN hash locally
    final newHash = _hashPin(newPin);
    await _preferences.setPinHash(newHash);
    return true;
  }

  Future<void> disablePin() async {
    await _preferences.setPinEnabled(false);
    await _preferences.setPinHash(null);
    final requiresAuth = state.sessionActive && state.biometricEnabled;
    emit(
      state.copyWith(
        pinEnabled: false,
        isUnlocked: requiresAuth ? state.isUnlocked : true,
      ),
    );
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _preferences.setBiometricEnabled(enabled);
    final requiresAuth = state.sessionActive && (state.pinEnabled || enabled);
    emit(
      state.copyWith(
        biometricEnabled: enabled,
        isUnlocked: requiresAuth ? state.isUnlocked : true,
      ),
    );
  }

  Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      return canCheck && supported;
    } catch (error, stackTrace) {
      _talker.error('Error checking biometric availability', error, stackTrace);
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics(String reason) async {
    emit(state.copyWith(isAuthenticating: true));
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuthenticate) {
        emit(state.copyWith(isUnlocked: true, isAuthenticating: false));
        return true;
      }
    } catch (error, stackTrace) {
      _talker.warning(
        'Biometric authentication failed or was cancelled',
        error,
        stackTrace,
      );
    }
    emit(state.copyWith(isAuthenticating: false));
    return false;
  }

  Future<bool> verifyPin(String pin) async {
    if (pin.length != 4) {
      return false;
    }
    final storedHash = _preferences.readPinHash();
    if (storedHash == null || storedHash.isEmpty) {
      return false;
    }
    final matches = storedHash == _hashPin(pin);
    if (matches) {
      emit(state.copyWith(isUnlocked: true));
    }
    return matches;
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  String _localeToLang(Locale? locale) {
    if (locale == null) return 'en';
    final code = locale.languageCode;
    if (code == 'uz') {
      final script = locale.scriptCode;
      if (script == 'Cyrl') return 'uz_Cyrl';
      return 'uz_Latn';
    }
    return code; // en, ru, etc.
  }
}
