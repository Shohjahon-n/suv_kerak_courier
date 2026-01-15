import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';

class ForgotPasswordStartPage extends StatefulWidget {
  const ForgotPasswordStartPage({super.key});

  @override
  State<ForgotPasswordStartPage> createState() =>
      _ForgotPasswordStartPageState();
}

class _ForgotPasswordStartPageState extends State<ForgotPasswordStartPage> {
  final TextEditingController _courierIdController = TextEditingController();
  final FocusNode _courierFocus = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _courierIdController.dispose();
    _courierFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final courierIdText = _courierIdController.text.trim();

    if (courierIdText.isEmpty) {
      _showToast(l10n.forgotPasswordValidationEmpty);
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
        '/bots/kuryer/forgot-password/start/',
        data: {
          'kuryer_id': courierId,
        },
      );
      final data = response.data;
      final ok = data is Map && data['ok'] == true;
      final detail = _stringValue(data, 'detail');
      if (!ok) {
        _showToast(detail ?? l10n.forgotPasswordStartFailed);
        return;
      }

      final responseCourierId = _intValue(data['kuryer_id']);
      final resolvedCourierId = responseCourierId ?? courierId;

      if (!mounted) {
        return;
      }
      _showToast(detail ?? l10n.forgotPasswordStartSuccess);
      context.push('/forgot-password/otp/$resolvedCourierId');
    } on DioException catch (error) {
      _showToast(
        _extractErrorDetail(error) ?? l10n.forgotPasswordStartFailed,
      );
    } catch (_) {
      _showToast(l10n.forgotPasswordStartFailed);
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
                            l10n.forgotPasswordTitle,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.forgotPasswordSubtitle,
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
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.number,
                                  autofillHints: const [
                                    AutofillHints.username
                                  ],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: l10n.forgotPasswordCourierIdLabel,
                                    hintText: l10n.forgotPasswordCourierIdHint,
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
                                  onSubmitted: (_) => _submit(),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submit,
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
                                        : Text(l10n.forgotPasswordStartButton),
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
