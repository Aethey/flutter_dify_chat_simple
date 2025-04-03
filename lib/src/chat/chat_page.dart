import 'package:chat_bot_sdk/custom/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../config/sdk_config.dart';
import '../models/chat_history.dart';
import '../models/message.dart';
import '../state/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

/// Main chat interface page
class ChatPage extends ConsumerStatefulWidget {
  /// Title of the chat page
  final String? title;
  final String userID;

  /// Optional initial bot message
  final String? initialMessage;

  /// Optional custom theme
  final ThemeData? themeData;

  /// Optional custom widget to display when the bot is thinking
  final Widget? thinkingWidget;

  /// Optional custom widget to display when the chat is none
  final Widget? emptyWidget;

  /// Optional conversation ID to load an existing conversation
  final String? conversationId;

  /// Constructor
  const ChatPage(
      {super.key,
      this.title,
      this.initialMessage,
      this.themeData,
      this.thinkingWidget,
      required this.userID,
      this.emptyWidget,
      this.conversationId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;
  String _lastMessageContent = '';

  @override
  void initState() {
    super.initState();

    if (widget.conversationId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatProvider.notifier).clearChat();

        Future.delayed(const Duration(seconds: 1), () {
          final message = widget.initialMessage ??
              SdkConfig.instance.initialMessage ??
              context.l10n.initialMessage;

          final assistantMessage = ChatMessage.assistant(
            content: message,
          );

          final chatHistory = ChatHistory();
          chatHistory.addMessage(assistantMessage);

          final chatNotifier = ref.read(chatProvider.notifier);
          chatNotifier.setInitialState(
              ChatState(chatHistory: chatHistory, isFirstDisplay: false));
        });
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Load the conversation history
        ref.read(chatProvider.notifier).loadConversationHistory(
              widget.conversationId!,
              widget.userID,
            );
      });
    }
  }

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
              child: chatState.isLoadingHistory
                  ? _buildLoadingState(context)
                  : chatState.isFirstDisplay && widget.emptyWidget != null
                      // 首次显示且提供了emptyWidget时显示动画
                      ? widget.emptyWidget!
                      : chatState.chatHistory.messages.isEmpty
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
                  chatState.getLocalizedErrorMessage(context) ??
                      context.l10n.genericError,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Input area
            MessageInput(
              onSendMessage: (message, conversationId) {
                final actualConversationId =
                    conversationId ?? chatState.conversationId;
                chatNotifier.sendMessage(message, widget.userID,
                    conversationId: actualConversationId);
                // Scroll after sending a message
                _scrollToBottom();
              },
              isLoading: chatState.isLoading,
              isLoadingHistory: chatState.isLoadingHistory,
              hintText: context.l10n.typeMessage,
              userId: widget.userID,
              conversationId: chatState.conversationId,
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

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Three-dot loading animation
          Container(
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: LoadingDot(
                      color: customColor0 ?? Colors.blue,
                      delay: Duration(milliseconds: 300 * i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.loadingConversation,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: customColor0,
                ),
          ),
        ],
      ),
    );
  }
}

/// Animated loading dot for the three-dot loading animation
class LoadingDot extends StatefulWidget {
  final Color color;
  final Duration delay;

  const LoadingDot({
    super.key,
    required this.color,
    required this.delay,
  });

  @override
  State<LoadingDot> createState() => _LoadingDotState();
}

class _LoadingDotState extends State<LoadingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {});
      });

    // Start the animation after the delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.3 + _animation.value * 0.7),
        shape: BoxShape.circle,
      ),
    );
  }
}
