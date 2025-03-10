library chat_bot_sdk;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/chat/chat_page.dart';
import 'src/config/sdk_config.dart';
import 'l10n/app_localizations.dart';

/// Entry point for the Chat Bot SDK
class ChatBotSdk {
  /// Initialize the SDK with configuration
  /// 
  /// [apiKey] - The API key for authenticating with Dify.ai
  /// [apiEndpoint] - Optional custom API endpoint (default: https://api.dify.ai/v1)
  /// [appId] - Optional application ID (not required for API calls)
  static void initialize({
    required String apiKey,
    String apiEndpoint = 'https://api.dify.ai/v1',
    String? appId,
  }) {
    print('Initializing ChatBotSdk with endpoint: $apiEndpoint');
    SdkConfig.instance.initialize(
      apiKey: apiKey,
      apiEndpoint: apiEndpoint,
      appId: appId,
    );
  }

  /// Start a chat session
  /// 
  /// This launches the chat interface as a new screen
  /// 
  /// [context] - BuildContext for navigation
  /// [title] - Optional title for the chat page (default is localized 'Chat Assistant')
  /// [initialMessage] - Optional initial bot message
  /// [themeData] - Optional custom theme
  /// [locale] - Optional locale for localization (defaults to system locale)
  /// [thinkingWidget] - Optional custom widget to display when the bot is thinking (replaces default "_Thinking..._" text)
  static Future<void> startChat({
    required BuildContext context,
    String? title,
    String? initialMessage,
    ThemeData? themeData,
    Locale? locale,
    Widget? thinkingWidget,
    Widget? emptyWidget,
  }) async {
    // Verify SDK is initialized
    if (!SdkConfig.instance.isInitialized) {
      throw Exception('ChatBotSdk is not initialized. Call ChatBotSdk.initialize() first.');
    }    
    // Launch the chat page
    await Navigator.of(context).push(
       MaterialPageRoute(
        builder: (context) => ProviderScope(
          child: Builder(
            builder: (context) => Localizations(
              locale: locale ?? Localizations.localeOf(context),
              delegates: ChatBotLocalizationsSetup.localizationsDelegates,
              child: Theme(
                data: themeData ?? Theme.of(context),
                child: ChatPage(
                  title: title,
                  initialMessage: initialMessage,
                  themeData: themeData ?? Theme.of(context),
                  thinkingWidget: thinkingWidget,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 