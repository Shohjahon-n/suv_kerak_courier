import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn'),
    Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Cyrl'),
  ];

  static AppLocalizations of(BuildContext context) {
    final localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (localizations == null) {
      throw StateError('AppLocalizations not found in context');
    }
    return localizations;
  }

  static Locale resolveLocale(Locale locale) {
    if (locale.languageCode == 'uz' && locale.scriptCode == null) {
      return const Locale.fromSubtags(languageCode: 'uz', scriptCode: 'Latn');
    }

    for (final supported in supportedLocales) {
      if (_isSameLocale(supported, locale)) {
        return supported;
      }
    }
    return supportedLocales.first;
  }

  static bool isSupported(Locale locale) {
    if (locale.languageCode == 'uz' && locale.scriptCode == null) {
      return true;
    }
    return supportedLocales.any((supported) => _isSameLocale(supported, locale));
  }

  static bool _isSameLocale(Locale a, Locale b) {
    if (a.languageCode != b.languageCode) {
      return false;
    }
    if (a.scriptCode != null || b.scriptCode != null) {
      return a.scriptCode == b.scriptCode;
    }
    return true;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Suv Kerak Courier',
      'homeTitle': 'Courier Dashboard',
      'homeSubtitle': 'Ready for courier feature development.',
      'counterLabel': 'Counter',
      'openSettings': 'Open settings',
      'themeLight': 'Switch to light theme',
      'themeDark': 'Switch to dark theme',
      'settingsTitle': 'Settings',
      'languageTitle': 'Language',
      'languageEnglish': 'English',
      'languageRussian': 'Russian',
      'languageUzbekLatin': 'Uzbek (Latin)',
      'languageUzbekCyrillic': 'Uzbek (Cyrillic)',
      'languageSelectionTitle': 'Choose your language',
      'languageSelectionSubtitle': 'Select the language for the courier app.',
      'loginTitle': 'Courier Login',
      'loginSubtitle': 'Sign in to start deliveries.',
      'loginPlaceholder': 'Login screen is being prepared.',
      'loginHint': "We'll add phone and verification next.",
      'loginCourierIdLabel': 'Courier ID',
      'loginCourierIdHint': 'Enter your courier ID',
      'loginPasswordLabel': 'Password',
      'loginPasswordHint': 'Enter your password',
      'loginButton': 'Log in',
      'forgotPassword': 'Forgot password?',
      'registerLink': 'Register',
      'loginValidationEmpty': 'Enter ID and password.',
      'loginValidationId': 'Courier ID must be numbers.',
      'loginErrorGeneric': 'Login failed. Try again.',
      'loginSuccess': 'Logged in successfully.',
      'comingSoon': 'Coming soon.',
      'refreshLabel': 'Refresh',
      'homeEmptyState': 'No data yet.',
      'homeCourierIdLabel': 'Courier ID',
      'homeLastActiveLabel': 'Last active',
      'homeCashBalanceLabel': 'Cash balance',
      'homeFullWaterLabel': 'Full water remaining',
      'homeEmptyBottleLabel': 'Empty bottles',
      'homeOrdersTodayLabel': 'Orders today',
      'notAvailable': 'Not available',
      'mainMenuTitle': 'Main menu',
      'menuOrders': 'Orders',
      'ordersQuickActionsTitle': 'Quick actions',
      'ordersPendingButton': 'Uncompleted orders',
      'ordersCompletedTodayButton': "Today's completed orders",
      'ordersMapButton': 'Show orders on map',
      'ordersPeriodicReportTitle': 'Periodic completed orders report',
      'ordersPendingTitle': 'Uncompleted orders',
      'ordersSummaryTitle': 'Summary',
      'ordersCountLabel': 'Orders count',
      'ordersTotalWaterLabel': 'Total water',
      'ordersOrderIdLabel': 'Order number',
      'ordersBuyerIdLabel': 'Buyer ID',
      'ordersNoteLabel': 'Note',
      'ordersWaterCountLabel': 'Water count',
      'ordersPaymentStatusLabel': 'Payment status',
      'ordersLocationLabel': 'Location',
      'ordersEmptyState': 'No orders yet.',
      'ordersSessionMissing': 'Business ID not found.',
      'ordersLoadFailed': 'Failed to load orders.',
      'ordersLocationServiceDisabled': 'Location services are disabled.',
      'ordersLocationPermissionDenied':
          'Location permission is required to show your position.',
      'ordersLocationPermissionPermanentlyDenied':
          'Enable location permission in settings to show your position.',
      'ordersLocationUnavailable': 'Unable to get your location.',
      'ordersCourierLabel': 'You',
      'ordersCourierTitle': 'Your location',
      'ordersCourierSubtitle': 'Showing your current position.',
      'ordersMapFindMe': 'Find me',
      'ordersMapGoButton': 'Go',
      'ordersRouteFailed': 'Failed to build route.',
      'ordersMapFollowHeading': 'Follow heading',
      'ordersMapFollowHeadingOff': 'Stop following',
      'menuCashReport': 'Cash report',
      'menuBottleBalance': 'Bottle balance',
      'bottleBalanceEmptyPeriodicTitle': 'Periodic empty bottle report',
      'bottleBalanceFullWaterPeriodicTitle': 'Periodic full water report',
      'bottleBalanceSummaryTitle': 'Summary',
      'bottleBalanceOperationsTitle': 'Operations',
      'bottleBalanceOpeningBalanceLabel': 'Opening bottle balance',
      'bottleBalanceClosingBalanceLabel': 'Closing bottle balance',
      'bottleBalanceTotalIncomeLabel': 'Total bottles in',
      'bottleBalanceTotalExpenseLabel': 'Total bottles out',
      'bottleBalanceIncomeLabel': 'In',
      'bottleBalanceExpenseLabel': 'Out',
      'bottleBalanceBalanceLabel': 'Balance',
      'fullWaterOpeningBalanceLabel': 'Opening full water balance',
      'fullWaterClosingBalanceLabel': 'Closing full water balance',
      'fullWaterTotalIncomeLabel': 'Total full water in',
      'fullWaterTotalExpenseLabel': 'Total full water out',
      'menuSettings': 'Settings',
      'menuSecurity': 'Security',
      'menuAbout': 'About system',
      'aboutDescription':
          'The "Suv kerak" project app is part of the "Hisob" system and was created to help entrepreneurs who distribute drinking water monitor the order fulfillment process. We are always ready to automate your other business activities or your specific workflow.',
      'aboutShareButton': 'Share app',
      'aboutUpdateButton': 'Update app',
      'aboutVersionLabel': 'Version',
      'aboutShareMessage': 'Try the Suv Kerak Courier app.',
      'aboutUpdateUnavailable': 'Update link not available.',
      'aboutShareUnavailable': 'Share link not available.',
      'cashReportPeriodicTitle': 'Periodic cash report',
      'cashReportOnlineTitle': 'Online payments',
      'cashReportStartDate': 'Start date',
      'cashReportEndDate': 'End date',
      'cashReportPickDate': 'Select date',
      'cashReportShow': 'Show',
      'cashReportValidationRequired': 'Select start and end dates.',
      'cashReportValidationOrder': 'Start date must be before end date.',
      'cashReportRangeLabel': 'Period',
      'cashReportApiNotReady': 'API is not connected yet.',
      'cashReportEmptyResult': 'No data for the selected period.',
      'cashReportRetry': 'Retry',
      'cashReportSessionMissing': 'Courier session not found.',
      'cashReportSummaryTitle': 'Summary',
      'cashReportOpeningBalanceLabel': 'Opening balance',
      'cashReportClosingBalanceLabel': 'Closing balance',
      'cashReportTotalIncomeLabel': 'Total income',
      'cashReportTotalExpenseLabel': 'Total expense',
      'cashReportOperationsTitle': 'Operations',
      'cashReportIncomeLabel': 'Income',
      'cashReportExpenseLabel': 'Expense',
      'cashReportBalanceLabel': 'Balance',
      'cashReportTotalAmountLabel': 'Total amount',
      'cashReportPaymentsTitle': 'Payments',
      'cashReportOrderLabel': 'Order',
      'cashReportBuyerLabel': 'Buyer',
      'cashReportPaymentSystemLabel': 'Payment system',
      'cashReportAmountLabel': 'Amount',
      'themeModeTitle': 'Theme mode',
      'themeModeLight': 'Light',
      'themeModeDark': 'Dark',
      'securityTitle': 'Security',
      'securityPinTitle': 'PIN code login',
      'securityBiometricTitle': 'Biometric login',
      'securityChangePasswordTitle': 'Change password',
      'securityChangePinTitle': 'Change PIN',
      'securityOldPasswordLabel': 'Current password',
      'securityNewPasswordLabel': 'New password',
      'securityConfirmPasswordLabel': 'Confirm password',
      'securityOldPinLabel': 'Current PIN',
      'securityNewPinLabel': 'New PIN',
      'securityConfirmPinLabel': 'Confirm PIN',
      'securityUpdateButton': 'Update',
      'securityValidationRequired': 'Fill out all fields.',
      'securityValidationMismatch': 'New values do not match.',
      'securityApiNotReady': 'API is not connected yet.',
      'securitySessionMissing': 'Courier session not found.',
      'securityPasswordUpdated': 'Password updated successfully.',
      'securityPasswordUpdateFailed': 'Password update failed.',
      'securityPinUpdated': 'PIN updated successfully.',
      'securityPinUpdateFailed': 'PIN update failed.',
      'pinSetupTitle': 'Create PIN',
      'pinSetupSubtitle': 'Choose a 4-digit PIN.',
      'pinSetupLabel': 'PIN',
      'pinSetupConfirmLabel': 'Confirm PIN',
      'pinSetupSave': 'Save',
      'pinSetupCancel': 'Cancel',
      'pinSetupErrorLength': 'PIN must be 4 digits.',
      'pinSetupErrorMismatch': 'PINs do not match.',
      'pinUnlockTitle': 'Enter PIN',
      'pinUnlockSubtitle': 'Enter your PIN to continue.',
      'pinUnlockButton': 'Unlock',
      'pinUnlockError': 'Incorrect PIN.',
      'biometricButton': 'Use biometrics',
      'biometricReason': 'Authenticate to unlock.',
      'biometricUnavailable': 'Biometrics not available on this device.',
      'biometricFailed': 'Biometric authentication failed.',
    },
    'ru': {
      'appTitle': 'Suv Kerak Courier',
      'homeTitle': 'Панель курьера',
      'homeSubtitle': 'Готово для разработки функций курьера.',
      'counterLabel': 'Счётчик',
      'openSettings': 'Открыть настройки',
      'themeLight': 'Переключить на светлую тему',
      'themeDark': 'Переключить на тёмную тему',
      'settingsTitle': 'Настройки',
      'languageTitle': 'Язык',
      'languageEnglish': 'Английский',
      'languageRussian': 'Русский',
      'languageUzbekLatin': 'Узбекский (латиница)',
      'languageUzbekCyrillic': 'Узбекский (кириллица)',
      'languageSelectionTitle': 'Выберите язык',
      'languageSelectionSubtitle': 'Выберите язык для приложения курьера.',
      'loginTitle': 'Вход курьера',
      'loginSubtitle': 'Войдите, чтобы начать доставки.',
      'loginPlaceholder': 'Экран входа в разработке.',
      'loginHint': 'Далее добавим телефон и подтверждение.',
      'loginCourierIdLabel': 'ID курьера',
      'loginCourierIdHint': 'Введите ID курьера',
      'loginPasswordLabel': 'Пароль',
      'loginPasswordHint': 'Введите пароль',
      'loginButton': 'Войти',
      'forgotPassword': 'Забыли пароль?',
      'registerLink': 'Регистрация',
      'loginValidationEmpty': 'Введите ID и пароль.',
      'loginValidationId': 'ID курьера должен быть числом.',
      'loginErrorGeneric': 'Не удалось войти. Попробуйте еще раз.',
      'loginSuccess': 'Успешный вход.',
      'comingSoon': 'Скоро будет.',
      'refreshLabel': 'Обновить',
      'homeEmptyState': 'Пока нет данных.',
      'homeCourierIdLabel': 'ID курьера',
      'homeLastActiveLabel': 'Последняя активность',
      'homeCashBalanceLabel': 'Остаток в кассе',
      'homeFullWaterLabel': 'Полная вода',
      'homeEmptyBottleLabel': 'Пустые бутыли',
      'homeOrdersTodayLabel': 'Заказы за сегодня',
      'notAvailable': 'Нет данных',
      'mainMenuTitle': 'Главное меню',
      'menuOrders': 'Заказы',
      'ordersQuickActionsTitle': 'Быстрые действия',
      'ordersPendingButton': 'Невыполненные заказы',
      'ordersCompletedTodayButton': 'Выполненные за сегодня',
      'ordersMapButton': 'Показать заказы на карте',
      'ordersPeriodicReportTitle':
          'Периодический отчет по выполненным заказам',
      'ordersPendingTitle': 'Невыполненные заказы',
      'ordersSummaryTitle': 'Сводка',
      'ordersCountLabel': 'Количество заказов',
      'ordersTotalWaterLabel': 'Всего воды',
      'ordersOrderIdLabel': 'Номер заказа',
      'ordersBuyerIdLabel': 'ID покупателя',
      'ordersNoteLabel': 'Комментарий',
      'ordersWaterCountLabel': 'Количество воды',
      'ordersPaymentStatusLabel': 'Статус оплаты',
      'ordersLocationLabel': 'Локация',
      'ordersEmptyState': 'Пока нет заказов.',
      'ordersSessionMissing': 'Не найден ID бизнеса.',
      'ordersLoadFailed': 'Не удалось загрузить заказы.',
      'ordersLocationServiceDisabled': 'Службы геолокации отключены.',
      'ordersLocationPermissionDenied':
          'Разрешение на геолокацию нужно, чтобы показать вашу позицию.',
      'ordersLocationPermissionPermanentlyDenied':
          'Разрешите доступ к геолокации в настройках, чтобы показать вашу позицию.',
      'ordersLocationUnavailable': 'Не удалось получить вашу геолокацию.',
      'ordersCourierLabel': 'Вы',
      'ordersCourierTitle': 'Ваше местоположение',
      'ordersCourierSubtitle': 'Показываем вашу текущую позицию.',
      'ordersMapFindMe': 'Мое местоположение',
      'ordersMapGoButton': 'Маршрут',
      'ordersRouteFailed': 'Не удалось построить маршрут.',
      'ordersMapFollowHeading': 'Следовать направлению',
      'ordersMapFollowHeadingOff': 'Отключить слежение',
      'menuCashReport': 'Кассовый отчет',
      'menuBottleBalance': 'Учет тары',
      'bottleBalanceEmptyPeriodicTitle': 'Периодический учет тары',
      'bottleBalanceFullWaterPeriodicTitle':
          'Периодический учет полных бутылей',
      'bottleBalanceSummaryTitle': 'Сводка',
      'bottleBalanceOperationsTitle': 'Операции',
      'bottleBalanceOpeningBalanceLabel': 'Начальный остаток тары',
      'bottleBalanceClosingBalanceLabel': 'Конечный остаток тары',
      'bottleBalanceTotalIncomeLabel': 'Поступило тары',
      'bottleBalanceTotalExpenseLabel': 'Расход тары',
      'bottleBalanceIncomeLabel': 'Приход',
      'bottleBalanceExpenseLabel': 'Расход',
      'bottleBalanceBalanceLabel': 'Остаток',
      'fullWaterOpeningBalanceLabel': 'Начальный остаток полных бутылей',
      'fullWaterClosingBalanceLabel': 'Конечный остаток полных бутылей',
      'fullWaterTotalIncomeLabel': 'Поступило полных бутылей',
      'fullWaterTotalExpenseLabel': 'Расход полных бутылей',
      'menuSettings': 'Настройки',
      'menuSecurity': 'Безопасность',
      'menuAbout': 'О системе',
      'aboutDescription':
          'Приложение проекта "Suv kerak" входит в систему "Hisob" и создано для контроля процесса выполнения заказов предпринимателями, занимающимися доставкой питьевой воды. Мы всегда готовы автоматизировать другие направления вашего бизнеса или именно вашу деятельность.',
      'aboutShareButton': 'Поделиться',
      'aboutUpdateButton': 'Обновить приложение',
      'aboutVersionLabel': 'Версия',
      'aboutShareMessage': 'Попробуйте приложение Suv Kerak Courier.',
      'aboutUpdateUnavailable': 'Ссылка для обновления недоступна.',
      'aboutShareUnavailable': 'Ссылка для отправки недоступна.',
      'cashReportPeriodicTitle': 'Периодический кассовый отчет',
      'cashReportOnlineTitle': 'Онлайн платежи',
      'cashReportStartDate': 'Дата начала',
      'cashReportEndDate': 'Дата окончания',
      'cashReportPickDate': 'Выберите дату',
      'cashReportShow': 'Показать',
      'cashReportValidationRequired': 'Выберите дату начала и окончания.',
      'cashReportValidationOrder':
          'Дата начала должна быть раньше даты окончания.',
      'cashReportRangeLabel': 'Период',
      'cashReportApiNotReady': 'API еще не подключен.',
      'cashReportEmptyResult': 'Нет данных за выбранный период.',
      'cashReportRetry': 'Повторить',
      'cashReportSessionMissing': 'Сессия курьера не найдена.',
      'cashReportSummaryTitle': 'Сводка',
      'cashReportOpeningBalanceLabel': 'Начальный остаток',
      'cashReportClosingBalanceLabel': 'Конечный остаток',
      'cashReportTotalIncomeLabel': 'Всего поступлений',
      'cashReportTotalExpenseLabel': 'Всего расходов',
      'cashReportOperationsTitle': 'Операции',
      'cashReportIncomeLabel': 'Поступление',
      'cashReportExpenseLabel': 'Расход',
      'cashReportBalanceLabel': 'Баланс',
      'cashReportTotalAmountLabel': 'Общая сумма',
      'cashReportPaymentsTitle': 'Платежи',
      'cashReportOrderLabel': 'Заказ',
      'cashReportBuyerLabel': 'Покупатель',
      'cashReportPaymentSystemLabel': 'Платежная система',
      'cashReportAmountLabel': 'Сумма',
      'themeModeTitle': 'Тема',
      'themeModeLight': 'Светлая',
      'themeModeDark': 'Темная',
      'securityTitle': 'Безопасность',
      'securityPinTitle': 'Вход по PIN-коду',
      'securityBiometricTitle': 'Вход по биометрии',
      'securityChangePasswordTitle': 'Сменить пароль',
      'securityChangePinTitle': 'Сменить PIN-код',
      'securityOldPasswordLabel': 'Текущий пароль',
      'securityNewPasswordLabel': 'Новый пароль',
      'securityConfirmPasswordLabel': 'Подтвердите пароль',
      'securityOldPinLabel': 'Текущий PIN',
      'securityNewPinLabel': 'Новый PIN',
      'securityConfirmPinLabel': 'Подтвердите PIN',
      'securityUpdateButton': 'Обновить',
      'securityValidationRequired': 'Заполните все поля.',
      'securityValidationMismatch': 'Новые значения не совпадают.',
      'securityApiNotReady': 'API еще не подключен.',
      'securitySessionMissing': 'Сессия курьера не найдена.',
      'securityPasswordUpdated': 'Пароль успешно обновлен.',
      'securityPasswordUpdateFailed': 'Не удалось обновить пароль.',
      'securityPinUpdated': 'PIN успешно обновлен.',
      'securityPinUpdateFailed': 'Не удалось обновить PIN.',
      'pinSetupTitle': 'Создать PIN',
      'pinSetupSubtitle': 'Выберите PIN из 4 цифр.',
      'pinSetupLabel': 'PIN',
      'pinSetupConfirmLabel': 'Повторите PIN',
      'pinSetupSave': 'Сохранить',
      'pinSetupCancel': 'Отмена',
      'pinSetupErrorLength': 'PIN должен быть из 4 цифр.',
      'pinSetupErrorMismatch': 'PIN не совпадает.',
      'pinUnlockTitle': 'Введите PIN',
      'pinUnlockSubtitle': 'Введите PIN, чтобы продолжить.',
      'pinUnlockButton': 'Открыть',
      'pinUnlockError': 'Неверный PIN.',
      'biometricButton': 'Использовать биометрию',
      'biometricReason': 'Подтвердите личность для входа.',
      'biometricUnavailable': 'Биометрия недоступна на этом устройстве.',
      'biometricFailed': 'Не удалось пройти биометрическую проверку.',
    },
    'uz_Latn': {
      'appTitle': 'Suv Kerak Courier',
      'homeTitle': 'Kuryer paneli',
      'homeSubtitle': 'Kuryer funksiyalarini ishlab chiqishga tayyor.',
      'counterLabel': 'Hisoblagich',
      'openSettings': 'Sozlamalarni ochish',
      'themeLight': "Yorug' mavzuga o'tish",
      'themeDark': "Qorong'i mavzuga o'tish",
      'settingsTitle': 'Sozlamalar',
      'languageTitle': 'Til',
      'languageEnglish': 'Inglizcha',
      'languageRussian': 'Ruscha',
      'languageUzbekLatin': "O'zbek (Lotin)",
      'languageUzbekCyrillic': "O'zbek (Kiril)",
      'languageSelectionTitle': 'Tilni tanlang',
      'languageSelectionSubtitle': 'Kuryer ilovasi uchun tilni tanlang.',
      'loginTitle': 'Kuryer kirish',
      'loginSubtitle': 'Yetkazib berishni boshlash uchun tizimga kiring.',
      'loginPlaceholder': 'Kirish sahifasi tayyorlanmoqda.',
      'loginHint': "Keyingi bosqichda telefon va tasdiqlash bo'ladi.",
      'loginCourierIdLabel': 'Kuryer ID',
      'loginCourierIdHint': 'Kuryer ID ni kiriting',
      'loginPasswordLabel': 'Parol',
      'loginPasswordHint': 'Parolni kiriting',
      'loginButton': 'Kirish',
      'forgotPassword': 'Parolni unutdingizmi?',
      'registerLink': "Ro'yxatdan o'tish",
      'loginValidationEmpty': 'ID va parolni kiriting.',
      'loginValidationId': "Kuryer ID faqat raqam bo'lishi kerak.",
      'loginErrorGeneric': "Kirishda xatolik. Qayta urinib ko'ring.",
      'loginSuccess': 'Muvaffaqiyatli kirdingiz.',
      'comingSoon': 'Tez orada.',
      'refreshLabel': 'Yangilash',
      'homeEmptyState': "Hozircha ma'lumot yo'q.",
      'homeCourierIdLabel': 'Kuryer ID',
      'homeLastActiveLabel': 'Oxirgi faollik',
      'homeCashBalanceLabel': "Kassa qoldig'i",
      'homeFullWaterLabel': "To'la suv qoldig'i",
      'homeEmptyBottleLabel': "Bo'sh baklar",
      'homeOrdersTodayLabel': 'Bugungi buyurtmalar',
      'notAvailable': "Ma'lumot yo'q",
      'mainMenuTitle': 'Asosiy menyu',
      'menuOrders': 'Buyurtmalar',
      'ordersQuickActionsTitle': 'Tezkor amallar',
      'ordersPendingButton': 'Bajarilmagan buyurtmalar',
      'ordersCompletedTodayButton': 'Bugungi bajarilgan buyurtmalar',
      'ordersMapButton': "Buyurtmalarni xaritada ko'rsatish",
      'ordersPeriodicReportTitle':
          'Bajarilgan buyurtmalarni davriy hisoboti',
      'ordersPendingTitle': 'Bajarilmagan buyurtmalar',
      'ordersSummaryTitle': "Umumiy ma'lumot",
      'ordersCountLabel': 'Buyurtmalar soni',
      'ordersTotalWaterLabel': 'Jami suv soni',
      'ordersOrderIdLabel': 'Buyurtma raqami',
      'ordersBuyerIdLabel': 'Buyurtmachi ID',
      'ordersNoteLabel': 'Izoh',
      'ordersWaterCountLabel': 'Suv soni',
      'ordersPaymentStatusLabel': "To'lov holati",
      'ordersLocationLabel': 'Lokatsiya',
      'ordersEmptyState': "Hozircha buyurtmalar yo'q.",
      'ordersSessionMissing': 'Biznes ID topilmadi.',
      'ordersLoadFailed': 'Buyurtmalarni yuklashda xatolik.',
      'ordersLocationServiceDisabled': 'Joylashuv xizmati o\'chirilgan.',
      'ordersLocationPermissionDenied':
          'Joylashuvingizni ko\'rsatish uchun ruxsat kerak.',
      'ordersLocationPermissionPermanentlyDenied':
          'Joylashuv ruxsatini sozlamalardan yoqing.',
      'ordersLocationUnavailable': 'Joylashuvni aniqlab bo\'lmadi.',
      'ordersCourierLabel': 'Siz',
      'ordersCourierTitle': 'Sizning joylashuvingiz',
      'ordersCourierSubtitle': 'Hozirgi joylashuvingiz ko\'rsatiladi.',
      'ordersMapFindMe': 'Mening joylashuvim',
      'ordersMapGoButton': 'Yo\'nalish',
      'ordersRouteFailed': 'Marshrutni chizib bo\'lmadi.',
      'ordersMapFollowHeading': 'Yo\'nalishni kuzatish',
      'ordersMapFollowHeadingOff': 'Kuzatishni o\'chirish',
      'menuCashReport': 'Kassa hisoboti',
      'menuBottleBalance': 'Taralar hisobi',
      'bottleBalanceEmptyPeriodicTitle': 'Taralar davriy hisobi',
      'bottleBalanceFullWaterPeriodicTitle':
          "Suv to'la baklar davriy hisobi",
      'bottleBalanceSummaryTitle': 'Yakun',
      'bottleBalanceOperationsTitle': 'Operatsiyalar',
      'bottleBalanceOpeningBalanceLabel': "Boshlang'ich tara qoldig'i",
      'bottleBalanceClosingBalanceLabel': "Yakuniy tara qoldig'i",
      'bottleBalanceTotalIncomeLabel': 'Jami tara kirimi',
      'bottleBalanceTotalExpenseLabel': 'Jami tara chiqimi',
      'bottleBalanceIncomeLabel': 'Kirim',
      'bottleBalanceExpenseLabel': 'Chiqim',
      'bottleBalanceBalanceLabel': 'Qoldiq',
      'fullWaterOpeningBalanceLabel': "Boshlang'ich suv to'la baklar qoldig'i",
      'fullWaterClosingBalanceLabel': "Yakuniy suv to'la baklar qoldig'i",
      'fullWaterTotalIncomeLabel': "Jami suv to'la baklar kirimi",
      'fullWaterTotalExpenseLabel': "Jami suv to'la baklar chiqimi",
      'menuSettings': 'Sozlamalar',
      'menuSecurity': 'Xavfsizlik',
      'menuAbout': 'Tizim haqida',
      'aboutDescription':
          "\"Suv kerak\" loyihasi ilovasi \"Hisob\" tizimidagi ilova bo'lib, aynan ichimlik suvi tarqatish faoliyati bilan shug'ullanuvchi tadbirkorlar uchun buyurtmalarni bajarish jarayonini nazorat qilish maqsadida yaratilgan. Tadbirkorlikning boshqa faoliyatlari yoki aynan sizning faoliyatingizni avtomatlashtirish uchun biz doimo tayyormiz.",
      'aboutShareButton': "Ilovani bo'lishish",
      'aboutUpdateButton': 'Ilovani yangilash',
      'aboutVersionLabel': 'Versiya',
      'aboutShareMessage': "Suv Kerak Courier ilovasini sinab ko'ring.",
      'aboutUpdateUnavailable': "Yangilash havolasi mavjud emas.",
      'aboutShareUnavailable': "Ulashish havolasi mavjud emas.",
      'cashReportPeriodicTitle': 'Davriy kassa hisoboti',
      'cashReportOnlineTitle': "Onlayn to'lovlar",
      'cashReportStartDate': 'Boshlanish sanasi',
      'cashReportEndDate': 'Tugash sanasi',
      'cashReportPickDate': 'Sanani tanlang',
      'cashReportShow': "Ko'rsatish",
      'cashReportValidationRequired':
          'Boshlanish va tugash sanasini tanlang.',
      'cashReportValidationOrder':
          "Boshlanish sanasi tugash sanasidan oldin bo'lishi kerak.",
      'cashReportRangeLabel': 'Davr',
      'cashReportApiNotReady': 'API hali ulanmagan.',
      'cashReportEmptyResult': "Tanlangan davr uchun ma'lumot yo'q.",
      'cashReportRetry': "Qayta urinib ko'rish",
      'cashReportSessionMissing': 'Kuryer sessiyasi topilmadi.',
      'cashReportSummaryTitle': 'Yakun',
      'cashReportOpeningBalanceLabel': "Boshlang'ich saldo",
      'cashReportClosingBalanceLabel': 'Yakuniy saldo',
      'cashReportTotalIncomeLabel': 'Jami kirim',
      'cashReportTotalExpenseLabel': 'Jami chiqim',
      'cashReportOperationsTitle': 'Operatsiyalar',
      'cashReportIncomeLabel': 'Kirim',
      'cashReportExpenseLabel': 'Chiqim',
      'cashReportBalanceLabel': 'Balans',
      'cashReportTotalAmountLabel': 'Jami summa',
      'cashReportPaymentsTitle': "To'lovlar",
      'cashReportOrderLabel': 'Buyurtma',
      'cashReportBuyerLabel': 'Buyurtmachi',
      'cashReportPaymentSystemLabel': "To'lov tizimi",
      'cashReportAmountLabel': 'Summa',
      'themeModeTitle': 'Mavzu',
      'themeModeLight': "Yorug'",
      'themeModeDark': "Qorong'i",
      'securityTitle': 'Xavfsizlik',
      'securityPinTitle': 'PIN kod orqali kirish',
      'securityBiometricTitle': 'Biometrik kirish',
      'securityChangePasswordTitle': "Parolni almashtirish",
      'securityChangePinTitle': 'PIN kodni almashtirish',
      'securityOldPasswordLabel': 'Eski parol',
      'securityNewPasswordLabel': 'Yangi parol',
      'securityConfirmPasswordLabel': 'Yangi parolni tasdiqlash',
      'securityOldPinLabel': 'Eski PIN',
      'securityNewPinLabel': 'Yangi PIN',
      'securityConfirmPinLabel': 'Yangi PINni tasdiqlash',
      'securityUpdateButton': 'Yangilash',
      'securityValidationRequired': "Barcha maydonlarni to'ldiring.",
      'securityValidationMismatch': 'Yangi qiymatlar mos emas.',
      'securityApiNotReady': 'API hali ulanmagan.',
      'securitySessionMissing': 'Kuryer sessiyasi topilmadi.',
      'securityPasswordUpdated': 'Parol muvaffaqiyatli yangilandi.',
      'securityPasswordUpdateFailed': 'Parolni yangilashda xatolik.',
      'securityPinUpdated': 'PIN muvaffaqiyatli yangilandi.',
      'securityPinUpdateFailed': 'PINni yangilashda xatolik.',
      'pinSetupTitle': 'PIN tanlang',
      'pinSetupSubtitle': '4 xonali PIN tanlang.',
      'pinSetupLabel': 'PIN',
      'pinSetupConfirmLabel': 'PIN ni tasdiqlang',
      'pinSetupSave': 'Saqlash',
      'pinSetupCancel': 'Bekor qilish',
      'pinSetupErrorLength': "PIN 4 ta raqam bo'lishi kerak.",
      'pinSetupErrorMismatch': 'PIN lar mos emas.',
      'pinUnlockTitle': 'PIN kiriting',
      'pinUnlockSubtitle': 'Davom etish uchun PIN kiriting.',
      'pinUnlockButton': 'Kirish',
      'pinUnlockError': "PIN noto'g'ri.",
      'biometricButton': 'Biometrik kirish',
      'biometricReason': 'Kirish uchun tasdiqlang.',
      'biometricUnavailable': 'Bu qurilmada biometrik mavjud emas.',
      'biometricFailed': 'Biometrik tekshiruv muvaffaqiyatsiz.',
    },
    'uz_Cyrl': {
      'appTitle': 'Suv Kerak Courier',
      'homeTitle': 'Курьер панели',
      'homeSubtitle': 'Курьер функцияларини ишлаб чиқишга тайёр.',
      'counterLabel': 'Ҳисоблагич',
      'openSettings': 'Созламаларни очиш',
      'themeLight': 'Ёруғ мавзуга ўтиш',
      'themeDark': 'Қоронғи мавзуга ўтиш',
      'settingsTitle': 'Созламалар',
      'languageTitle': 'Тил',
      'languageEnglish': 'Инглизча',
      'languageRussian': 'Русча',
      'languageUzbekLatin': 'Ўзбек (Лотин)',
      'languageUzbekCyrillic': 'Ўзбек (Кирил)',
      'languageSelectionTitle': 'Тилни танланг',
      'languageSelectionSubtitle': 'Курьер иловаси учун тилни танланг.',
      'loginTitle': 'Курьер кириш',
      'loginSubtitle': 'Етказиб беришни бошлаш учун тизимга киринг.',
      'loginPlaceholder': 'Кириш саҳифаси тайёрланмоқда.',
      'loginHint': 'Кейинги босқичда телефон ва тасдиқлаш бўлади.',
      'loginCourierIdLabel': 'Курьер ID',
      'loginCourierIdHint': 'Курьер ID ни киритинг',
      'loginPasswordLabel': 'Парол',
      'loginPasswordHint': 'Паролни киритинг',
      'loginButton': 'Кириш',
      'forgotPassword': 'Паролни унутдингизми?',
      'registerLink': 'Рўйхатдан ўтиш',
      'loginValidationEmpty': 'ID ва паролни киритинг.',
      'loginValidationId': 'Курьер ID фақат рақам бўлиши керак.',
      'loginErrorGeneric': 'Киришда хатолик. Қайта уриниб кўринг.',
      'loginSuccess': 'Муваффақиятли кирдингиз.',
      'comingSoon': 'Тез орада.',
      'refreshLabel': 'Янгилаш',
      'homeEmptyState': 'Ҳозирча маълумот йўқ.',
      'homeCourierIdLabel': 'Курьер ID',
      'homeLastActiveLabel': 'Охирги фаоллик',
      'homeCashBalanceLabel': 'Касса қолдиғи',
      'homeFullWaterLabel': 'Тўла сув қолдиғи',
      'homeEmptyBottleLabel': 'Бўш баклар',
      'homeOrdersTodayLabel': 'Бугунги буюртмалар',
      'notAvailable': 'Маълумот йўқ',
      'mainMenuTitle': 'Асосий меню',
      'menuOrders': 'Буюртмалар',
      'ordersQuickActionsTitle': 'Тезкор амаллар',
      'ordersPendingButton': 'Бажарилмаган буюртмалар',
      'ordersCompletedTodayButton': 'Бугунги бажарилган буюртмалар',
      'ordersMapButton': 'Буюртмаларни харитада кўрсатиш',
      'ordersPeriodicReportTitle':
          'Бажарилган буюртмаларни даврий ҳисоботи',
      'ordersPendingTitle': 'Бажарилмаган буюртмалар',
      'ordersSummaryTitle': 'Умумий маълумот',
      'ordersCountLabel': 'Буюртмалар сони',
      'ordersTotalWaterLabel': 'Жами сув сони',
      'ordersOrderIdLabel': 'Буюртма рақами',
      'ordersBuyerIdLabel': 'Буюртмачи ID',
      'ordersNoteLabel': 'Изоҳ',
      'ordersWaterCountLabel': 'Сув сони',
      'ordersPaymentStatusLabel': 'Тўлов ҳолати',
      'ordersLocationLabel': 'Локация',
      'ordersEmptyState': 'Ҳозирча буюртмалар йўқ.',
      'ordersSessionMissing': 'Бизнес ID топилмади.',
      'ordersLoadFailed': 'Буюртмаларни юклашда хатолик.',
      'ordersLocationServiceDisabled': 'Жойлашув хизмати ўчирилган.',
      'ordersLocationPermissionDenied':
          'Жойлашувингизни кўрсатиш учун рухсат керак.',
      'ordersLocationPermissionPermanentlyDenied':
          'Жойлашув рухсатини созламалардан ёқинг.',
      'ordersLocationUnavailable': 'Жойлашувни аниқлаб бўлмади.',
      'ordersCourierLabel': 'Сиз',
      'ordersCourierTitle': 'Сизнинг жойлашувингиз',
      'ordersCourierSubtitle': 'Ҳозирги жойлашувингиз кўрсатилади.',
      'ordersMapFindMe': 'Менинг жойлашувим',
      'ordersMapGoButton': 'Йўналиш',
      'ordersRouteFailed': 'Маршрутни чизиб бўлмади.',
      'ordersMapFollowHeading': 'Йўналишни кузатиш',
      'ordersMapFollowHeadingOff': 'Кузатишни ўчириш',
      'menuCashReport': 'Касса ҳисоботи',
      'menuBottleBalance': 'Таралар ҳисоби',
      'bottleBalanceEmptyPeriodicTitle': 'Таралар даврий ҳисоби',
      'bottleBalanceFullWaterPeriodicTitle':
          'Сув тўла баклар даврий ҳисоби',
      'bottleBalanceSummaryTitle': 'Якун',
      'bottleBalanceOperationsTitle': 'Операциялар',
      'bottleBalanceOpeningBalanceLabel': 'Бошланғич тара қолдиғи',
      'bottleBalanceClosingBalanceLabel': 'Якуний тара қолдиғи',
      'bottleBalanceTotalIncomeLabel': 'Жами тара кирими',
      'bottleBalanceTotalExpenseLabel': 'Жами тара чиқими',
      'bottleBalanceIncomeLabel': 'Кирим',
      'bottleBalanceExpenseLabel': 'Чиқим',
      'bottleBalanceBalanceLabel': 'Қолдиқ',
      'fullWaterOpeningBalanceLabel':
          'Бошланғич сув тўла баклар қолдиғи',
      'fullWaterClosingBalanceLabel': 'Якуний сув тўла баклар қолдиғи',
      'fullWaterTotalIncomeLabel': 'Жами сув тўла баклар кирими',
      'fullWaterTotalExpenseLabel': 'Жами сув тўла баклар чиқими',
      'menuSettings': 'Созламалар',
      'menuSecurity': 'Хавфсизлик',
      'menuAbout': 'Тизим ҳақида',
      'aboutDescription':
          '"Suv kerak" лойиҳаси иловаси "Hisob" тизимидаги илова бўлиб, айнан ичимлик суви тарқатувчи фаолиятлар билан шуғулланувчи тадбиркорлар учун буюртмаларни бажариш жараёнини назорат қилиш мақсадида яратилган. Тадбиркорликни бошқа фаолиятлари ёки айнан сизнинг фаолиятингизни автоматлаштириш учун биз доимо тайёрмиз.',
      'aboutShareButton': 'Иловани бўлишиш',
      'aboutUpdateButton': 'Иловани янгилаш',
      'aboutVersionLabel': 'Версия',
      'aboutShareMessage': 'Suv Kerak Courier иловасини синаб кўринг.',
      'aboutUpdateUnavailable': 'Янгилаш ҳаволаси мавжуд эмас.',
      'aboutShareUnavailable': 'Улашиш ҳаволаси мавжуд эмас.',
      'cashReportPeriodicTitle': 'Даврий касса ҳисоботи',
      'cashReportOnlineTitle': 'Онлайн тўловлар',
      'cashReportStartDate': 'Бошланиш санаси',
      'cashReportEndDate': 'Тугаш санаси',
      'cashReportPickDate': 'Санани танланг',
      'cashReportShow': 'Кўрсатиш',
      'cashReportValidationRequired':
          'Бошланиш ва тугаш санасини танланг.',
      'cashReportValidationOrder':
          'Бошланиш санаси тугаш санасидан олдин бўлиши керак.',
      'cashReportRangeLabel': 'Давр',
      'cashReportApiNotReady': 'API ҳали уланмаган.',
      'cashReportEmptyResult': 'Танланган давр учун маълумот йўқ.',
      'cashReportRetry': 'Қайта уриниб кўриш',
      'cashReportSessionMissing': 'Курьер сессияси топилмади.',
      'cashReportSummaryTitle': 'Якун',
      'cashReportOpeningBalanceLabel': 'Бошланғич салдо',
      'cashReportClosingBalanceLabel': 'Якуний салдо',
      'cashReportTotalIncomeLabel': 'Жами кирим',
      'cashReportTotalExpenseLabel': 'Жами чиқим',
      'cashReportOperationsTitle': 'Операциялар',
      'cashReportIncomeLabel': 'Кирим',
      'cashReportExpenseLabel': 'Чиқим',
      'cashReportBalanceLabel': 'Баланс',
      'cashReportTotalAmountLabel': 'Жами сумма',
      'cashReportPaymentsTitle': 'Тўловлар',
      'cashReportOrderLabel': 'Буюртма',
      'cashReportBuyerLabel': 'Буюртмачи',
      'cashReportPaymentSystemLabel': 'Тўлов тизими',
      'cashReportAmountLabel': 'Сумма',
      'themeModeTitle': 'Мавзу',
      'themeModeLight': 'Ёруғ',
      'themeModeDark': 'Қоронғи',
      'securityTitle': 'Хавфсизлик',
      'securityPinTitle': 'PIN код орқали кириш',
      'securityBiometricTitle': 'Биометрик кириш',
      'securityChangePasswordTitle': 'Паролни алмаштириш',
      'securityChangePinTitle': 'PIN кодни алмаштириш',
      'securityOldPasswordLabel': 'Эски парол',
      'securityNewPasswordLabel': 'Янги парол',
      'securityConfirmPasswordLabel': 'Янги паролни тасдиқлаш',
      'securityOldPinLabel': 'Эски PIN',
      'securityNewPinLabel': 'Янги PIN',
      'securityConfirmPinLabel': 'Янги PINни тасдиқлаш',
      'securityUpdateButton': 'Янгилаш',
      'securityValidationRequired': 'Барча майдонларни тўлдиринг.',
      'securityValidationMismatch': 'Янги қийматлар мос эмас.',
      'securityApiNotReady': 'API ҳали уланмаган.',
      'securitySessionMissing': 'Курьер сессияси топилмади.',
      'securityPasswordUpdated': 'Парол муваффақиятли янгиланди.',
      'securityPasswordUpdateFailed': 'Паролни янгилаб бўлмади.',
      'securityPinUpdated': 'PIN муваффақиятли янгиланди.',
      'securityPinUpdateFailed': 'PINни янгилаб бўлмади.',
      'pinSetupTitle': 'PIN танланг',
      'pinSetupSubtitle': '4 хонали PIN танланг.',
      'pinSetupLabel': 'PIN',
      'pinSetupConfirmLabel': 'PIN ни тасдиқланг',
      'pinSetupSave': 'Сақлаш',
      'pinSetupCancel': 'Бекор қилиш',
      'pinSetupErrorLength': 'PIN 4 та рақам бўлиши керак.',
      'pinSetupErrorMismatch': 'PIN лар мос эмас.',
      'pinUnlockTitle': 'PIN киритинг',
      'pinUnlockSubtitle': 'Давом этиш учун PIN киритинг.',
      'pinUnlockButton': 'Кириш',
      'pinUnlockError': 'PIN нотўғри.',
      'biometricButton': 'Биометрик кириш',
      'biometricReason': 'Кириш учун тасдиқланг.',
      'biometricUnavailable': 'Бу қурилмада биометрик мавжуд эмас.',
      'biometricFailed': 'Биометрик текширув муваффақиятсиз.',
    },
  };

  String _t(String key) {
    final localeKey = _localeKey(locale);
    return _localizedValues[localeKey]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String get appTitle => _t('appTitle');
  String get homeTitle => _t('homeTitle');
  String get homeSubtitle => _t('homeSubtitle');
  String get counterLabel => _t('counterLabel');
  String get openSettings => _t('openSettings');
  String get themeLight => _t('themeLight');
  String get themeDark => _t('themeDark');
  String get settingsTitle => _t('settingsTitle');
  String get languageTitle => _t('languageTitle');
  String get languageEnglish => _t('languageEnglish');
  String get languageRussian => _t('languageRussian');
  String get languageUzbekLatin => _t('languageUzbekLatin');
  String get languageUzbekCyrillic => _t('languageUzbekCyrillic');
  String get languageSelectionTitle => _t('languageSelectionTitle');
  String get languageSelectionSubtitle => _t('languageSelectionSubtitle');
  String get loginTitle => _t('loginTitle');
  String get loginSubtitle => _t('loginSubtitle');
  String get loginPlaceholder => _t('loginPlaceholder');
  String get loginHint => _t('loginHint');
  String get loginCourierIdLabel => _t('loginCourierIdLabel');
  String get loginCourierIdHint => _t('loginCourierIdHint');
  String get loginPasswordLabel => _t('loginPasswordLabel');
  String get loginPasswordHint => _t('loginPasswordHint');
  String get loginButton => _t('loginButton');
  String get forgotPassword => _t('forgotPassword');
  String get registerLink => _t('registerLink');
  String get loginValidationEmpty => _t('loginValidationEmpty');
  String get loginValidationId => _t('loginValidationId');
  String get loginErrorGeneric => _t('loginErrorGeneric');
  String get loginSuccess => _t('loginSuccess');
  String get comingSoon => _t('comingSoon');
  String get refreshLabel => _t('refreshLabel');
  String get homeEmptyState => _t('homeEmptyState');
  String get homeCourierIdLabel => _t('homeCourierIdLabel');
  String get homeLastActiveLabel => _t('homeLastActiveLabel');
  String get homeCashBalanceLabel => _t('homeCashBalanceLabel');
  String get homeFullWaterLabel => _t('homeFullWaterLabel');
  String get homeEmptyBottleLabel => _t('homeEmptyBottleLabel');
  String get homeOrdersTodayLabel => _t('homeOrdersTodayLabel');
  String get notAvailable => _t('notAvailable');
  String get mainMenuTitle => _t('mainMenuTitle');
  String get menuOrders => _t('menuOrders');
  String get ordersQuickActionsTitle => _t('ordersQuickActionsTitle');
  String get ordersPendingButton => _t('ordersPendingButton');
  String get ordersCompletedTodayButton => _t('ordersCompletedTodayButton');
  String get ordersMapButton => _t('ordersMapButton');
  String get ordersPeriodicReportTitle => _t('ordersPeriodicReportTitle');
  String get ordersPendingTitle => _t('ordersPendingTitle');
  String get ordersSummaryTitle => _t('ordersSummaryTitle');
  String get ordersCountLabel => _t('ordersCountLabel');
  String get ordersTotalWaterLabel => _t('ordersTotalWaterLabel');
  String get ordersOrderIdLabel => _t('ordersOrderIdLabel');
  String get ordersBuyerIdLabel => _t('ordersBuyerIdLabel');
  String get ordersNoteLabel => _t('ordersNoteLabel');
  String get ordersWaterCountLabel => _t('ordersWaterCountLabel');
  String get ordersPaymentStatusLabel => _t('ordersPaymentStatusLabel');
  String get ordersLocationLabel => _t('ordersLocationLabel');
  String get ordersEmptyState => _t('ordersEmptyState');
  String get ordersSessionMissing => _t('ordersSessionMissing');
  String get ordersLoadFailed => _t('ordersLoadFailed');
  String get ordersLocationServiceDisabled =>
      _t('ordersLocationServiceDisabled');
  String get ordersLocationPermissionDenied =>
      _t('ordersLocationPermissionDenied');
  String get ordersLocationPermissionPermanentlyDenied =>
      _t('ordersLocationPermissionPermanentlyDenied');
  String get ordersLocationUnavailable => _t('ordersLocationUnavailable');
  String get ordersCourierLabel => _t('ordersCourierLabel');
  String get ordersCourierTitle => _t('ordersCourierTitle');
  String get ordersCourierSubtitle => _t('ordersCourierSubtitle');
  String get ordersMapFindMe => _t('ordersMapFindMe');
  String get ordersMapGoButton => _t('ordersMapGoButton');
  String get ordersRouteFailed => _t('ordersRouteFailed');
  String get ordersMapFollowHeading => _t('ordersMapFollowHeading');
  String get ordersMapFollowHeadingOff => _t('ordersMapFollowHeadingOff');
  String get menuCashReport => _t('menuCashReport');
  String get menuBottleBalance => _t('menuBottleBalance');
  String get bottleBalanceEmptyPeriodicTitle =>
      _t('bottleBalanceEmptyPeriodicTitle');
  String get bottleBalanceFullWaterPeriodicTitle =>
      _t('bottleBalanceFullWaterPeriodicTitle');
  String get bottleBalanceSummaryTitle => _t('bottleBalanceSummaryTitle');
  String get bottleBalanceOperationsTitle =>
      _t('bottleBalanceOperationsTitle');
  String get bottleBalanceOpeningBalanceLabel =>
      _t('bottleBalanceOpeningBalanceLabel');
  String get bottleBalanceClosingBalanceLabel =>
      _t('bottleBalanceClosingBalanceLabel');
  String get bottleBalanceTotalIncomeLabel =>
      _t('bottleBalanceTotalIncomeLabel');
  String get bottleBalanceTotalExpenseLabel =>
      _t('bottleBalanceTotalExpenseLabel');
  String get bottleBalanceIncomeLabel => _t('bottleBalanceIncomeLabel');
  String get bottleBalanceExpenseLabel => _t('bottleBalanceExpenseLabel');
  String get bottleBalanceBalanceLabel => _t('bottleBalanceBalanceLabel');
  String get fullWaterOpeningBalanceLabel =>
      _t('fullWaterOpeningBalanceLabel');
  String get fullWaterClosingBalanceLabel =>
      _t('fullWaterClosingBalanceLabel');
  String get fullWaterTotalIncomeLabel => _t('fullWaterTotalIncomeLabel');
  String get fullWaterTotalExpenseLabel => _t('fullWaterTotalExpenseLabel');
  String get menuSettings => _t('menuSettings');
  String get menuSecurity => _t('menuSecurity');
  String get menuAbout => _t('menuAbout');
  String get aboutDescription => _t('aboutDescription');
  String get aboutShareButton => _t('aboutShareButton');
  String get aboutUpdateButton => _t('aboutUpdateButton');
  String get aboutVersionLabel => _t('aboutVersionLabel');
  String get aboutShareMessage => _t('aboutShareMessage');
  String get aboutUpdateUnavailable => _t('aboutUpdateUnavailable');
  String get aboutShareUnavailable => _t('aboutShareUnavailable');
  String get cashReportPeriodicTitle => _t('cashReportPeriodicTitle');
  String get cashReportOnlineTitle => _t('cashReportOnlineTitle');
  String get cashReportStartDate => _t('cashReportStartDate');
  String get cashReportEndDate => _t('cashReportEndDate');
  String get cashReportPickDate => _t('cashReportPickDate');
  String get cashReportShow => _t('cashReportShow');
  String get cashReportValidationRequired => _t('cashReportValidationRequired');
  String get cashReportValidationOrder => _t('cashReportValidationOrder');
  String get cashReportRangeLabel => _t('cashReportRangeLabel');
  String get cashReportApiNotReady => _t('cashReportApiNotReady');
  String get cashReportEmptyResult => _t('cashReportEmptyResult');
  String get cashReportRetry => _t('cashReportRetry');
  String get cashReportSessionMissing => _t('cashReportSessionMissing');
  String get cashReportSummaryTitle => _t('cashReportSummaryTitle');
  String get cashReportOpeningBalanceLabel =>
      _t('cashReportOpeningBalanceLabel');
  String get cashReportClosingBalanceLabel =>
      _t('cashReportClosingBalanceLabel');
  String get cashReportTotalIncomeLabel => _t('cashReportTotalIncomeLabel');
  String get cashReportTotalExpenseLabel => _t('cashReportTotalExpenseLabel');
  String get cashReportOperationsTitle => _t('cashReportOperationsTitle');
  String get cashReportIncomeLabel => _t('cashReportIncomeLabel');
  String get cashReportExpenseLabel => _t('cashReportExpenseLabel');
  String get cashReportBalanceLabel => _t('cashReportBalanceLabel');
  String get cashReportTotalAmountLabel => _t('cashReportTotalAmountLabel');
  String get cashReportPaymentsTitle => _t('cashReportPaymentsTitle');
  String get cashReportOrderLabel => _t('cashReportOrderLabel');
  String get cashReportBuyerLabel => _t('cashReportBuyerLabel');
  String get cashReportPaymentSystemLabel => _t('cashReportPaymentSystemLabel');
  String get cashReportAmountLabel => _t('cashReportAmountLabel');
  String get themeModeTitle => _t('themeModeTitle');
  String get themeModeLight => _t('themeModeLight');
  String get themeModeDark => _t('themeModeDark');
  String get securityTitle => _t('securityTitle');
  String get securityPinTitle => _t('securityPinTitle');
  String get securityBiometricTitle => _t('securityBiometricTitle');
  String get securityChangePasswordTitle => _t('securityChangePasswordTitle');
  String get securityChangePinTitle => _t('securityChangePinTitle');
  String get securityOldPasswordLabel => _t('securityOldPasswordLabel');
  String get securityNewPasswordLabel => _t('securityNewPasswordLabel');
  String get securityConfirmPasswordLabel => _t('securityConfirmPasswordLabel');
  String get securityOldPinLabel => _t('securityOldPinLabel');
  String get securityNewPinLabel => _t('securityNewPinLabel');
  String get securityConfirmPinLabel => _t('securityConfirmPinLabel');
  String get securityUpdateButton => _t('securityUpdateButton');
  String get securityValidationRequired => _t('securityValidationRequired');
  String get securityValidationMismatch => _t('securityValidationMismatch');
  String get securityApiNotReady => _t('securityApiNotReady');
  String get securitySessionMissing => _t('securitySessionMissing');
  String get securityPasswordUpdated => _t('securityPasswordUpdated');
  String get securityPasswordUpdateFailed => _t('securityPasswordUpdateFailed');
  String get securityPinUpdated => _t('securityPinUpdated');
  String get securityPinUpdateFailed => _t('securityPinUpdateFailed');
  String get pinSetupTitle => _t('pinSetupTitle');
  String get pinSetupSubtitle => _t('pinSetupSubtitle');
  String get pinSetupLabel => _t('pinSetupLabel');
  String get pinSetupConfirmLabel => _t('pinSetupConfirmLabel');
  String get pinSetupSave => _t('pinSetupSave');
  String get pinSetupCancel => _t('pinSetupCancel');
  String get pinSetupErrorLength => _t('pinSetupErrorLength');
  String get pinSetupErrorMismatch => _t('pinSetupErrorMismatch');
  String get pinUnlockTitle => _t('pinUnlockTitle');
  String get pinUnlockSubtitle => _t('pinUnlockSubtitle');
  String get pinUnlockButton => _t('pinUnlockButton');
  String get pinUnlockError => _t('pinUnlockError');
  String get biometricButton => _t('biometricButton');
  String get biometricReason => _t('biometricReason');
  String get biometricUnavailable => _t('biometricUnavailable');
  String get biometricFailed => _t('biometricFailed');

  static String _localeKey(Locale locale) {
    if (locale.languageCode == 'uz') {
      return 'uz_${locale.scriptCode ?? 'Latn'}';
    }
    return locale.languageCode;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(
      AppLocalizations(AppLocalizations.resolveLocale(locale)),
    );
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
