import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/security/security_cubit.dart';
import '../../../../core/storage/app_preferences.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final TextEditingController _oldPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _oldPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController =
      TextEditingController();

  final FocusNode _oldPasswordFocus = FocusNode();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _oldPinFocus = FocusNode();
  final FocusNode _newPinFocus = FocusNode();
  final FocusNode _confirmPinFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscurePin = true;
  bool _isPasswordLoading = false;
  bool _isPinLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _oldPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _oldPinFocus.dispose();
    _newPinFocus.dispose();
    _confirmPinFocus.dispose();
    super.dispose();
  }

  Future<void> _submitPasswordChange() async {
    if (_isPasswordLoading) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (oldPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showToast(l10n.securityValidationRequired);
      return;
    }
    if (newPassword != confirmPassword) {
      _showToast(l10n.securityValidationMismatch);
      return;
    }

    setState(() => _isPasswordLoading = true);
    try {
      final preferences = context.read<AppPreferences>();
      final businessId = preferences.readBusinessId();
      final courierId = preferences.readCourierId();
      if (businessId == null || courierId == null) {
        _showToast(l10n.securitySessionMissing);
        return;
      }

      final dio = context.read<Dio>();
      final response = await dio.post(
        '/couriers/change-password/',
        data: {
          'business_id': businessId,
          'kuryer_id': courierId,
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      final data = response.data;
      final ok = data is Map && data['ok'] == true;
      final detail = _stringValue(data, 'detail');
      if (!ok) {
        _showToast(detail ?? l10n.securityPasswordUpdateFailed);
        return;
      }

      _clearPasswordInputs();
      _showToast(detail ?? l10n.securityPasswordUpdated);
    } on DioException catch (error) {
      _showToast(
        _extractErrorDetail(error) ?? l10n.securityPasswordUpdateFailed,
      );
    } catch (_) {
      _showToast(l10n.securityPasswordUpdateFailed);
    } finally {
      if (mounted) {
        setState(() => _isPasswordLoading = false);
      }
    }
  }

  Future<void> _submitPinChange() async {
    if (_isPinLoading) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final oldPin = _oldPinController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (oldPin.length != 4 || newPin.length != 4 || confirmPin.length != 4) {
      _showToast(l10n.pinSetupErrorLength);
      return;
    }
    if (newPin != confirmPin) {
      _showToast(l10n.pinSetupErrorMismatch);
      return;
    }

    setState(() => _isPinLoading = true);
    try {
      final preferences = context.read<AppPreferences>();
      final businessId = preferences.readBusinessId();
      final courierId = preferences.readCourierId();
      if (businessId == null || courierId == null) {
        _showToast(l10n.securitySessionMissing);
        return;
      }

      final dio = context.read<Dio>();
      final response = await dio.post(
        '/couriers/change-pin/',
        data: {
          'business_id': businessId,
          'kuryer_id': courierId,
          'old_pin': oldPin,
          'new_pin': newPin,
        },
      );
      final data = response.data;
      final ok = data is Map && data['ok'] == true;
      final detail = _stringValue(data, 'detail');
      if (!ok) {
        _showToast(detail ?? l10n.securityPinUpdateFailed);
        return;
      }

      if (!mounted) return;
      await context.read<SecurityCubit>().enablePin(newPin);
      _clearPinInputs();
      _showToast(detail ?? l10n.securityPinUpdated);
    } on DioException catch (error) {
      _showToast(
        _extractErrorDetail(error) ?? l10n.securityPinUpdateFailed,
      );
    } catch (_) {
      _showToast(l10n.securityPinUpdateFailed);
    } finally {
      if (mounted) {
        setState(() => _isPinLoading = false);
      }
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

  void _clearPasswordInputs() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _oldPasswordFocus.unfocus();
    _newPasswordFocus.unfocus();
    _confirmPasswordFocus.unfocus();
  }

  void _clearPinInputs() {
    _oldPinController.clear();
    _newPinController.clear();
    _confirmPinController.clear();
    _oldPinFocus.unfocus();
    _newPinFocus.unfocus();
    _confirmPinFocus.unfocus();
  }

  String? _extractErrorDetail(DioException error) {
    final data = error.response?.data;
    return _stringValue(data, 'detail');
  }

  String? _stringValue(dynamic data, String key) {
    if (data is Map) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.6),
      ),
    );

    InputDecoration decoration({
      required String label,
      required IconData icon,
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: colorScheme.surface,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.4,
          ),
        ),
        suffixIcon: suffixIcon,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menuSecurity),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: l10n.securityChangePasswordTitle),
          const SizedBox(height: 12),
          _FormCard(
            child: Column(
              children: [
                TextField(
                  controller: _oldPasswordController,
                  focusNode: _oldPasswordFocus,
                  enabled: !_isPasswordLoading,
                  textInputAction: TextInputAction.next,
                  obscureText: _obscurePassword,
                  decoration: decoration(
                    label: l10n.securityOldPasswordLabel,
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => _newPasswordFocus.requestFocus(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPasswordController,
                  focusNode: _newPasswordFocus,
                  enabled: !_isPasswordLoading,
                  textInputAction: TextInputAction.next,
                  obscureText: _obscurePassword,
                  decoration: decoration(
                    label: l10n.securityNewPasswordLabel,
                    icon: Icons.lock_reset_outlined,
                  ),
                  onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocus,
                  enabled: !_isPasswordLoading,
                  textInputAction: TextInputAction.done,
                  obscureText: _obscurePassword,
                  decoration: decoration(
                    label: l10n.securityConfirmPasswordLabel,
                    icon: Icons.check_circle_outline,
                  ),
                  onSubmitted: (_) => _submitPasswordChange(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isPasswordLoading ? null : _submitPasswordChange,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isPasswordLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(l10n.securityUpdateButton),
                  ),
                ),
              ],
            ),
          ),
          BlocBuilder<SecurityCubit, SecurityState>(
            builder: (context, state) {
              if (!state.pinEnabled) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _SectionTitle(title: l10n.securityChangePinTitle),
                  const SizedBox(height: 12),
                  _FormCard(
                    child: Column(
                      children: [
                        TextField(
                          controller: _oldPinController,
                          focusNode: _oldPinFocus,
                          enabled: !_isPinLoading,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          obscureText: _obscurePin,
                          inputFormatters:  [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: decoration(
                            label: l10n.securityOldPinLabel,
                            icon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() => _obscurePin = !_obscurePin);
                              },
                              icon: Icon(
                                _obscurePin
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _newPinFocus.requestFocus(),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newPinController,
                          focusNode: _newPinFocus,
                          enabled: !_isPinLoading,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          obscureText: _obscurePin,
                          inputFormatters:  [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: decoration(
                            label: l10n.securityNewPinLabel,
                            icon: Icons.lock_reset_outlined,
                          ),
                          onSubmitted: (_) => _confirmPinFocus.requestFocus(),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmPinController,
                          focusNode: _confirmPinFocus,
                          enabled: !_isPinLoading,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          obscureText: _obscurePin,
                          inputFormatters:  [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: decoration(
                            label: l10n.securityConfirmPinLabel,
                            icon: Icons.check_circle_outline,
                          ),
                          onSubmitted: (_) => _submitPinChange(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isPinLoading ? null : _submitPinChange,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isPinLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Text(l10n.securityUpdateButton),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
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

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
