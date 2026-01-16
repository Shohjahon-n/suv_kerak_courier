import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/security/pin_pad.dart';
import '../../../../core/security/security_cubit.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/responsive_spacing.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentLocale = context.select((LocaleCubit cubit) => cubit.state);
    final themeMode = context.select((ThemeCubit cubit) => cubit.state);

    final languages = [
      _LanguageOption(
        locale: const Locale('en'),
        label: l10n.languageEnglish,
        flag: '🇬🇧',
      ),
      _LanguageOption(
        locale: const Locale('ru'),
        label: l10n.languageRussian,
        flag: '🇷🇺',
      ),
      _LanguageOption(
        locale: const Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn'),
        label: l10n.languageUzbekLatin,
        flag: '🇺🇿',
      ),
      _LanguageOption(
        locale: const Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
        label: l10n.languageUzbekCyrillic,
        flag: '🇺🇿',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: ResponsiveSpacing.pagePadding(context),
        children: [
          _SectionTitle(title: l10n.languageTitle),
          const SizedBox(height: 8),
          ...languages.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LanguageTile(
                option: option,
                selected: _isSameLocale(option.locale, currentLocale),
                onTap: () {
                  context.read<LocaleCubit>().setLocale(option.locale);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SectionTitle(title: l10n.themeModeTitle),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 8)),
          Container(
            padding: ResponsiveSpacing.cardPadding(context),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveSpacing.borderRadius(context, base: 14)),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.themeModeLight),
                  icon: const Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.themeModeDark),
                  icon: const Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {themeMode},
              showSelectedIcon: false,
              onSelectionChanged: (selection) async {
                if (selection.isEmpty) {
                  return;
                }
                await context.read<ThemeCubit>().setMode(selection.first);
              },
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: l10n.securityTitle),
          const SizedBox(height: 8),
          BlocBuilder<SecurityCubit, SecurityState>(
            builder: (context, state) {
              return Column(
                children: [
                  _ToggleTile(
                    title: l10n.securityPinTitle,
                    value: state.pinEnabled,
                    onChanged: (enabled) async {
                      final cubit = context.read<SecurityCubit>();
                      if (enabled) {
                        final pin = await _showPinSetupDialog(context);
                        if (!context.mounted) {
                          return;
                        }
                        if (pin == null) {
                          return;
                        }
                        await cubit.enablePin(pin);
                      } else {
                        await cubit.disablePin();
                      }
                    },
                  ),
                  if (state.pinEnabled) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await _showChangePinDialog(context);
                          if (!context.mounted) return;
                          if (result == null) return;

                          final cubit = context.read<SecurityCubit>();
                          final success = await cubit.changePin(
                            result.oldPin,
                            result.newPin,
                          );

                          if (!context.mounted) return;
                          if (success) {
                            _showToast(context, l10n.pinChangeSuccess);
                          } else {
                            _showToast(context, l10n.pinChangeError);
                          }
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(l10n.changePinButton),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _ToggleTile(
                    title: l10n.securityBiometricTitle,
                    value: state.biometricEnabled,
                    onChanged: (enabled) async {
                      final cubit = context.read<SecurityCubit>();
                      if (enabled) {
                        final available = await cubit.canUseBiometrics();
                        if (!context.mounted) {
                          return;
                        }
                        if (!available) {
                          _showToast(context, l10n.biometricUnavailable);
                          return;
                        }
                      }
                      await cubit.setBiometricEnabled(enabled);
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: l10n.profileTitle),
          SizedBox(height: ResponsiveSpacing.spacing(context, base: 8)),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveSpacing.borderRadius(context, base: 14)),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: colorScheme.error,
              ),
              title: Text(
                l10n.logoutButton,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _logout(context),
            ),
          ),
        ],
      ),
    );
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

  Future<String?> _showPinSetupDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => const _PinSetupDialog(),
    );
  }

  Future<_ChangePinResult?> _showChangePinDialog(BuildContext context) async {
    return showDialog<_ChangePinResult>(
      context: context,
      builder: (context) => const _ChangePinDialog(),
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final preferences = context.read<AppPreferences>();
    final securityCubit = context.read<SecurityCubit>();
    await preferences.clearSession();
    securityCubit.reset();
    if (!context.mounted) {
      return;
    }
    context.go('/login');
  }
}

class _ChangePinResult {
  const _ChangePinResult({required this.oldPin, required this.newPin});

