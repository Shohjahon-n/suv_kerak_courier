import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

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

  bool get requiresAuth =>
      sessionActive && (pinEnabled || biometricEnabled);

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
    this._preferences, {
    LocalAuthentication? localAuth,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        super(_initialState(_preferences));

  final AppPreferences _preferences;
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
    emit(
      state.copyWith(
        sessionActive: sessionActive,
        isUnlocked: true,
      ),
    );
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
    final hash = _hashPin(pin);
    await _preferences.setPinHash(hash);
    await _preferences.setPinEnabled(true);
    emit(state.copyWith(pinEnabled: true, isUnlocked: true));
  }

  Future<void> disablePin() async {
    await _preferences.setPinEnabled(false);
    await _preferences.setPinHash(null);
    final requiresAuth =
        state.sessionActive && state.biometricEnabled;
    emit(
      state.copyWith(
        pinEnabled: false,
        isUnlocked: requiresAuth ? state.isUnlocked : true,
      ),
    );
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _preferences.setBiometricEnabled(enabled);
    final requiresAuth =
        state.sessionActive && (state.pinEnabled || enabled);
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
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics(String reason) async {
    emit(state.copyWith(isAuthenticating: true));
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
      if (didAuthenticate) {
        emit(state.copyWith(isUnlocked: true, isAuthenticating: false));
        return true;
      }
    } catch (_) {
      // Ignore and fall through to failure.
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
}
