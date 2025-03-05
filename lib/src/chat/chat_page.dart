import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import '../state/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../../l10n/app_localizations.dart';

/// Main chat interface page
class ChatPage extends ConsumerWidget {
  /// Title of the chat page
  final String? title;
  
  /// Optional initial bot message
  final String? initialMessage;
  
  /// Optional custom theme
  final ThemeData? themeData;
  
  /// Constructor
  const ChatPage({
    super.key,
    this.title,
    this.initialMessage,
    this.themeData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);
    
    // Check if this is the first build and we have an initial message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialMessage != null && 
          chatState.chatHistory.messages.isEmpty) {
        final assistantMessage = ChatMessage.assistant(
          content: initialMessage!,
        );
        chatState.chatHistory.addMessage(assistantMessage);
        // Force a rebuild
        ref.read(chatProvider.notifier).clearChat();
        ref.read(chatProvider.notifier).sendMessage('');
      } else if (chatState.chatHistory.messages.isEmpty) {
        // Use localized initial message if none provided
        final assistantMessage = ChatMessage.assistant(
          content: context.l10n.initialMessage,
        );
        chatState.chatHistory.addMessage(assistantMessage);
        // Force a rebuild
        ref.read(chatProvider.notifier).clearChat();
        ref.read(chatProvider.notifier).sendMessage('');
      }
    });
    
    // Use local theme data or from parent
    final effectiveTheme = themeData ?? Theme.of(context);
    
    return Theme(
      data: effectiveTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title ?? context.l10n.chatTitle),
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: chatState.isLoading 
                  ? null 
                  : () => _showResetConfirmation(context, chatNotifier),
              tooltip: context.l10n.resetChat,
            ),
          ],
        ),
        body: Column(
          children: [
            // Chat messages list
            Expanded(
              child: chatState.chatHistory.messages.isEmpty
                  ? _buildEmptyState(context)
                  : _buildChatList(context, chatState),
            ),
            
            // Error message display if any
            if (chatState.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.red.shade100,
                width: double.infinity,
                child: Text(
                  chatState.getLocalizedErrorMessage(context) ?? context.l10n.genericError,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            
            // Input area
            MessageInput(
              onSendMessage: (message) => chatNotifier.sendMessage(message),
              isLoading: chatState.isLoading,
              hintText: context.l10n.typeMessage,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChatList(BuildContext context, ChatState chatState) {
    return ListView.builder(
      reverse: false,
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      itemCount: chatState.chatHistory.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.chatHistory.messages[index];
        
        // Skip system messages
        if (message.role == MessageRole.system) {
          return const SizedBox.shrink();
        }
        
        return MessageBubble(message: message);
      },
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.startConversation,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.typeToBegin,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _showResetConfirmation(
    BuildContext context, 
    ChatNotifier chatNotifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.resetChat),
        content: Text(context.l10n.resetChatConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.reset),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      chatNotifier.clearChat();
    }
  }
} 