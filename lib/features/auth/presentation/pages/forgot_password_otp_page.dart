import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/security/security_cubit.dart';
import '../../../../core/storage/app_preferences.dart';

class ForgotPasswordOtpPage extends StatefulWidget {
  const ForgotPasswordOtpPage({
    super.key,
    required this.courierId,
  });

  final int courierId;

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
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
      _showToast(l10n.forgotPasswordOtpValidation);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dio = context.read<Dio>();
      final response = await dio.post(
        '/bots/kuryer/forgot-password/verify/',
        data: {
          'kuryer_id': widget.courierId,
          'code': code,
        },
      );
      final data = response.data;
      final ok = data is Map && data['ok'] == true;
      final detail = _stringValue(data, 'detail');
      if (!ok) {
        _showToast(detail ?? l10n.forgotPasswordOtpFailed);
        return;
      }

      final preferences = context.read<AppPreferences>();
      final responseCourierId = _intValue(data['kuryer_id']);
      final responseBusinessId = _intValue(data['business_id']);
      final resolvedCourierId = responseCourierId ?? widget.courierId;
      final resolvedBusinessId =
          responseBusinessId ?? preferences.readBusinessId();

      await preferences.setCourierId(resolvedCourierId);
      if (resolvedBusinessId == null) {
        _showToast(l10n.securitySessionMissing);
        return;
      }
      await preferences.setBusinessId(resolvedBusinessId);

      if (!mounted) {
        return;
      }
      context.read<SecurityCubit>().activateSession();
      context.go('/home');
    } on DioException catch (error) {
      _showToast(
        _extractErrorDetail(error) ?? l10n.forgotPasswordOtpFailed,
      );
    } catch (_) {
      _showToast(l10n.forgotPasswordOtpFailed);
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
      _showToast(l10n.forgotPasswordOpenBotFailed);
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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 24,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back),
                            color: colorScheme.onBackground,
                            tooltip: MaterialLocalizations.of(context)
                                .backButtonTooltip,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.forgotPasswordOtpTitle,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.forgotPasswordOtpSubtitle,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${l10n.loginCourierIdLabel}: ${widget.courierId}',
                            style: textTheme.bodyMedium?.copyWith(
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
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _verifyOtp,
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
                                        : Text(l10n.forgotPasswordOtpButton),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _openBot,
                                    icon: const Icon(Icons.send_outlined),
                                    label:
                                        Text(l10n.forgotPasswordOpenBotButton),
                                  ),
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
