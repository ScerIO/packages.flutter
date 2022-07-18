import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'messages/messages_all.dart';
import 'string_resources.dart';

class ExplorerLocalizations with StringResources {
  static Future<ExplorerLocalizations> load(Locale locale) async {
    final String localeName =
        locale.countryCode == null || locale.countryCode!.isEmpty
            ? locale.languageCode
            : locale.toString();
    final String canonicalLocaleName = Intl.canonicalizedLocale(localeName);
    Intl.defaultLocale = canonicalLocaleName;
    // print('canonicalLocaleName $canonicalLocaleName');
    await initializeMessages(canonicalLocaleName);
    return ExplorerLocalizations();
  }

  static ExplorerLocalizations? of(BuildContext context) =>
      Localizations.of<ExplorerLocalizations>(context, ExplorerLocalizations);
}
