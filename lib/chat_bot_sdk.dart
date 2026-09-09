import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'src/core/config/sdk_config.dart';
import 'src/data/datasources/conversation_local_datasource.dart';
import 'src/data/repositories/conversation_repository_impl.dart';
import 'src/domain/usecases/delete_conversation.dart';
import 'src/domain/usecases/list_conversations.dart';
import 'src/presentation/config/chat_input_bar_config.dart';
import 'src/presentation/history/show_conversation_history.dart';
import 'src/presentation/pages/chat_page.dart';

export 'src/presentation/config/chat_input_bar_config.dart';

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
    debugPrint('Initializing ChatBotSdk with endpoint: $apiEndpoint');
    SdkConfig.instance.initialize(
      apiKey: apiKey,
      apiEndpoint: apiEndpoint,
      appId: appId,
    );
  }

  /// Start a chat session
  static Future<void> startChat({
    required BuildContext context,
    String? title,
    String? initialMessage,
    ThemeData? themeData,
    Locale? locale,
    Widget? thinkingWidget,
    Widget? emptyWidget,
    required String userID,
    String? conversationId,
    ChatInputBarConfig inputBarConfig = const ChatInputBarConfig(),
  }) async {
    if (!SdkConfig.instance.isInitialized) {
      throw Exception(
        'ChatBotSdk is not initialized. Call ChatBotSdk.initialize() first.',
      );
    }

    if (initialMessage != null) {
      SdkConfig.instance.setInitialMessage(initialMessage);
    }

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
                  emptyWidget: emptyWidget,
                  userID: userID,
                  conversationId: conversationId,
                  inputBarConfig: inputBarConfig,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Open conversation history from any host-app screen.
  static Future<void> showHistory({
    required BuildContext context,
    required String userId,
    ThemeData? themeData,
    Locale? locale,
    void Function(String conversationId)? onConversationSelected,
    VoidCallback? onNewConversation,
  }) {
    final repository = _conversationRepository();
    return showConversationHistory(
      context: context,
      themeData: themeData,
      locale: locale,
      loadConversations: () => ListConversations(repository)(userId),
      deleteConversation: (conversationId) => DeleteConversation(repository)(
        userId: userId,
        conversationId: conversationId,
      ),
      onConversationSelected: onConversationSelected,
      onNewConversation: onNewConversation,
    );
  }

  /// Get all conversations for a user
  static Future<List<Map<String, dynamic>>> getConversations(
    String userId,
  ) async {
    final conversations = await ListConversations(_conversationRepository())(
      userId,
    );
    return conversations.map((item) => item.toMap()).toList();
  }

  /// Delete a conversation
  static Future<void> deleteConversation(
    String userId,
    String conversationId,
  ) async {
    await DeleteConversation(_conversationRepository())(
      userId: userId,
      conversationId: conversationId,
    );
  }

  static ConversationRepositoryImpl _conversationRepository() {
    return ConversationRepositoryImpl(ConversationLocalDataSource());
  }
}
