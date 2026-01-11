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
