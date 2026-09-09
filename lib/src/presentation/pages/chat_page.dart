import 'dart:math' as math;

import 'package:chat_bot_sdk/custom/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/config/sdk_config.dart';
import '../../domain/entities/chat_history.dart';
import '../../domain/entities/chat_message.dart';
import '../config/chat_input_bar_config.dart';
import '../state/chat_notifier.dart';
import '../state/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

/// Main chat interface page
class ChatPage extends ConsumerStatefulWidget {
  final String? title;
  final String userID;
  final String? initialMessage;
  final ThemeData? themeData;
  final Widget? thinkingWidget;
  final Widget? emptyWidget;
  final String? conversationId;
  final ChatInputBarConfig inputBarConfig;

  const ChatPage({
    super.key,
    this.title,
    this.initialMessage,
    this.themeData,
    this.thinkingWidget,
    required this.userID,
    this.emptyWidget,
    this.conversationId,
    this.inputBarConfig = const ChatInputBarConfig(),
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  static const _atBottomThreshold = 72.0;

  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;
  String _lastMessageContent = '';

  /// View-only flag; ValueNotifier keeps rebuilds scoped to the arrow button.
  final ValueNotifier<bool> _isAtBottom = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);

    if (widget.conversationId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatProvider.notifier).clearChat();

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
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
              ChatState(chatHistory: chatHistory, isFirstDisplay: false),
            );
          }
        });
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatProvider.notifier).loadConversationHistory(
              widget.conversationId!,
              widget.userID,
            );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _isAtBottom.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // ValueNotifier skips notifications when the value is unchanged.
    _isAtBottom.value =
        position.pixels >= position.maxScrollExtent - _atBottomThreshold;
  }

  void _scrollToBottom({bool force = false}) {
    if (!force && !_isAtBottom.value) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _jumpToLatest() {
    _isAtBottom.value = true;
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onChatStateChanged(ChatState next) {
    final messages = next.chatHistory.messages;
    if (messages.length != _lastMessageCount) {
      _lastMessageCount = messages.length;
      _scrollToBottom();
    } else if (messages.isNotEmpty &&
        messages.last.content != _lastMessageContent) {
      _lastMessageContent = messages.last.content;
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);

    // Auto-scroll runs on state change only, not on every rebuild.
    ref.listen<ChatState>(chatProvider, (_, next) => _onChatStateChanged(next));

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
        body: LayoutBuilder(
          builder: (context, constraints) {
            const minListH = 96.0;
            final errorH = chatState.errorMessage != null ? 48.0 : 0.0;
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Listener(
                        behavior: HitTestBehavior.translucent,
                        onPointerDown: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        child: chatState.isLoadingHistory
                            ? _buildLoadingState(context)
                            : chatState.isFirstDisplay &&
                                    widget.emptyWidget != null
                                ? widget.emptyWidget!
                                : chatState.chatHistory.messages.isEmpty
                                    ? _buildEmptyState(context)
                                    : _buildChatList(context, chatState),
                      ),
                      // Hidden while streaming to avoid flicker; shown again
                      // based on scroll position once generation completes.
                      if (!chatState.isLoading &&
                          !chatState.isLoadingHistory &&
                          chatState.chatHistory.messages.isNotEmpty)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 8,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _isAtBottom,
                            builder: (context, atBottom, child) => atBottom
                                ? const SizedBox.shrink()
                                : child!,
                            child: Center(
                              child: _buildScrollToBottomButton(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: math.max(
                      120,
                      constraints.maxHeight - minListH - errorH,
                    ),
                  ),
                  child: MessageInput(
                    onSendMessage: (message, conversationId, [files]) {
                      final actualConversationId =
                          conversationId ?? chatState.conversationId;
                      chatNotifier.sendMessage(
                        message,
                        widget.userID,
                        conversationId: actualConversationId,
                        files: files ?? const [],
                      );
                      _isAtBottom.value = true;
                      _scrollToBottom(force: true);
                    },
                    userId: widget.userID,
                    inputBarConfig: widget.inputBarConfig,
                    isLoading: chatState.isLoading,
                    isLoadingHistory: chatState.isLoadingHistory,
                    hintText: context.l10n.typeMessage,
                    conversationId: chatState.conversationId,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScrollToBottomButton(BuildContext context) {
    final accent = customColor0 ?? Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        key: const Key('chat_scroll_to_bottom'),
        customBorder: const CircleBorder(),
        onTap: _jumpToLatest,
        child: Tooltip(
          message: context.l10n.scrollToBottom,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.keyboard_arrow_down,
              color: accent,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context, ChatState chatState) {
    return ListView.builder(
      controller: _scrollController,
      reverse: false,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      itemCount: chatState.chatHistory.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.chatHistory.messages[index];
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
    );

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
    // AnimatedBuilder repaints only this dot, no setState per frame.
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.3 + _animation.value * 0.7),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
