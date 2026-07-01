import 'package:flutter/material.dart';
import 'app_localizations.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['sw', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode, locale.countryCode);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}
