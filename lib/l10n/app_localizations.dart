import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Suv Kerak Courier'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Courier Dashboard'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for courier feature development.'**
  String get homeSubtitle;

  /// No description provided for @counterLabel.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counterLabel;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Switch to light theme'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get themeDark;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageUzbekLatin.
  ///
  /// In en, this message translates to:
  /// **'Uzbek (Latin)'**
  String get languageUzbekLatin;

  /// No description provided for @languageUzbekCyrillic.
  ///
  /// In en, this message translates to:
  /// **'Uzbek (Cyrillic)'**
  String get languageUzbekCyrillic;

  /// No description provided for @languageSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageSelectionTitle;

  /// No description provided for @languageSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the language for the courier app.'**
  String get languageSelectionSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Courier Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to start deliveries.'**
  String get loginSubtitle;

  /// No description provided for @loginPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Login screen is being prepared.'**
  String get loginPlaceholder;

  /// No description provided for @loginHint.
  ///
  /// In en, this message translates to:
  /// **'We\'ll add phone and verification next.'**
  String get loginHint;

  /// No description provided for @loginCourierIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Courier ID'**
  String get loginCourierIdLabel;

  /// No description provided for @loginCourierIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your courier ID'**
  String get loginCourierIdHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your courier ID to receive a code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordCourierIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Courier ID'**
  String get forgotPasswordCourierIdLabel;

  /// No description provided for @forgotPasswordCourierIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your courier ID'**
  String get forgotPasswordCourierIdHint;

  /// No description provided for @forgotPasswordStartButton.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get forgotPasswordStartButton;

  /// No description provided for @forgotPasswordValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your courier ID.'**
  String get forgotPasswordValidationEmpty;

  /// No description provided for @forgotPasswordStartSuccess.
  ///
  /// In en, this message translates to:
  /// **'Code sent. Check the bot.'**
  String get forgotPasswordStartSuccess;

  /// No description provided for @forgotPasswordStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send the code.'**
  String get forgotPasswordStartFailed;

  /// No description provided for @forgotPasswordOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get forgotPasswordOtpTitle;

  /// No description provided for @forgotPasswordOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code sent by the bot.'**
  String get forgotPasswordOtpSubtitle;

  /// No description provided for @forgotPasswordOtpLabel.
  ///
  /// In en, this message translates to:
  /// **'OTP code'**
  String get forgotPasswordOtpLabel;

  /// No description provided for @forgotPasswordOtpHint.
  ///
  /// In en, this message translates to:
  /// **'4-digit code'**
  String get forgotPasswordOtpHint;

  /// No description provided for @forgotPasswordOtpButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get forgotPasswordOtpButton;

  /// No description provided for @forgotPasswordOtpValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code.'**
  String get forgotPasswordOtpValidation;

  /// No description provided for @forgotPasswordOtpFailed.
  ///
  /// In en, this message translates to:
  /// **'OTP verification failed.'**
  String get forgotPasswordOtpFailed;

  /// No description provided for @forgotPasswordOpenBotButton.
  ///
  /// In en, this message translates to:
  /// **'Go to bot'**
  String get forgotPasswordOpenBotButton;

  /// No description provided for @forgotPasswordOpenBotFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the bot.'**
  String get forgotPasswordOpenBotFailed;

  /// No description provided for @registerLink.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerLink;

  /// No description provided for @loginValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter ID and password.'**
  String get loginValidationEmpty;

  /// No description provided for @loginValidationId.
  ///
  /// In en, this message translates to:
  /// **'Courier ID must be numbers.'**
  String get loginValidationId;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Try again.'**
  String get loginErrorGeneric;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully.'**
  String get loginSuccess;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon.'**
  String get comingSoon;

  /// No description provided for @refreshLabel.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshLabel;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @homeEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No data yet.'**
  String get homeEmptyState;

  /// No description provided for @homeCourierIdMissing.
  ///
  /// In en, this message translates to:
  /// **'Courier ID not found.'**
  String get homeCourierIdMissing;

  /// No description provided for @homeUnexpectedResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response.'**
  String get homeUnexpectedResponse;

  /// No description provided for @homeRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed.'**
  String get homeRequestFailed;

  /// No description provided for @homeCourierIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Courier ID'**
  String get homeCourierIdLabel;

  /// No description provided for @homeLastActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Last active'**
  String get homeLastActiveLabel;

  /// No description provided for @homeCashBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash balance'**
  String get homeCashBalanceLabel;

  /// No description provided for @homeFullWaterLabel.
  ///
  /// In en, this message translates to:
  /// **'Full water remaining'**
  String get homeFullWaterLabel;

  /// No description provided for @homeEmptyBottleLabel.
  ///
  /// In en, this message translates to:
  /// **'Empty bottles'**
  String get homeEmptyBottleLabel;

  /// No description provided for @homeOrdersTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed today'**
  String get homeOrdersTodayLabel;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @mainMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Main menu'**
  String get mainMenuTitle;

  /// No description provided for @menuCourierService.
  ///
  /// In en, this message translates to:
  /// **'Courier service accounting'**
  String get menuCourierService;

  /// No description provided for @menuOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get menuOrders;

  /// No description provided for @ordersQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get ordersQuickActionsTitle;

  /// No description provided for @ordersPendingButton.
  ///
  /// In en, this message translates to:
  /// **'Uncompleted orders'**
  String get ordersPendingButton;

  /// No description provided for @ordersCompletedTodayButton.
  ///
  /// In en, this message translates to:
  /// **'Today\'s completed orders'**
  String get ordersCompletedTodayButton;

  /// No description provided for @ordersMapButton.
  ///
  /// In en, this message translates to:
  /// **'Show orders on map'**
  String get ordersMapButton;

  /// No description provided for @ordersPeriodicReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Periodic completed orders report'**
  String get ordersPeriodicReportTitle;

  /// No description provided for @ordersPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Uncompleted orders'**
  String get ordersPendingTitle;

  /// No description provided for @ordersSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get ordersSummaryTitle;

  /// No description provided for @ordersCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders count'**
  String get ordersCountLabel;

  /// No description provided for @ordersTotalWaterLabel.
  ///
  /// In en, this message translates to:
  /// **'Total water'**
  String get ordersTotalWaterLabel;

  /// No description provided for @ordersOrderIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get ordersOrderIdLabel;

  /// No description provided for @ordersBuyerIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer ID'**
  String get ordersBuyerIdLabel;

  /// No description provided for @ordersNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get ordersNoteLabel;

  /// No description provided for @ordersWaterCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Water count'**
  String get ordersWaterCountLabel;

  /// No description provided for @ordersPaymentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get ordersPaymentStatusLabel;

  /// No description provided for @ordersLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get ordersLocationLabel;

  /// No description provided for @ordersAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get ordersAddressLabel;

  /// No description provided for @ordersEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No orders yet.'**
  String get ordersEmptyState;

  /// No description provided for @ordersSessionMissing.
  ///
  /// In en, this message translates to:
  /// **'Business ID not found.'**
  String get ordersSessionMissing;

  /// No description provided for @ordersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders.'**
  String get ordersLoadFailed;

  /// No description provided for @ordersLocationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get ordersLocationServiceDisabled;

  /// No description provided for @ordersLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to show your position.'**
  String get ordersLocationPermissionDenied;

  /// No description provided for @ordersLocationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Enable location permission in settings to show your position.'**
  String get ordersLocationPermissionPermanentlyDenied;

  /// No description provided for @ordersLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to get your location.'**
  String get ordersLocationUnavailable;

  /// No description provided for @ordersCourierLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get ordersCourierLabel;

  /// No description provided for @ordersCourierTitle.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get ordersCourierTitle;

  /// No description provided for @ordersCourierSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Showing your current position.'**
  String get ordersCourierSubtitle;

  /// No description provided for @ordersMapFindMe.
  ///
  /// In en, this message translates to:
  /// **'Find me'**
  String get ordersMapFindMe;

  /// No description provided for @ordersMapGoButton.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get ordersMapGoButton;

  /// No description provided for @ordersRouteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to build route.'**
  String get ordersRouteFailed;

  /// No description provided for @ordersMapFollowHeading.
  ///
  /// In en, this message translates to:
  /// **'Follow heading'**
  String get ordersMapFollowHeading;

  /// No description provided for @ordersMapFollowHeadingOff.
  ///
  /// In en, this message translates to:
  /// **'Stop following'**
  String get ordersMapFollowHeadingOff;

  /// No description provided for @ordersMapNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get ordersMapNavigationTitle;

  /// No description provided for @ordersMapUpdatingRoute.
  ///
  /// In en, this message translates to:
  /// **'Updating route...'**
  String get ordersMapUpdatingRoute;

  /// No description provided for @ordersMapStopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get ordersMapStopButton;

  /// No description provided for @ordersMapUnitKilometer.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get ordersMapUnitKilometer;

  /// No description provided for @ordersMapUnitMeter.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get ordersMapUnitMeter;

  /// No description provided for @ordersMapUnitMinute.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get ordersMapUnitMinute;

  /// No description provided for @ordersMapUnitHour.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get ordersMapUnitHour;

  /// No description provided for @ordersMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map view'**
  String get ordersMapTitle;

  /// No description provided for @ordersMapOnWayOrderLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the active order.'**
  String get ordersMapOnWayOrderLoadFailed;

  /// No description provided for @ordersMapArrivedHintFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send arrival notification.'**
  String get ordersMapArrivedHintFailed;

  /// No description provided for @ordersMapSetOnWayFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark the order as on the way.'**
  String get ordersMapSetOnWayFailed;

  /// No description provided for @ordersMapOrderDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load order details.'**
  String get ordersMapOrderDetailsLoadFailed;

  /// No description provided for @ordersMapCompleteOrderFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete the order.'**
  String get ordersMapCompleteOrderFailed;

  /// No description provided for @ordersMapOpenCallFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the call app.'**
  String get ordersMapOpenCallFailed;

  /// No description provided for @ordersMapArrivedDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Have you arrived?'**
  String get ordersMapArrivedDialogTitle;

  /// No description provided for @ordersMapArrivedAutoClose.
  ///
  /// In en, this message translates to:
  /// **'Closes automatically in {seconds} seconds.'**
  String ordersMapArrivedAutoClose(Object seconds);

  /// No description provided for @ordersMapOrderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get ordersMapOrderDetailsTitle;

  /// No description provided for @ordersMapWaterPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Water price'**
  String get ordersMapWaterPriceLabel;

  /// No description provided for @ordersMapWaterLabel.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get ordersMapWaterLabel;

  /// No description provided for @ordersMapSoldBottleLabel.
  ///
  /// In en, this message translates to:
  /// **'Sold containers'**
  String get ordersMapSoldBottleLabel;

  /// No description provided for @ordersMapTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ordersMapTotalLabel;

  /// No description provided for @ordersMapPaymentAcceptedOnline.
  ///
  /// In en, this message translates to:
  /// **'Accepted (Online payment)'**
  String get ordersMapPaymentAcceptedOnline;

  /// No description provided for @ordersMapAcceptPayment.
  ///
  /// In en, this message translates to:
  /// **'Accept payment'**
  String get ordersMapAcceptPayment;

  /// No description provided for @ordersMapSelectOrder.
  ///
  /// In en, this message translates to:
  /// **'Select an order'**
  String get ordersMapSelectOrder;

  /// No description provided for @ordersMapTakeOrder.
  ///
  /// In en, this message translates to:
  /// **'Take order {orderNum}'**
  String ordersMapTakeOrder(Object orderNum);

  /// No description provided for @ordersMapArrivedButton.
  ///
  /// In en, this message translates to:
  /// **'Arrived for order {orderNum}'**
  String ordersMapArrivedButton(Object orderNum);

  /// No description provided for @ordersMapOnWayButton.
  ///
  /// In en, this message translates to:
  /// **'I\'m on my way'**
  String get ordersMapOnWayButton;

  /// No description provided for @ordersMapFoundButton.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get ordersMapFoundButton;

  /// No description provided for @ordersMapNotFoundButton.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get ordersMapNotFoundButton;

  /// No description provided for @ordersMapOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order: {orderNum}, Water: {waterCount}'**
  String ordersMapOrderSummary(Object orderNum, Object waterCount);

  /// No description provided for @ordersMapConfirmCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed?'**
  String get ordersMapConfirmCompletedTitle;

  /// No description provided for @ordersMapLocationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location service is disabled'**
  String get ordersMapLocationServiceDisabled;

  /// No description provided for @ordersMapLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get ordersMapLocationPermissionDenied;

  /// No description provided for @ordersMapLocationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied forever (enable in Settings)'**
  String get ordersMapLocationPermissionDeniedForever;

  /// No description provided for @ordersMapSessionError.
  ///
  /// In en, this message translates to:
  /// **'Session not found'**
  String get ordersMapSessionError;

  /// No description provided for @ordersMapUrlNotFound.
  ///
  /// In en, this message translates to:
  /// **'Map URL not found'**
  String get ordersMapUrlNotFound;

  /// No description provided for @ordersMapLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load map'**
  String get ordersMapLoadError;

  /// No description provided for @menuCashReport.
  ///
  /// In en, this message translates to:
  /// **'Cash report'**
  String get menuCashReport;

  /// No description provided for @menuBottleBalance.
  ///
  /// In en, this message translates to:
  /// **'Water and Bottle Balance'**
  String get menuBottleBalance;

  /// No description provided for @bottleBalanceEmptyPeriodicTitle.
  ///
  /// In en, this message translates to:
  /// **'Periodic empty bottle report'**
  String get bottleBalanceEmptyPeriodicTitle;

  /// No description provided for @bottleBalanceFullWaterPeriodicTitle.
  ///
  /// In en, this message translates to:
  /// **'Periodic full water report'**
  String get bottleBalanceFullWaterPeriodicTitle;

  /// No description provided for @bottleBalanceSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get bottleBalanceSummaryTitle;

  /// No description provided for @bottleBalanceOperationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get bottleBalanceOperationsTitle;

  /// No description provided for @bottleBalanceOpeningBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening bottle balance'**
  String get bottleBalanceOpeningBalanceLabel;

  /// No description provided for @bottleBalanceClosingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Closing bottle balance'**
  String get bottleBalanceClosingBalanceLabel;

  /// No description provided for @bottleBalanceTotalIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total bottles in'**
  String get bottleBalanceTotalIncomeLabel;

  /// No description provided for @bottleBalanceTotalExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Total bottles out'**
  String get bottleBalanceTotalExpenseLabel;

  /// No description provided for @bottleBalanceIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get bottleBalanceIncomeLabel;

  /// No description provided for @bottleBalanceExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get bottleBalanceExpenseLabel;

  /// No description provided for @bottleBalanceBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get bottleBalanceBalanceLabel;

  /// No description provided for @fullWaterOpeningBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening full water balance'**
  String get fullWaterOpeningBalanceLabel;

  /// No description provided for @fullWaterClosingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Closing full water balance'**
  String get fullWaterClosingBalanceLabel;

  /// No description provided for @fullWaterTotalIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total full water in'**
  String get fullWaterTotalIncomeLabel;

  /// No description provided for @fullWaterTotalExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Total full water out'**
  String get fullWaterTotalExpenseLabel;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get menuSecurity;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About system'**
  String get menuAbout;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'\"Suv Kerak\" is a professional courier application, part of the \"Hisob\" business automation platform. Our company specializes in digitalization and automation of business processes for entrepreneurs in various industries.\n\nThis app helps water distribution businesses streamline order management, delivery tracking, and financial reporting with modern technology solutions.'**
  String get aboutDescription;

  /// No description provided for @aboutShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get aboutShareButton;

  /// No description provided for @aboutUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get aboutUpdateButton;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersionLabel;

  /// No description provided for @aboutShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Try the Suv Kerak Courier app.'**
  String get aboutShareMessage;

  /// No description provided for @aboutUpdateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Update link not available.'**
  String get aboutUpdateUnavailable;

  /// No description provided for @aboutShareUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Share link not available.'**
  String get aboutShareUnavailable;

  /// No description provided for @homeDevelopedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by Hisob Company v{version}'**
  String homeDevelopedBy(Object version);

  /// No description provided for @cashReportPeriodicTitle.
  ///
  /// In en, this message translates to:
  /// **'Periodic cash report'**
  String get cashReportPeriodicTitle;

  /// No description provided for @cashReportOnlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Online payments'**
  String get cashReportOnlineTitle;

  /// No description provided for @cashReportStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get cashReportStartDate;

  /// No description provided for @cashReportEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get cashReportEndDate;

  /// No description provided for @cashReportPickDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get cashReportPickDate;

  /// No description provided for @cashReportShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get cashReportShow;

  /// No description provided for @cashReportValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Select start and end dates.'**
  String get cashReportValidationRequired;

  /// No description provided for @cashReportValidationOrder.
  ///
  /// In en, this message translates to:
  /// **'Start date must be before end date.'**
  String get cashReportValidationOrder;

  /// No description provided for @cashReportRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get cashReportRangeLabel;

  /// No description provided for @cashReportApiNotReady.
  ///
  /// In en, this message translates to:
  /// **'API is not connected yet.'**
  String get cashReportApiNotReady;

  /// No description provided for @cashReportEmptyResult.
  ///
  /// In en, this message translates to:
  /// **'No data for the selected period.'**
  String get cashReportEmptyResult;

  /// No description provided for @cashReportRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get cashReportRetry;

  /// No description provided for @cashReportSessionMissing.
  ///
  /// In en, this message translates to:
  /// **'Courier session not found.'**
  String get cashReportSessionMissing;

  /// No description provided for @cashReportSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get cashReportSummaryTitle;

  /// No description provided for @cashReportOpeningBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get cashReportOpeningBalanceLabel;

  /// No description provided for @cashReportClosingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Closing balance'**
  String get cashReportClosingBalanceLabel;

  /// No description provided for @cashReportTotalIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get cashReportTotalIncomeLabel;

  /// No description provided for @cashReportTotalExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Total expense'**
  String get cashReportTotalExpenseLabel;

  /// No description provided for @cashReportOperationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get cashReportOperationsTitle;

  /// No description provided for @cashReportIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get cashReportIncomeLabel;

  /// No description provided for @cashReportExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get cashReportExpenseLabel;

  /// No description provided for @cashReportBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get cashReportBalanceLabel;

  /// No description provided for @cashReportTotalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get cashReportTotalAmountLabel;

  /// No description provided for @cashReportPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get cashReportPaymentsTitle;

  /// No description provided for @cashReportOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get cashReportOrderLabel;

  /// No description provided for @cashReportBuyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get cashReportBuyerLabel;

  /// No description provided for @cashReportPaymentSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment system'**
  String get cashReportPaymentSystemLabel;

  /// No description provided for @cashReportAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get cashReportAmountLabel;

  /// No description provided for @themeModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeModeTitle;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutButton;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityTitle;

  /// No description provided for @securityPinTitle.
  ///
  /// In en, this message translates to:
  /// **'PIN code login'**
  String get securityPinTitle;

  /// No description provided for @securityBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric login'**
  String get securityBiometricTitle;

  /// No description provided for @securityChangePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get securityChangePasswordTitle;

  /// No description provided for @securityChangePinTitle.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get securityChangePinTitle;

  /// No description provided for @securityOldPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get securityOldPasswordLabel;

  /// No description provided for @securityNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get securityNewPasswordLabel;

  /// No description provided for @securityConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get securityConfirmPasswordLabel;

  /// No description provided for @securityOldPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Current PIN'**
  String get securityOldPinLabel;

  /// No description provided for @securityNewPinLabel.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get securityNewPinLabel;

  /// No description provided for @securityConfirmPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get securityConfirmPinLabel;

  /// No description provided for @securityUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get securityUpdateButton;

  /// No description provided for @securityValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Fill out all fields.'**
  String get securityValidationRequired;

  /// No description provided for @securityValidationMismatch.
  ///
  /// In en, this message translates to:
  /// **'New values do not match.'**
  String get securityValidationMismatch;

  /// No description provided for @securityApiNotReady.
  ///
  /// In en, this message translates to:
  /// **'API is not connected yet.'**
  String get securityApiNotReady;

  /// No description provided for @securitySessionMissing.
  ///
  /// In en, this message translates to:
  /// **'Courier session not found.'**
  String get securitySessionMissing;

  /// No description provided for @securityPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get securityPasswordUpdated;

  /// No description provided for @securityPasswordUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Password update failed.'**
  String get securityPasswordUpdateFailed;

  /// No description provided for @securityPinUpdated.
  ///
  /// In en, this message translates to:
  /// **'PIN updated successfully.'**
  String get securityPinUpdated;

  /// No description provided for @securityPinUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'PIN update failed.'**
  String get securityPinUpdateFailed;

  /// No description provided for @pinSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get pinSetupTitle;

  /// No description provided for @pinSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a 4-digit PIN.'**
  String get pinSetupSubtitle;

  /// No description provided for @pinSetupLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinSetupLabel;

  /// No description provided for @pinSetupConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get pinSetupConfirmLabel;

  /// No description provided for @pinSetupSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get pinSetupSave;

  /// No description provided for @pinSetupCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pinSetupCancel;

  /// No description provided for @pinSetupErrorLength.
  ///
  /// In en, this message translates to:
  /// **'PIN must be 4 digits.'**
  String get pinSetupErrorLength;

  /// No description provided for @pinSetupErrorMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match.'**
  String get pinSetupErrorMismatch;

  /// No description provided for @pinUnlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get pinUnlockTitle;

  /// No description provided for @pinUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to continue.'**
  String get pinUnlockSubtitle;

  /// No description provided for @pinUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get pinUnlockButton;

  /// No description provided for @pinUnlockError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN.'**
  String get pinUnlockError;

  /// No description provided for @biometricButton.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get biometricButton;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to unlock.'**
  String get biometricReason;

  /// No description provided for @biometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available on this device.'**
  String get biometricUnavailable;

  /// No description provided for @biometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed.'**
  String get biometricFailed;

  /// No description provided for @changePinButton.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePinButton;

  /// No description provided for @changePinTitle.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePinTitle;

  /// No description provided for @pinChangeOldLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter current PIN'**
  String get pinChangeOldLabel;

  /// No description provided for @pinChangeNewLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN'**
  String get pinChangeNewLabel;

  /// No description provided for @pinChangeSuccess.
  ///
  /// In en, this message translates to:
  /// **'PIN changed successfully.'**
  String get pinChangeSuccess;

  /// No description provided for @pinChangeError.
  ///
  /// In en, this message translates to:
  /// **'Failed to change PIN. Check your current PIN.'**
  String get pinChangeError;

  /// No description provided for @pinChangeSameError.
  ///
  /// In en, this message translates to:
  /// **'New PIN must be different from current PIN.'**
  String get pinChangeSameError;

  /// No description provided for @courierServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Courier Service Statement'**
  String get courierServiceTitle;

  /// No description provided for @courierServiceSelectRange.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get courierServiceSelectRange;

  /// No description provided for @courierServiceSelectButton.
  ///
  /// In en, this message translates to:
  /// **'Select period'**
  String get courierServiceSelectButton;

  /// No description provided for @courierServiceSelectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select a date range to view the report.'**
  String get courierServiceSelectPrompt;

  /// No description provided for @courierServiceStartBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get courierServiceStartBalance;

  /// No description provided for @courierServiceEndBalance.
  ///
  /// In en, this message translates to:
  /// **'Closing balance'**
  String get courierServiceEndBalance;

  /// No description provided for @courierServiceOperationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Service operations'**
  String get courierServiceOperationsTitle;

  /// No description provided for @courierServiceOrderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get courierServiceOrderNumber;

  /// No description provided for @courierServiceCharged.
  ///
  /// In en, this message translates to:
  /// **'Charged'**
  String get courierServiceCharged;

  /// No description provided for @courierServicePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get courierServicePaid;

  /// No description provided for @courierServiceCount.
  ///
  /// In en, this message translates to:
  /// **'Service count'**
  String get courierServiceCount;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'uz': {
  switch (locale.scriptCode) {
    case 'Cyrl': return AppLocalizationsUzCyrl();
case 'Latn': return AppLocalizationsUzLatn();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
    case 'uz': return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
