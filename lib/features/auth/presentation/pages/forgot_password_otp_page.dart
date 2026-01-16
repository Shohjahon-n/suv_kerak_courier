import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/security/security_cubit.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordOtpPage extends StatefulWidget {
  const ForgotPasswordOtpPage({
    super.key,
    required this.courierId,
  });

  final int courierId;

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage>
    with ErrorHandlingMixin<ForgotPasswordOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();
  bool _isLoading = false;

  static final Uri _botUri = Uri.parse('https://t.me/suv_kerak_bot');

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_isLoading) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final code = _otpController.text.trim();

    if (code.length != 4) {
      showToast(l10n.forgotPasswordOtpValidation);
      return;
    }

    final dio = context.read<Dio>();
    final preferences = context.read<AppPreferences>();

    setState(() => _isLoading = true);
    try {
      final response = await dio.post(
        '/bots/kuryer/forgot-password/verify/',
        data: {
          'kuryer_id': widget.courierId,
          'code': code,
        },
      );
      final data = response.data;
      final ok = data is Map && data['ok'] == true;
      final detail = stringValue(data, 'detail');
      if (!mounted) {
        return;
      }
      if (!ok) {
        showToast(detail ?? l10n.forgotPasswordOtpFailed);
        return;
      }

      final responseCourierId = intValue(data['kuryer_id']);
      final responseBusinessId = intValue(data['business_id']);
      final resolvedCourierId = responseCourierId ?? widget.courierId;
      final resolvedBusinessId =
          responseBusinessId ?? preferences.readBusinessId();

      await preferences.setCourierId(resolvedCourierId);
      if (!mounted) {
        return;
      }
      if (resolvedBusinessId == null) {
        showToast(l10n.securitySessionMissing);
        return;
      }
      await preferences.setBusinessId(resolvedBusinessId);

      if (!mounted) {
        return;
      }
      context.read<SecurityCubit>().activateSession();
      context.go('/home');
    } on DioException catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.forgotPasswordOtpFailed,
        showSnackbar: true,
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.forgotPasswordOtpFailed,
        showSnackbar: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openBot() async {
    final l10n = AppLocalizations.of(context);
    final ok = await launchUrl(
      _botUri,
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      showToast(l10n.forgotPasswordOpenBotFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        ResponsiveSpacing.borderRadius(context, base: 16),
      ),
      borderSide: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.6),
      ),
    );

    return AuthScaffold(
      title: l10n.forgotPasswordOtpTitle,
      subtitle: l10n.forgotPasswordOtpSubtitle,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
        color: colorScheme.onSurface,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      ),
      extra: Text(
        '${l10n.loginCourierIdLabel}: ${widget.courierId}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
      form: AuthFormCard(
        child: Column(
          children: [
            TextField(
              controller: _otpController,
              focusNode: _otpFocus,
              enabled: !_isLoading,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: InputDecoration(
                labelText: l10n.forgotPasswordOtpLabel,
                hintText: l10n.forgotPasswordOtpHint,
                prefixIcon: const Icon(Icons.sms_outlined),
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
              onSubmitted: (_) => _verifyOtp(),
            ),
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 20)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
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
                    : Text(l10n.forgotPasswordOtpButton),
              ),
            ),
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 12)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openBot,
                icon: const Icon(Icons.send_outlined),
                label: Text(l10n.forgotPasswordOpenBotButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
