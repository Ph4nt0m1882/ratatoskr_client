import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Importez vos fichiers auto-générés (s'il souligne en rouge, relancez `flutter gen-l10n`)
import 'l10n/app_localizations.dart';

// Importez vos fichiers internes
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/chat/chat_screen.dart';

void main() {
  runApp(
    // ProviderScope enveloppe toute l'app pour activer Riverpod !
    const ProviderScope(child: RatatoskrApp()),
  );
}

class RatatoskrApp extends ConsumerWidget {
  const RatatoskrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute le gestionnaire de thème. Si la valeur change, toute l'app se redessine instantanément.
    final currentThemeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // -- GESTION DES LANGUES (i18n) --
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // Anglais (Défaut)
        Locale('fr', ''), // Français
      ],

      // -- GESTION DU THÈME --
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentThemeMode,

      // -- PREMIER ÉCRAN --
      home: const ChatScreen(),
    );
  }
}
