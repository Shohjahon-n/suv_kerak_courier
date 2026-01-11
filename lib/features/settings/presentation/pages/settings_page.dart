import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = context.select((LocaleCubit cubit) => cubit.state);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.languageTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...AppLocalizations.supportedLocales.map(
            (locale) => RadioListTile<Locale>(
              value: locale,
              groupValue: currentLocale,
              title: Text(_languageLabel(l10n, locale)),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                context.read<LocaleCubit>().setLocale(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _languageLabel(AppLocalizations l10n, Locale locale) {
    if (locale.languageCode == 'ru') {
      return l10n.languageRussian;
    }
    if (locale.languageCode == 'uz' && locale.scriptCode == 'Cyrl') {
      return l10n.languageUzbekCyrillic;
    }
    if (locale.languageCode == 'uz') {
      return l10n.languageUzbekLatin;
    }
    return l10n.languageEnglish;
  }
}
