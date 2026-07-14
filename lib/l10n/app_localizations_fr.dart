// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Ratatoskr';

  @override
  String get chatPlaceholder => 'Envoyez une commande ou un message...';

  @override
  String themeCommand(Object themeName) {
    return 'Thème basculé sur $themeName';
  }
}