  final String oldPin;
  final String newPin;
}

class _ChangePinDialog extends StatefulWidget {
  const _ChangePinDialog();

  @override
  State<_ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<_ChangePinDialog> {
  static const int _pinLength = 4;

  String _input = '';
  String? _oldPin;
  String? _firstNewPin;
  String? _errorText;

  _PinStep get _currentStep {
    if (_oldPin == null) return _PinStep.oldPin;
    if (_firstNewPin == null) return _PinStep.newPin;
    return _PinStep.confirmNewPin;
  }

  void _addDigit(String digit) {
    if (_input.length >= _pinLength) return;
    setState(() {
      _input = '$_input$digit';
      _errorText = null;
    });
    if (_input.length == _pinLength) {
      _handleComplete();
    }
  }

  void _removeDigit() {
    if (_input.isEmpty) return;
    setState(() {
      _input = _input.substring(0, _input.length - 1);
    });
  }

  void _handleComplete() {
    final l10n = AppLocalizations.of(context);

    if (_oldPin == null) {
      // First step: old PIN entered
      setState(() {
        _oldPin = _input;
        _input = '';
      });
      return;
    }

    if (_firstNewPin == null) {
      // Second step: new PIN entered
      if (_input == _oldPin) {
        setState(() {
          _errorText = l10n.pinChangeSameError;
          _input = '';
        });
        return;
      }
      setState(() {
        _firstNewPin = _input;
        _input = '';
      });
      return;
    }

    // Third step: confirm new PIN
    if (_input == _firstNewPin) {
      Navigator.of(context).pop(
        _ChangePinResult(oldPin: _oldPin!, newPin: _input),
      );
      return;
    }

    setState(() {
      _errorText = l10n.pinSetupErrorMismatch;
      _firstNewPin = null;
      _input = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final stepLabel = switch (_currentStep) {
      _PinStep.oldPin => l10n.pinChangeOldLabel,
      _PinStep.newPin => l10n.pinChangeNewLabel,
      _PinStep.confirmNewPin => l10n.pinSetupConfirmLabel,
    };

    return Dialog(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.changePinTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              stepLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            PinDots(length: _pinLength, filled: _input.length),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            PinKeypad(
              onDigit: _addDigit,
              onBackspace: _removeDigit,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.pinSetupCancel),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PinStep { oldPin, newPin, confirmNewPin }

class _PinSetupDialog extends StatefulWidget {
  const _PinSetupDialog();

  @override
  State<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<_PinSetupDialog> {
  static const int _pinLength = 4;

  String _input = '';
  String? _firstPin;
  String? _errorText;

  bool get _isConfirming => _firstPin != null;

  void _addDigit(String digit) {
    if (_input.length >= _pinLength) {
      return;
    }
    setState(() {
      _input = '$_input$digit';
      _errorText = null;
    });
    if (_input.length == _pinLength) {
      _handleComplete();
    }
  }

  void _removeDigit() {
    if (_input.isEmpty) {
      return;
    }
    setState(() {
      _input = _input.substring(0, _input.length - 1);
    });
  }

  void _handleComplete() {
    final l10n = AppLocalizations.of(context);
    if (_firstPin == null) {
      setState(() {
        _firstPin = _input;
        _input = '';
      });
      return;
    }
    if (_input == _firstPin) {
      Navigator.of(context).pop(_input);
      return;
    }
    setState(() {
      _errorText = l10n.pinSetupErrorMismatch;
      _firstPin = null;
      _input = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final stepLabel =
    _isConfirming ? l10n.pinSetupConfirmLabel : l10n.pinSetupLabel;

    return Dialog(
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.pinSetupTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pinSetupSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              stepLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            PinDots(length: _pinLength, filled: _input.length),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 20),
            PinKeypad(
              onDigit: _addDigit,
              onBackspace: _removeDigit,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.pinSetupCancel),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.locale,
    required this.label,
    required this.flag,
  });

  final Locale locale;
  final String label;
  final String flag;
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = ResponsiveSpacing.borderRadius(context, base: 14);
    final padding = ResponsiveSpacing.largePadding(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: padding.left,
            vertical: padding.top * 0.75,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primaryContainer
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.4)
                  : colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Text(option.flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveSpacing.borderRadius(context, base: 14)),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: SwitchListTile.adaptive(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
