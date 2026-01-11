import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/security/security_cubit.dart';
import '../../../../core/storage/app_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _courierIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _courierFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _courierIdController.dispose();
    _passwordController.dispose();
    _courierFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final courierIdText = _courierIdController.text.trim();
    final password = _passwordController.text;

    if (courierIdText.isEmpty || password.isEmpty) {
      _showToast(l10n.loginValidationEmpty);
      return;
    }

    final courierId = int.tryParse(courierIdText);
    if (courierId == null) {
      _showToast(l10n.loginValidationId);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = context.read<Dio>();
      final response = await dio.post(
        '/couriers/login/',
        data: {
          'kuryer_id': courierId,
          'password': password,
        },
      );
      final data = response.data;
      final ok = data is Map && data['ok'] == true;
      final detail = _stringValue(data, 'detail');

      if (!ok) {
        _showToast(detail ?? l10n.loginErrorGeneric);
        return;
      }

      final preferences = context.read<AppPreferences>();
      final responseCourierId = _intValue(data is Map ? data['kuryer_id'] : null);
      final responseBusinessId =
          _intValue(data is Map ? data['business_id'] : null);

      await preferences.setCourierId(responseCourierId ?? courierId);
      await preferences.setBusinessId(responseBusinessId);

      if (!mounted) {
        return;
      }
      context.read<SecurityCubit>().activateSession();
      context.go('/home');
    } on DioException catch (error) {
      _showToast(_extractErrorDetail(error) ?? l10n.loginErrorGeneric);
    } catch (_) {
      _showToast(l10n.loginErrorGeneric);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

  int? _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  void _showComingSoon() {
    _showToast(AppLocalizations.of(context).comingSoon);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: colorScheme.outline.withOpacity(0.6),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.background,
                  colorScheme.secondaryContainer,
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 24,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.loginTitle,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.loginSubtitle,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Container(
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
                              children: [
                                TextField(
                                  controller: _courierIdController,
                                  focusNode: _courierFocus,
                                  enabled: !_isLoading,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  autofillHints: const [
                                    AutofillHints.username
                                  ],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: l10n.loginCourierIdLabel,
                                    hintText: l10n.loginCourierIdHint,
                                    prefixIcon:
                                        const Icon(Icons.badge_outlined),
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
                                  ),
                                  onSubmitted: (_) {
                                    _passwordFocus.requestFocus();
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  enabled: !_isLoading,
                                  textInputAction: TextInputAction.done,
                                  obscureText: _obscurePassword,
                                  autofillHints: const [
                                    AutofillHints.password
                                  ],
                                  decoration: InputDecoration(
                                    labelText: l10n.loginPasswordLabel,
                                    hintText: l10n.loginPasswordHint,
                                    prefixIcon:
                                        const Icon(Icons.lock_outline),
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
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword =
                                              !_obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (_) => _login(),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _isLoading
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
                                        : Text(l10n.loginButton),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  runSpacing: 4,
                                  spacing: 12,
                                  children: [
                                    TextButton(
                                      onPressed: _showComingSoon,
                                      child: Text(l10n.forgotPassword),
                                    ),
                                    TextButton(
                                      onPressed: _showComingSoon,
                                      child: Text(l10n.registerLink),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
