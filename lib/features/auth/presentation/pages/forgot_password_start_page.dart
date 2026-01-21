import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suv_kerak_courier/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordStartPage extends StatefulWidget {
  const ForgotPasswordStartPage({super.key});

  @override
  State<ForgotPasswordStartPage> createState() =>
      _ForgotPasswordStartPageState();
}

class _ForgotPasswordStartPageState extends State<ForgotPasswordStartPage>
    with ErrorHandlingMixin<ForgotPasswordStartPage> {
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
      showToast(l10n.forgotPasswordValidationEmpty);
      return;
    }

    final courierId = int.tryParse(courierIdText);
    if (courierId == null) {
      showToast(l10n.loginValidationId);
      return;
    }

    final dio = context.read<Dio>();

    setState(() => _isLoading = true);
    try {
      final response = await dio.post(
        '/bots/kuryer/forgot-password/start/',
        data: {
          'kuryer_id': courierId,
        },
      );
      final data = response.data;
      final ok = data is Map && data['ok'] == true;
      final detail = stringValue(data, 'detail');
      if (!mounted) {
        return;
      }
      if (!ok) {
        showToast(detail ?? l10n.forgotPasswordStartFailed);
        return;
      }

      final responseCourierId = intValue(data['kuryer_id']);
      final resolvedCourierId = responseCourierId ?? courierId;

      showToast(detail ?? l10n.forgotPasswordStartSuccess);
      context.push('/forgot-password/otp/$resolvedCourierId');
    } on DioException catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.forgotPasswordStartFailed,
        showSnackbar: true,
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.forgotPasswordStartFailed,
        showSnackbar: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      title: l10n.forgotPasswordTitle,
      subtitle: l10n.forgotPasswordSubtitle,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
        color: colorScheme.onSurface,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      ),
      form: AuthFormCard(
        child: Column(
          children: [
            TextField(
              controller: _courierIdController,
              focusNode: _courierFocus,
              enabled: !_isLoading,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.username],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.forgotPasswordCourierIdLabel,
                hintText: l10n.forgotPasswordCourierIdHint,
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
              onSubmitted: (_) => _submit(),
            ),
            SizedBox(height: ResponsiveSpacing.spacing(context, base: 20)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
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
                    : Text(l10n.forgotPasswordStartButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
