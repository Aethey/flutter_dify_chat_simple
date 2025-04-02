import 'package:chat_bot_sdk/custom/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../models/message.dart';
import '../state/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

/// Main chat interface page
class ChatPage extends ConsumerStatefulWidget {
  /// Title of the chat page
  final String? title;

  /// Optional initial bot message
  final String? initialMessage;

  /// Optional custom theme
  final ThemeData? themeData;

  /// Optional custom widget to display when the bot is thinking
  final Widget? thinkingWidget;

  /// Optional custom widget to display when the chat is none
  final Widget? emptyWidget;

  /// Constructor
  const ChatPage(
      {super.key,
      this.title,
      this.initialMessage,
      this.themeData,
      this.thinkingWidget,
      this.emptyWidget});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;
  String _lastMessageContent = '';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // Use a small delay to ensure the layout is complete
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);

    // Check if this is the first build and we have an initial message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialMessage != null &&
          chatState.chatHistory.messages.isEmpty) {
        final assistantMessage = ChatMessage.assistant(
          content: widget.initialMessage!,
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

    // Check if we need to scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if messages count changed
      if (chatState.chatHistory.messages.length != _lastMessageCount) {
        _lastMessageCount = chatState.chatHistory.messages.length;
        _scrollToBottom();
      }
      // Check if last message content changed (for streaming)
      else if (chatState.chatHistory.messages.isNotEmpty) {
        final lastMsg = chatState.chatHistory.messages.last;
        if (lastMsg.content != _lastMessageContent) {
          _lastMessageContent = lastMsg.content;
          _scrollToBottom();
        }
      }
    });

    // Use local theme data or from parent
    final effectiveTheme = widget.themeData ?? Theme.of(context);

    return Theme(
      data: effectiveTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title ?? context.l10n.chatTitle,
            style: TextStyle(color: customColor0),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: customColor0,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.grey[200],
        body: Column(
          children: [
            // Chat messages list
            Expanded(
              child: chatState.chatHistory.messages.isEmpty
                  ? (widget.emptyWidget ?? _buildEmptyState(context))
                  : _buildChatList(context, chatState),
            ),

            // Error message display if any
            if (chatState.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.red.shade100,
                width: double.infinity,
                child: Text(
                  chatState.getLocalizedErrorMessage(context) ??
                      context.l10n.genericError,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Input area
            MessageInput(
              onSendMessage: (message) {
                chatNotifier.sendMessage(message);
                // Scroll after sending a message
                _scrollToBottom();
              },
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
      controller: _scrollController,
      reverse: false,
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      itemCount: chatState.chatHistory.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.chatHistory.messages[index];

        // Skip system messages
        if (message.role == MessageRole.system) {
          return const SizedBox.shrink();
        }

        return MessageBubble(
          message: message,
          thinkingWidget: widget.thinkingWidget,
        );
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
            color: customColor0,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.startConversation,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: customColor0,
                ),
          ),
        ],
      ),
    );
  }
}
