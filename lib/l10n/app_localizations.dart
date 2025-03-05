import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../localization/chat_bot_localizations.dart';

/// Extension for easy access to localizations
extension BuildContextExtensions on BuildContext {
  /// Get localized strings
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Localization support for the chat bot SDK
class ChatBotLocalizationsSetup {
  /// Get the supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('ja', ''), // Japanese
    Locale('zh', ''), // Chinese
  ];
  
  /// Get the localization delegates
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  
  /// Get the locale resolution callback
  static Locale? localeResolutionCallback(
    Locale? locale,
    Iterable<Locale> supportedLocales,
  ) {
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale?.languageCode) {
        return supportedLocale;
      }
    }
    return supportedLocales.first;
  }
} 