import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_localizations.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit()
      : super(
          AppLocalizations.resolveLocale(
            WidgetsBinding.instance.platformDispatcher.locale,
          ),
        );

  void setLocale(Locale locale) {
    emit(AppLocalizations.resolveLocale(locale));
  }
}
