// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Suv Kerak Courier';

  @override
  String get homeTitle => 'Courier Dashboard';

  @override
  String get homeSubtitle => 'Ready for courier feature development.';

  @override
  String get counterLabel => 'Counter';

  @override
  String get openSettings => 'Open settings';

  @override
  String get themeLight => 'Switch to light theme';

  @override
  String get themeDark => 'Switch to dark theme';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileTitle => 'Profile';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageUzbekLatin => 'Uzbek (Latin)';

  @override
  String get languageUzbekCyrillic => 'Uzbek (Cyrillic)';

  @override
  String get languageSelectionTitle => 'Choose your language';

  @override
  String get languageSelectionSubtitle =>
      'Select the language for the courier app.';

  @override
  String get loginTitle => 'Courier Login';

  @override
  String get loginSubtitle => 'Sign in to start deliveries.';

  @override
  String get loginPlaceholder => 'Login screen is being prepared.';

  @override
  String get loginHint => 'We\'ll add phone and verification next.';

  @override
  String get loginCourierIdLabel => 'Courier ID';

  @override
  String get loginCourierIdHint => 'Enter your courier ID';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginButton => 'Log in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Update password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your courier ID to receive a code.';

  @override
  String get forgotPasswordCourierIdLabel => 'Courier ID';

  @override
  String get forgotPasswordCourierIdHint => 'Enter your courier ID';

  @override
  String get forgotPasswordStartButton => 'Update password';

  @override
  String get forgotPasswordValidationEmpty => 'Enter your courier ID.';

  @override
  String get forgotPasswordStartSuccess => 'Code sent. Check the bot.';

  @override
  String get forgotPasswordStartFailed => 'Failed to send the code.';

  @override
  String get forgotPasswordOtpTitle => 'Enter code';

  @override
  String get forgotPasswordOtpSubtitle =>
      'Enter the 4-digit code sent by the bot.';

  @override
  String get forgotPasswordOtpLabel => 'OTP code';

  @override
  String get forgotPasswordOtpHint => '4-digit code';

  @override
  String get forgotPasswordOtpButton => 'Verify';

  @override
  String get forgotPasswordOtpValidation => 'Enter the 4-digit code.';

  @override
  String get forgotPasswordOtpFailed => 'OTP verification failed.';

  @override
  String get forgotPasswordOpenBotButton => 'Go to bot';

  @override
  String get forgotPasswordOpenBotFailed => 'Unable to open the bot.';

  @override
  String get registerLink => 'Register';

  @override
  String get loginValidationEmpty => 'Enter ID and password.';

  @override
  String get loginValidationId => 'Courier ID must be numbers.';

  @override
  String get loginErrorGeneric => 'Login failed. Try again.';

  @override
  String get loginSuccess => 'Logged in successfully.';

  @override
  String get profileCompletionTitle => 'Complete your profile';

  @override
  String get profileCompletionSubtitle =>
      'Please provide the following information to continue';

  @override
  String get profileNameLabel => 'Full name';

  @override
  String get profileNameHint => 'Enter your full name';

  @override
  String get profileNameValidation => 'Enter your name';

  @override
  String get profilePhoneLabel => 'Phone number';

  @override
  String get profilePhoneHint => '+998 90 123 45 67';

  @override
  String get profilePhoneValidation => 'Enter valid Uzbek phone number';

  @override
  String get profileCarNumberLabel => 'Car plate number';

  @override
  String get profileCarNumberHint => '01 A 123 AA';

  @override
  String get profileCarNumberValidation => 'Enter valid car plate number';

  @override
  String get profileCarModelLabel => 'Car model';

  @override
  String get profileCarModelHint => 'e.g., Chevrolet Lacetti';

  @override
  String get profileCarModelValidation => 'Enter car model';

  @override
  String get profileSubmitButton => 'Submit';

  @override
  String get profileCheckError => 'Failed to check profile status';

  @override
  String get profileSubmitError => 'Failed to submit profile information';

  @override
  String get profileSubmitSuccess => 'Profile completed successfully';

  @override
  String get comingSoon => 'Coming soon.';

  @override
  String get refreshLabel => 'Refresh';

  @override
  String get offlineRetryMessage => 'Wi-Fi unavailable. Please try again.';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonBack => 'Back';

  @override
  String get homeEmptyState => 'No data yet.';

  @override
  String get homeCourierIdMissing => 'Courier ID not found.';

  @override
  String get homeUnexpectedResponse => 'Unexpected response.';

  @override
  String get homeRequestFailed => 'Request failed.';

  @override
  String get homeCourierIdLabel => 'Courier ID';

  @override
  String get homeLastActiveLabel => 'Last active';

  @override
  String get homeCashBalanceLabel => 'Cash balance';

  @override
  String get homeFullWaterLabel => 'Full water remaining';

  @override
  String get homeEmptyBottleLabel => 'Empty bottles';

  @override
  String get homeOrdersTodayLabel => 'Completed today';

  @override
  String get notAvailable => 'Not available';

  @override
  String get mainMenuTitle => 'Main menu';

  @override
  String get menuCourierService => 'Courier service accounting';

  @override
  String get menuOrders => 'Orders';

  @override
  String get ordersQuickActionsTitle => 'Quick actions';

  @override
  String get ordersPendingButton => 'Uncompleted orders';

  @override
  String get ordersCompletedTodayButton => 'Today\'s completed orders';

  @override
  String get ordersMapButton => 'Show orders on map';

  @override
  String get ordersPeriodicReportTitle => 'Periodic completed orders report';

  @override
  String get ordersPendingTitle => 'Uncompleted orders';

  @override
  String get ordersSummaryTitle => 'Summary';

  @override
  String get ordersCountLabel => 'Orders count';

  @override
  String get ordersTotalWaterLabel => 'Total water';

  @override
  String get ordersOrderIdLabel => 'Order number';

  @override
  String get ordersBuyerIdLabel => 'Buyer ID';

  @override
  String get ordersNoteLabel => 'Note';

  @override
  String get ordersWaterCountLabel => 'Water count';

  @override
  String get ordersPaymentStatusLabel => 'Payment status';

  @override
  String get ordersLocationLabel => 'Location';

  @override
  String get ordersAddressLabel => 'Address';

  @override
  String get ordersEmptyState => 'No orders yet.';

  @override
  String get ordersSessionMissing => 'Business ID not found.';

  @override
  String get ordersLoadFailed => 'Failed to load orders.';

  @override
  String get ordersLocationServiceDisabled => 'Location services are disabled.';

  @override
  String get ordersLocationPermissionDenied =>
      'Location permission is required to show your position.';

  @override
  String get ordersLocationPermissionPermanentlyDenied =>
      'Enable location permission in settings to show your position.';

  @override
  String get ordersLocationUnavailable => 'Unable to get your location.';

  @override
  String get ordersCourierLabel => 'You';

  @override
  String get ordersCourierTitle => 'Your location';

  @override
  String get ordersCourierSubtitle => 'Showing your current position.';

  @override
  String get ordersMapFindMe => 'Find me';

  @override
  String get ordersMapGoButton => 'Go';

  @override
  String get ordersRouteFailed => 'Failed to build route.';

  @override
  String get ordersMapFollowHeading => 'Follow heading';

  @override
  String get ordersMapFollowHeadingOff => 'Stop following';

  @override
  String get ordersMapNavigationTitle => 'Navigation';

  @override
  String get ordersMapUpdatingRoute => 'Updating route...';

  @override
  String get ordersMapStopButton => 'Stop';

  @override
  String get ordersMapUnitKilometer => 'km';

  @override
  String get ordersMapUnitMeter => 'm';

  @override
  String get ordersMapUnitMinute => 'min';

  @override
  String get ordersMapUnitHour => 'h';

  @override
  String get ordersMapTitle => 'Map view';

  @override
  String get ordersMapOnWayOrderLoadFailed =>
      'Failed to load the active order.';

  @override
  String get ordersMapArrivedHintFailed =>
      'Failed to send arrival notification.';

  @override
  String get ordersMapSetOnWayFailed =>
      'Failed to mark the order as on the way.';

  @override
  String get ordersMapOrderDetailsLoadFailed => 'Failed to load order details.';

  @override
  String get ordersMapCompleteOrderFailed => 'Failed to complete the order.';

  @override
  String get ordersMapOpenCallFailed => 'Unable to open the call app.';

  @override
  String get ordersMapArrivedDialogTitle => 'Have you arrived?';

  @override
  String ordersMapArrivedAutoClose(Object seconds) {
    return 'Closes automatically in $seconds seconds.';
  }

  @override
  String get ordersMapOrderDetailsTitle => 'Order details';

  @override
  String get ordersMapWaterPriceLabel => 'Water price';

  @override
  String get ordersMapWaterLabel => 'Water';

  @override
  String get ordersMapSoldBottleLabel => 'Sold containers';

  @override
  String get ordersMapTotalLabel => 'Total';

  @override
  String get ordersMapPaymentAcceptedOnline => 'Accepted (Online payment)';

  @override
  String get ordersMapAcceptPayment => 'Accept payment';

  @override
  String get ordersMapSelectOrder => 'Select an order';

  @override
  String ordersMapTakeOrder(Object orderNum) {
    return 'Take order $orderNum';
  }

  @override
  String ordersMapArrivedButton(Object orderNum) {
    return 'Arrived for order $orderNum';
  }

  @override
  String get ordersMapOnWayButton => 'I\'m on my way';

  @override
  String get ordersMapFoundButton => 'Found';

  @override
  String get ordersMapNotFoundButton => 'Not found';

  @override
  String ordersMapOrderSummary(Object orderNum, Object waterCount) {
    return 'Order: $orderNum, Water: $waterCount';
  }

  @override
  String get ordersMapConfirmCompletedTitle => 'Completed?';

  @override
  String get ordersMapLocationServiceDisabled => 'Location service is disabled';

  @override
  String get ordersMapLocationPermissionDenied => 'Location permission denied';

  @override
  String get ordersMapLocationPermissionDeniedForever =>
      'Location permission denied forever (enable in Settings)';

  @override
  String get ordersMapSessionError => 'Session not found';

  @override
  String get ordersMapUrlNotFound => 'Map URL not found';

  @override
  String get ordersMapLoadError => 'Failed to load map';

  @override
  String get menuCashReport => 'Cash report';

  @override
  String get menuBottleBalance => 'Water and Bottle Balance';

  @override
  String get bottleBalanceEmptyPeriodicTitle => 'Periodic empty bottle report';

  @override
  String get bottleBalanceFullWaterPeriodicTitle =>
      'Periodic full water report';

  @override
  String get bottleBalanceSummaryTitle => 'Summary';

  @override
  String get bottleBalanceOperationsTitle => 'Operations';

  @override
  String get bottleBalanceOpeningBalanceLabel => 'Opening bottle balance';

  @override
  String get bottleBalanceClosingBalanceLabel => 'Closing bottle balance';

  @override
  String get bottleBalanceTotalIncomeLabel => 'Total bottles in';

  @override
  String get bottleBalanceTotalExpenseLabel => 'Total bottles out';

  @override
  String get bottleBalanceIncomeLabel => 'In';

  @override
  String get bottleBalanceExpenseLabel => 'Out';

  @override
  String get bottleBalanceBalanceLabel => 'Balance';

  @override
  String get fullWaterOpeningBalanceLabel => 'Opening full water balance';

  @override
  String get fullWaterClosingBalanceLabel => 'Closing full water balance';

  @override
  String get fullWaterTotalIncomeLabel => 'Total full water in';

  @override
  String get fullWaterTotalExpenseLabel => 'Total full water out';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuSecurity => 'Security';

  @override
  String get menuAbout => 'About system';

  @override
  String get aboutDescription =>
      '\"Suv Kerak\" is a professional courier application, part of the \"Hisob\" business automation platform. Our company specializes in digitalization and automation of business processes for entrepreneurs in various industries.\n\nThis app helps water distribution businesses streamline order management, delivery tracking, and financial reporting with modern technology solutions.';

  @override
  String get aboutShareButton => 'Share';

  @override
  String get aboutUpdateButton => 'Update';

  @override
  String get aboutVersionLabel => 'Version';

  @override
  String get aboutShareMessage => 'Try the Suv Kerak Courier app.';

  @override
  String get aboutUpdateUnavailable => 'Update link not available.';

  @override
  String get aboutShareUnavailable => 'Share link not available.';

  @override
  String homeDevelopedBy(Object version) {
    return 'Developed by Hisob Company v$version';
  }

  @override
  String get cashReportPeriodicTitle => 'Periodic cash report';

  @override
  String get cashReportOnlineTitle => 'Online payments';

  @override
  String get cashReportStartDate => 'Start date';

  @override
  String get cashReportEndDate => 'End date';

  @override
  String get cashReportPickDate => 'Select date';

  @override
  String get cashReportShow => 'Show';

  @override
  String get cashReportValidationRequired => 'Select start and end dates.';

  @override
  String get cashReportValidationOrder => 'Start date must be before end date.';

  @override
  String get cashReportRangeLabel => 'Period';

  @override
  String get cashReportApiNotReady => 'API is not connected yet.';

  @override
  String get cashReportEmptyResult => 'No data for the selected period.';

  @override
  String get cashReportRetry => 'Retry';

  @override
  String get cashReportSessionMissing => 'Courier session not found.';

  @override
  String get cashReportSummaryTitle => 'Summary';

  @override
  String get cashReportOpeningBalanceLabel => 'Opening balance';

  @override
  String get cashReportClosingBalanceLabel => 'Closing balance';

  @override
  String get cashReportTotalIncomeLabel => 'Total income';

  @override
  String get cashReportTotalExpenseLabel => 'Total expense';

  @override
  String get cashReportOperationsTitle => 'Operations';

  @override
  String get cashReportIncomeLabel => 'Income';

  @override
  String get cashReportExpenseLabel => 'Expense';

  @override
  String get cashReportBalanceLabel => 'Balance';

  @override
  String get cashReportTotalAmountLabel => 'Total amount';

  @override
  String get cashReportPaymentsTitle => 'Payments';

  @override
  String get cashReportOrderLabel => 'Order';

  @override
  String get cashReportBuyerLabel => 'Buyer';

  @override
  String get cashReportPaymentSystemLabel => 'Payment system';

  @override
  String get cashReportAmountLabel => 'Amount';

  @override
  String get themeModeTitle => 'Theme mode';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get profileDataTitle => 'Profile Data';

  @override
  String get profileEditButton => 'Edit';

  @override
  String get profileSaveButton => 'Save Changes';

  @override
  String get profileUpdateSuccess => 'Profile updated successfully';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get logoutButton => 'Log out';

  @override
  String get securityTitle => 'Security';

  @override
  String get securityPinTitle => 'PIN code login';

  @override
  String get securityBiometricTitle => 'Biometric login';

  @override
  String get securityChangePasswordTitle => 'Change password';

  @override
  String get securityChangePinTitle => 'Change PIN';

  @override
  String get securityOldPasswordLabel => 'Current password';

  @override
  String get securityNewPasswordLabel => 'New password';

  @override
  String get securityConfirmPasswordLabel => 'Confirm password';

  @override
  String get securityOldPinLabel => 'Current PIN';

  @override
  String get securityNewPinLabel => 'New PIN';

  @override
  String get securityConfirmPinLabel => 'Confirm PIN';

  @override
  String get securityUpdateButton => 'Update';

  @override
  String get securityValidationRequired => 'Fill out all fields.';

  @override
  String get securityValidationMismatch => 'New values do not match.';

  @override
  String get securityApiNotReady => 'API is not connected yet.';

  @override
  String get securitySessionMissing => 'Courier session not found.';

  @override
  String get securityPasswordUpdated => 'Password updated successfully.';

  @override
  String get securityPasswordUpdateFailed => 'Password update failed.';

  @override
  String get securityPinUpdated => 'PIN updated successfully.';

  @override
  String get securityPinUpdateFailed => 'PIN update failed.';

  @override
  String get pinSetupTitle => 'Create PIN';

  @override
  String get pinSetupSubtitle => 'Choose a 4-digit PIN.';

  @override
  String get pinSetupLabel => 'PIN';

  @override
  String get pinSetupConfirmLabel => 'Confirm PIN';

  @override
  String get pinSetupSave => 'Save';

  @override
  String get pinSetupCancel => 'Cancel';

  @override
  String get pinSetupErrorLength => 'PIN must be 4 digits.';

  @override
  String get pinSetupErrorMismatch => 'PINs do not match.';

  @override
  String get pinUnlockTitle => 'Enter PIN';

  @override
  String get pinUnlockSubtitle => 'Enter your PIN to continue.';

  @override
  String get pinUnlockButton => 'Unlock';

  @override
  String get pinUnlockError => 'Incorrect PIN.';

  @override
  String get biometricButton => 'Use biometrics';

  @override
  String get biometricReason => 'Authenticate to unlock.';

  @override
  String get biometricUnavailable => 'Biometrics not available on this device.';

  @override
  String get biometricFailed => 'Biometric authentication failed.';

  @override
  String get changePinButton => 'Change PIN';

  @override
  String get changePinTitle => 'Change PIN';

  @override
  String get pinChangeOldLabel => 'Enter current PIN';

  @override
  String get pinChangeNewLabel => 'Enter new PIN';

  @override
  String get pinChangeSuccess => 'PIN changed successfully.';

  @override
  String get pinChangeError => 'Failed to change PIN. Check your current PIN.';

  @override
  String get pinChangeSameError =>
      'New PIN must be different from current PIN.';

  @override
  String get courierServiceTitle => 'Courier Service Statement';

  @override
  String get courierServiceSelectRange => 'Select date range';

  @override
  String get courierServiceSelectButton => 'Select period';

  @override
  String get courierServiceSelectPrompt =>
      'Please select a date range to view the report.';

  @override
  String get courierServiceStartBalance => 'Opening balance';

  @override
  String get courierServiceEndBalance => 'Closing balance';

  @override
  String get courierServiceTotalChargedLabel => 'Total charged';

  @override
  String get courierServiceTotalPaidLabel => 'Total paid';

  @override
  String get courierServiceBalanceLabel => 'Balance';

  @override
  String get courierServiceOperationsTitle => 'Service operations';

  @override
  String get courierServiceOrderNumber => 'Order number';

  @override
  String get courierServiceCharged => 'Charged';

  @override
  String get courierServicePaid => 'Paid';

  @override
  String get courierServiceCount => 'Water count';
}
