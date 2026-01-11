import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../localization/app_localizations.dart';
import 'pin_pad.dart';
import 'security_cubit.dart';

class SecurityLockScreen extends StatefulWidget {
  const SecurityLockScreen({super.key});

  @override
  State<SecurityLockScreen> createState() => _SecurityLockScreenState();
}

class _SecurityLockScreenState extends State<SecurityLockScreen> {
  static const int _pinLength = 4;

  String _pin = '';
  String? _errorText;
  bool _isSubmitting = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submitPin() async {
    final l10n = AppLocalizations.of(context);
    final pin = _pin;
    if (pin.length != _pinLength) {
      setState(() => _errorText = l10n.pinSetupErrorLength);
      return;
    }
    if (_isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);
    final ok = await context.read<SecurityCubit>().verifyPin(pin);
    if (!mounted) {
      return;
    }
    if (!ok) {
      setState(() {
        _errorText = l10n.pinUnlockError;
        _pin = '';
        _isSubmitting = false;
      });
      return;
    }
    setState(() {
      _errorText = null;
      _isSubmitting = false;
    });
  }

  void _addDigit(String digit) {
    if (_pin.length >= _pinLength || _isSubmitting) {
      return;
    }
    setState(() {
      _pin = '$_pin$digit';
      _errorText = null;
    });
    if (_pin.length == _pinLength) {
      _submitPin();
    }
  }

  void _removeDigit() {
    if (_pin.isEmpty || _isSubmitting) {
      return;
    }
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _useBiometrics() async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SecurityCubit>();
    final available = await cubit.canUseBiometrics();
    if (!mounted) {
      return;
    }
    if (!available) {
      _showToast(l10n.biometricUnavailable);
      return;
    }
    final ok = await cubit.authenticateWithBiometrics(
      l10n.biometricReason,
    );
    if (!mounted) {
      return;
    }
    if (!ok) {
      _showToast(l10n.biometricFailed);
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<SecurityCubit, SecurityState>(
      builder: (context, state) {
        final showPin = state.pinEnabled;
        final showBiometric = state.biometricEnabled;
        final title =
            showPin ? l10n.pinUnlockTitle : l10n.securityBiometricTitle;
        final subtitle =
            showPin ? l10n.pinUnlockSubtitle : l10n.biometricReason;

        return WillPopScope(
          onWillPop: () async => false,
          child: Material(
            color: colorScheme.background,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                        colorScheme.background,
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: colorScheme.primary,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              title,
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (showPin) ...[
                              const SizedBox(height: 20),
                              PinDots(
                                length: _pinLength,
                                filled: _pin.length,
                              ),
                              if (_errorText != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  _errorText!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              PinKeypad(
                                enabled:
                                    !state.isAuthenticating && !_isSubmitting,
                                onDigit: _addDigit,
                                onBackspace: _removeDigit,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: (_pin.length == _pinLength &&
                                          !_isSubmitting &&
                                          !state.isAuthenticating)
                                      ? _submitPin
                                      : null,
                                  child: Text(l10n.pinUnlockButton),
                                ),
                              ),
                            ],
                            if (showBiometric) ...[
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: state.isAuthenticating
                                    ? null
                                    : _useBiometrics,
                                icon: state.isAuthenticating
                                    ? SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            colorScheme.primary,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.fingerprint),
                                label: Text(l10n.biometricButton),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
