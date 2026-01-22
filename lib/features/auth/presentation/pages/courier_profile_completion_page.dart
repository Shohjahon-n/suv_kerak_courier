import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:suv_kerak_courier/l10n/app_localizations.dart';

import '../../../../core/storage/app_preferences.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../../../../features/auth/presentation/widgets/car_plate_formatter.dart';
import '../../../../features/auth/presentation/widgets/phone_input_formatter.dart';
import '../widgets/auth_scaffold.dart';

class CourierProfileCompletionPage extends StatefulWidget {
  const CourierProfileCompletionPage({super.key});

  @override
  State<CourierProfileCompletionPage> createState() =>
      _CourierProfileCompletionPageState();
}

class _CourierProfileCompletionPageState
    extends State<CourierProfileCompletionPage>
    with ErrorHandlingMixin<CourierProfileCompletionPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _carNumberController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _carNumberFocus = FocusNode();
  final FocusNode _carModelFocus = FocusNode();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _carNumberController.dispose();
    _carModelController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _carNumberFocus.dispose();
    _carModelFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final carNumber = _carNumberController.text.trim();
    final carModel = _carModelController.text.trim();

    if (name.isEmpty) {
      showToast(l10n.profileNameValidation);
      _nameFocus.requestFocus();
      return;
    }

    if (!UzPhoneInputFormatter.isValid(phone)) {
      showToast(l10n.profilePhoneValidation);
      _phoneFocus.requestFocus();
      return;
    }

    if (!CarPlateInputFormatter.isValid(carNumber)) {
      showToast(l10n.profileCarNumberValidation);
      _carNumberFocus.requestFocus();
      return;
    }

    if (carModel.isEmpty) {
      showToast(l10n.profileCarModelValidation);
      _carModelFocus.requestFocus();
      return;
    }

    final preferences = context.read<AppPreferences>();
    final courierId = preferences.readCourierId();

    if (courierId == null) {
      showToast(l10n.profileCheckError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = context.read<Dio>();
      final cleanPhone = UzPhoneInputFormatter.getCleanPhone(phone);
      final cleanCarNumber = CarPlateInputFormatter.getCleanPlate(carNumber);

      await dio.post(
        '/couriers/save-profile/',
        data: {
          'kuryer_id': courierId,
          'kuryer_name': name,
          'avto_num': cleanCarNumber,
          'avto_marka': carModel,
          'tel_num': cleanPhone,
        },
      );

      if (!mounted) {
        return;
      }

      showToast(l10n.profileSubmitSuccess);

      if (!mounted) {
        return;
      }

      context.go('/home');
    } on DioException catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      final detail = extractErrorDetail(error);
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: detail ?? l10n.profileSubmitError,
        showSnackbar: true,
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.profileSubmitError,
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
      borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.6)),
    );

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.95,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: ResponsiveSpacing.pagePadding(context),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AuthFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: ResponsiveSpacing.iconSize(context, base: 48),
                      color: colorScheme.primary,
                    ),
                    SizedBox(
                      height: ResponsiveSpacing.spacing(context, base: 16),
                    ),
                    Text(
                      l10n.profileCompletionTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    SizedBox(
                      height: ResponsiveSpacing.spacing(context, base: 8),
                    ),
                    Text(
                      l10n.profileCompletionSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveSpacing.spacing(context, base: 24),
                    ),
                    TextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.profileNameLabel,
                        hintText: l10n.profileNameHint,
                        prefixIcon: const Icon(Icons.person_outline),
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
                        _phoneFocus.requestFocus();
                      },
                    ),
                    SizedBox(
                      height: ResponsiveSpacing.spacing(context, base: 16),
                    ),
                    TextField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [UzPhoneInputFormatter()],
                      decoration: InputDecoration(
                        labelText: l10n.profilePhoneLabel,
                        hintText: l10n.profilePhoneHint,
                        prefixIcon: const Icon(Icons.phone_outlined),
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
                        _carNumberFocus.requestFocus();
                      },
                    ),
                    SizedBox(
                      height: ResponsiveSpacing.spacing(context, base: 16),
                    ),
                    TextField(
                      controller: _carNumberController,
                      focusNode: _carNumberFocus,
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      inputFormatters: [CarPlateInputFormatter()],
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: l10n.profileCarNumberLabel,
                        hintText: l10n.profileCarNumberHint,
                        prefixIcon: const Icon(Icons.directions_car_outlined),
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
                        _carModelFocus.requestFocus();
                      },
                    ),
                    SizedBox(
                      height: ResponsiveSpacing.spacing(context, base: 16),
                    ),
                    TextField(
                      controller: _carModelController,
                      focusNode: _carModelFocus,
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: l10n.profileCarModelLabel,
                        hintText: l10n.profileCarModelHint,
                        prefixIcon: const Icon(Icons.directions_car),
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
                    SizedBox(
                      height: ResponsiveSpacing.spacing(context, base: 24),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveSpacing.spacing(
                              context,
                              base: 14,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveSpacing.borderRadius(context, base: 16),
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: ResponsiveSpacing.iconSize(
                                  context,
                                  base: 20,
                                ),
                                width: ResponsiveSpacing.iconSize(
                                  context,
                                  base: 20,
                                ),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(l10n.profileSubmitButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
