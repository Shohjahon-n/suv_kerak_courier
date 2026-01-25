import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suv_kerak_courier/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/security/security_cubit.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../widgets/auth_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with ErrorHandlingMixin<LoginPage> {
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
      showToast(l10n.loginValidationEmpty);
      return;
    }

    final courierId = int.tryParse(courierIdText);
    if (courierId == null) {
      showToast(l10n.loginValidationId);
      return;
    }

    final dio = context.read<Dio>();
    final preferences = context.read<AppPreferences>();

    setState(() => _isLoading = true);

    try {
      final response = await dio.post(
        '/couriers/login/',
        data: {'kuryer_id': courierId, 'password': password},
      );
      final data = response.data;
      final ok = data is Map && data['ok'] == true;
      final detail = stringValue(data, 'detail');

      if (!mounted) {
        return;
      }
      if (!ok) {
        showToast(detail ?? l10n.loginErrorGeneric);
        return;
      }

      final responseCourierId = intValue(data['kuryer_id']);
      final responseBusinessId = intValue(data['business_id']);
      final accessToken = stringValue(data, 'access');
      final refreshToken = stringValue(data, 'refresh');

      // Save tokens
      await preferences.setAccessToken(accessToken);
      await preferences.setRefreshToken(refreshToken);

      // Save user data
      await preferences.setCourierId(responseCourierId ?? courierId);
      await preferences.setBusinessId(responseBusinessId);

      if (!mounted) {
        return;
      }

      // Check if courier has completed profile
      final profileComplete = await _checkProfileStatus(
        responseCourierId ?? courierId,
      );

      if (!mounted) {
        return;
      }

      context.read<SecurityCubit>().activateSession();

      // Navigate based on profile completion status
      if (profileComplete) {
        context.go('/home');
      } else {
        context.go('/profile-completion');
      }
    } on DioException catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.loginErrorGeneric,
        showSnackbar: true,
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.loginErrorGeneric,
        showSnackbar: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _checkProfileStatus(int courierId) async {
    try {
      final dio = context.read<Dio>();
      final response = await dio.post(
        '/couriers/check-courier-parametr/',
        data: {'kuryer_id': courierId},
      );

      final data = response.data;
      if (data is Map) {
        // If ok is true, profile is complete
        return data['ok'] == true;
      }
      return false;
    } catch (e) {
      // On network error, assume profile exists (send to home)
      // This is safer - user can access app even if profile check fails
      return true;
    }
  }

  void _showComingSoon() {
    showToast(AppLocalizations.of(context).comingSoon);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        ResponsiveSpacing.borderRadius(context, base: 16),
      ),
      borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.6)),
    );

    return AuthScaffold(
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      form: AuthFormCard(
        child: Column(
          children: [
            TextField(
              controller: _courierIdController,
              focusNode: _courierFocus,
              enabled: !_isLoading,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.username],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.loginCourierIdLabel,
                hintText: l10n.loginCourierIdHint,
                prefixIcon: const Icon(Icons.badge_outlined),
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
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 16)),
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              enabled: !_isLoading,
              textInputAction: TextInputAction.done,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: l10n.loginPasswordLabel,
                hintText: l10n.loginPasswordHint,
                prefixIcon: const Icon(Icons.lock_outline),
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
                      _obscurePassword = !_obscurePassword;
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
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 20)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveSpacing.spacing(context, base: 14),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveSpacing.borderRadius(context, base: 16),
                    ),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: ResponsiveSpacing.iconSize(context, base: 20),
                        width: ResponsiveSpacing.iconSize(context, base: 20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(l10n.loginButton),
              ),
            ),
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 8)),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: ResponsiveSpacing.spacing(context, base: 4),
              spacing: ResponsiveSpacing.spacing(context, base: 12),
              children: [
                TextButton(
                  onPressed: () => context.push('/forgot-password'),
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
    );
  }
}
