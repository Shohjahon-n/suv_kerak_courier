import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suv_kerak_courier/l10n/app_localizations.dart';

import '../../../../core/storage/app_preferences.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/responsive_spacing.dart';
import '../../../auth/presentation/widgets/car_plate_formatter.dart';
import '../../../auth/presentation/widgets/phone_input_formatter.dart';

class ProfileDataPage extends StatefulWidget {
  const ProfileDataPage({super.key});

  @override
  State<ProfileDataPage> createState() => _ProfileDataPageState();
}

class _ProfileDataPageState extends State<ProfileDataPage>
    with ErrorHandlingMixin<ProfileDataPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _carNumberController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _carNumberFocus = FocusNode();
  final FocusNode _carModelFocus = FocusNode();

  bool _isLoading = false;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

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

  Future<void> _loadProfile() async {
    final preferences = context.read<AppPreferences>();
    final courierId = preferences.readCourierId();

    if (courierId == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = context.read<Dio>();
      final response = await dio.post(
        '/couriers/check-courier-parametr/',
        data: {'kuryer_id': courierId},
      );

      final data = response.data;
      if (!mounted) return;

      if (data is Map && data['ok'] == true) {
        setState(() {
          _nameController.text = data['kuryer_name']?.toString() ?? '';
          _phoneController.text = UzPhoneInputFormatter.format(
            data['tel_num']?.toString() ?? '',
          );
          _carNumberController.text = CarPlateInputFormatter.format(
            data['avto_num']?.toString() ?? '',
          );
          _carModelController.text = data['avto_marka']?.toString() ?? '';
        });
      }
    } catch (error, stackTrace) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.profileCheckError,
        showSnackbar: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

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

    setState(() => _isSaving = true);

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

      if (!mounted) return;

      showToast(l10n.profileUpdateSuccess);
      setState(() => _isEditing = false);
    } on DioException catch (error, stackTrace) {
      if (!mounted) return;
      final detail = extractErrorDetail(error);
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: detail ?? l10n.profileSubmitError,
        showSnackbar: true,
      );
    } catch (error, stackTrace) {
      if (!mounted) return;
      handleError(
        error,
        stackTrace: stackTrace,
        customMessage: l10n.profileSubmitError,
        showSnackbar: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Cancel editing - reload original data
      _loadProfile();
    }
    setState(() => _isEditing = !_isEditing);
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
      appBar: AppBar(
        title: Text(l10n.profileDataTitle),
        actions: [
          if (!_isLoading && !_isSaving)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: _toggleEdit,
              tooltip: _isEditing ? l10n.commonCancel : l10n.profileEditButton,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: ResponsiveSpacing.pagePadding(context),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: ResponsiveSpacing.iconSize(context, base: 72),
                    color: colorScheme.primary,
                  ),
                  SizedBox(
                    height: ResponsiveSpacing.spacing(context, base: 24),
                  ),
                  TextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    enabled: _isEditing,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: l10n.profileNameLabel,
                      hintText: l10n.profileNameHint,
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: _isEditing
                          ? colorScheme.surface
                          : colorScheme.surfaceContainerHighest,
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      disabledBorder: inputBorder,
                      focusedBorder: inputBorder.copyWith(
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _phoneFocus.requestFocus(),
                  ),
                  SizedBox(
                    height: ResponsiveSpacing.spacing(context, base: 16),
                  ),
                  TextField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    enabled: _isEditing,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [UzPhoneInputFormatter()],
                    decoration: InputDecoration(
                      labelText: l10n.profilePhoneLabel,
                      hintText: l10n.profilePhoneHint,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      filled: true,
                      fillColor: _isEditing
                          ? colorScheme.surface
                          : colorScheme.surfaceContainerHighest,
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      disabledBorder: inputBorder,
                      focusedBorder: inputBorder.copyWith(
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _carNumberFocus.requestFocus(),
                  ),
                  SizedBox(
                    height: ResponsiveSpacing.spacing(context, base: 16),
                  ),
                  TextField(
                    controller: _carNumberController,
                    focusNode: _carNumberFocus,
                    enabled: _isEditing,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    inputFormatters: [CarPlateInputFormatter()],
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: l10n.profileCarNumberLabel,
                      hintText: l10n.profileCarNumberHint,
                      prefixIcon: const Icon(Icons.directions_car_outlined),
                      filled: true,
                      fillColor: _isEditing
                          ? colorScheme.surface
                          : colorScheme.surfaceContainerHighest,
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      disabledBorder: inputBorder,
                      focusedBorder: inputBorder.copyWith(
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _carModelFocus.requestFocus(),
                  ),
                  SizedBox(
                    height: ResponsiveSpacing.spacing(context, base: 16),
                  ),
                  TextField(
                    controller: _carModelController,
                    focusNode: _carModelFocus,
                    enabled: _isEditing,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: l10n.profileCarModelLabel,
                      hintText: l10n.profileCarModelHint,
                      prefixIcon: const Icon(Icons.directions_car),
                      filled: true,
                      fillColor: _isEditing
                          ? colorScheme.surface
                          : colorScheme.surfaceContainerHighest,
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      disabledBorder: inputBorder,
                      focusedBorder: inputBorder.copyWith(
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _saveProfile(),
                  ),
                  SizedBox(
                    height: ResponsiveSpacing.spacing(context, base: 24),
                  ),
                  if (_isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
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
                        child: _isSaving
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
                            : Text(l10n.profileSaveButton),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
