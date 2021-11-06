import 'package:flutter/widgets.dart';

import 'localization.dart';

class ExplorerLocalizationsDelegate
    extends LocalizationsDelegate<ExplorerLocalizations> {
  const ExplorerLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ru', 'fr'].contains(locale.languageCode);

  @override
  Future<ExplorerLocalizations> load(Locale locale) =>
      ExplorerLocalizations.load(locale);

  @override
  bool shouldReload(ExplorerLocalizationsDelegate old) => false;
}
