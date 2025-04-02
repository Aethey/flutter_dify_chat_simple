import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../models/chat_history.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../config/sdk_config.dart';

/// Provider for chat service instance
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

/// Error type for localized error handling
enum ChatErrorType {
  /// Generic error
  generic,

  /// Network error
  network,

  /// Connection timeout
  connectionTimeout,

  /// Receive timeout
  receiveTimeout,

  /// Send timeout
  sendTimeout,

  /// Connection error
  connectionError,

  /// Request cancelled
  requestCancelled,

  /// Server error
  serverError
}

/// Error information class
class ErrorInfo {
  /// Type of the error
  final ChatErrorType type;

  /// Parameters for the error message
  final Map<String, dynamic>? params;

  /// Constructor
  const ErrorInfo(this.type, this.params);
}

/// State class for chat
class ChatState {
  /// The chat history containing all messages
  final ChatHistory chatHistory;

  /// Whether the chat is currently loading/processing
  final bool isLoading;

  /// Whether history is being loaded
  final bool isLoadingHistory;

  /// Any error message that occurred (raw error code)
  final String? errorMessage;

  /// Error type for localization
  final ChatErrorType? errorType;

  /// Additional error parameters
  final Map<String, dynamic>? errorParams;

  /// Current conversation ID
  final String? conversationId;

  /// Whether this is the first display (for animation)
  final bool isFirstDisplay;

  /// Constructor
  ChatState({
    ChatHistory? chatHistory,
    this.isLoading = false,
    this.isLoadingHistory = false,
    this.errorMessage,
    this.errorType,
    this.errorParams,
    this.conversationId,
    this.isFirstDisplay = true,
  }) : chatHistory = chatHistory ?? ChatHistory();

  /// Create a copy of this state with updated fields
  ChatState copyWith({
    ChatHistory? chatHistory,
    bool? isLoading,
    bool? isLoadingHistory,
    String? errorMessage,
    ChatErrorType? errorType,
    Map<String, dynamic>? errorParams,
    String? conversationId,
    bool? isFirstDisplay,
  }) {
    return ChatState(
      chatHistory: chatHistory ?? this.chatHistory,
      isLoading: isLoading ?? this.isLoading,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      errorMessage: errorMessage,
      errorType: errorType,
      errorParams: errorParams,
      conversationId: conversationId ?? this.conversationId,
      isFirstDisplay: isFirstDisplay ?? this.isFirstDisplay,
    );
  }

  /// Get the localized error message
  String? getLocalizedErrorMessage(BuildContext context) {
    if (errorMessage == null || errorType == null) return null;

    switch (errorType!) {
      case ChatErrorType.connectionTimeout:
        return context.l10n.connectionTimeout;
      case ChatErrorType.receiveTimeout:
        return context.l10n.receiveTimeout;
      case ChatErrorType.sendTimeout:
        return context.l10n.sendTimeout;
      case ChatErrorType.connectionError:
        return context.l10n.connectionError;
      case ChatErrorType.requestCancelled:
        return context.l10n.requestCancelled;
      case ChatErrorType.serverError:
        final statusCode = errorParams?['statusCode'] ?? '';
        final message = errorParams?['message'] ?? '';
        return context.l10n
            .serverError('{statusCode}', statusCode.toString())
            .replaceAll('{message}', message.toString());
      case ChatErrorType.network:
        final message = errorParams?['message'] ?? '';
        return context.l10n.networkError(message);
      case ChatErrorType.generic:
        return context.l10n.genericError;
    }
  }
}

/// Chat notifier to manage chat state
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;

  /// Constructor
  ChatNotifier(this._chatService) : super(ChatState());

  /// Load conversation history
  Future<void> loadConversationHistory(
      String conversationId, String userId) async {
    if (conversationId.isEmpty) return;

    // Update state to show loading
    state = state.copyWith(
      isLoadingHistory: true,
      conversationId: conversationId,
      chatHistory: ChatHistory(),
      // Clear history for new conversation
      errorMessage: null,
      errorType: null,
      errorParams: null,
    );

    try {
      // Fetch message history
      final messages =
          await _chatService.fetchConversationHistory(conversationId, userId);

      // Create a new chat history with the messages
      final ChatHistory chatHistory = ChatHistory();
      for (final message in messages) {
        chatHistory.addMessage(message);
      }

      // 确保ChatService也知道当前对话ID
      _chatService.lastConversationId = conversationId;

      // Update state with the messages
      state = state.copyWith(
        chatHistory: chatHistory,
        isLoadingHistory: false,
        conversationId: conversationId,
      );
    } catch (e) {
      // Parse error message
      final errorInfo = _parseErrorMessage(e.toString());

      // Update state to show error
      state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: e.toString(),
        errorType: errorInfo.type,
        errorParams: errorInfo.params,
      );
    }
  }

  /// Send a message to the chat and get response
  Future<void> sendMessage(String message, String userID,
      {String? conversationId}) async {
    debugPrint(
        'sendMessage: message=$message, conversationId=$conversationId, current state.conversationId=${state.conversationId}');

    // Handle special message: clear chat history
    if (message == 'clear_history') {
      debugPrint('Clearing history, starting new conversation');
      clearChat();
      return;
    }

    // Handle special message: new conversation with animation
    if (message == 'new_conversation_with_animation') {
      debugPrint('Starting new conversation with animation');
      // First clear chat and show animation
      clearChat();

      // After 1 second delay, add initial message and complete animation
      Future.delayed(const Duration(seconds: 1), () {
        // Get configured initial message
        final initialMessage = SdkConfig.instance.initialMessage ??
            "Hello! How can I help you today?";

        // Create chat history with initial message
        final chatHistory = ChatHistory();
        chatHistory.addMessage(ChatMessage.assistant(content: initialMessage));

        // Update state, set initial message and end animation display
        state = ChatState(chatHistory: chatHistory, isFirstDisplay: false);
      });
      return;
    }

    if (conversationId == null &&
        message.trim().isEmpty &&
        state.conversationId != null) {
      // Just clear current conversation, don't create new one immediately
      debugPrint('Clearing current conversation, not creating a new one');
      state = ChatState();
      return;
    }

    if (message.trim().isEmpty &&
        (conversationId == null && state.conversationId == null)) {
      debugPrint('Empty message with no conversationId, ignoring');
      return;
    }

    if (message.trim().isEmpty && conversationId != null) {
      debugPrint('Loading conversation from history: $conversationId');
      await loadConversationHistory(conversationId, userID);
      return;
    }

    // Handle case with actual message content - normal message flow
    debugPrint(
        'Sending new message, using conversation ID: ${conversationId ?? state.conversationId}');

    // Use provided conversationId or current state's conversationId
    final currentConversationId = conversationId ?? state.conversationId;

    // Add user message to chat history
    final userMessage = ChatMessage.user(content: message);
    state.chatHistory.addMessage(userMessage);

    // Create placeholder for assistant reply
    final assistantMessage = ChatMessage.assistant(
      content: '',
      status: MessageStatus.sending,
    );
    state.chatHistory.addMessage(assistantMessage);

    // Update state to show loading
    state = state.copyWith(
      chatHistory: state.chatHistory,
      isLoading: true,
      errorMessage: null,
      errorType: null,
      errorParams: null,
      conversationId: currentConversationId,
    );

    try {
      // Listen to streaming response
      _chatService
          .streamMessage(state.chatHistory, userID,
              conversationId: currentConversationId)
          .listen(
        (response) {
          // Get current messages (excluding placeholder)
          final messages = List<ChatMessage>.from(state.chatHistory.messages);

          // Replace placeholder with streaming message
          if (messages.isNotEmpty &&
              messages.last.role == MessageRole.assistant) {
            messages.last = response;
          } else {
            messages.add(response);
          }

          // Update state with new messages
          state = state.copyWith(
            chatHistory: state.chatHistory.copyWith(messages: messages),
            isLoading: response.status == MessageStatus.streaming,
          );
        },
        onError: (error) {
          final errorInfo = _parseErrorMessage(error.toString());
          state = state.copyWith(
            isLoading: false,
            errorMessage: error.toString(),
            errorType: errorInfo.type,
            errorParams: errorInfo.params,
          );
        },
        onDone: () {
          // Get conversation ID from ChatService
          final newConversationId = _chatService.lastConversationId;
          // Only update if we actually received a conversation ID
          if (newConversationId != null && newConversationId.isNotEmpty) {
            state = state.copyWith(
              isLoading: false,
              conversationId: newConversationId,
            );
          } else {
            state = state.copyWith(isLoading: false);
          }
        },
      );
    } catch (e) {
      // Parse error message
      final errorInfo = _parseErrorMessage(e.toString());

      // Update state to show error
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        errorType: errorInfo.type,
        errorParams: errorInfo.params,
      );

      // Update placeholder message to show error
      final messages = List<ChatMessage>.from(state.chatHistory.messages);
      if (messages.isNotEmpty && messages.last.role == MessageRole.assistant) {
        messages.last = ChatMessage.assistant(
          content: 'Error: Failed to get response',
          status: MessageStatus.error,
        );

        state = state.copyWith(
          chatHistory: state.chatHistory.copyWith(messages: messages),
        );
      }
    }
  }

  /// Set current conversation ID
  void setConversationId(String? conversationId) {
    state = state.copyWith(conversationId: conversationId);
  }

  /// Clear the chat history
  void clearChat() {
    state = ChatState(isFirstDisplay: true);
  }

  /// Set initial state with a welcome message (without triggering API calls)
  void setInitialState(ChatState newState) {
    state = newState;
  }

  /// Parse error message and return error type and params
  ErrorInfo _parseErrorMessage(String errorMsg) {
    if (errorMsg.contains('CONNECTION_TIMEOUT')) {
      return const ErrorInfo(ChatErrorType.connectionTimeout, null);
    } else if (errorMsg.contains('RECEIVE_TIMEOUT')) {
      return const ErrorInfo(ChatErrorType.receiveTimeout, null);
    } else if (errorMsg.contains('SEND_TIMEOUT')) {
      return const ErrorInfo(ChatErrorType.sendTimeout, null);
    } else if (errorMsg.contains('CONNECTION_ERROR')) {
      return const ErrorInfo(ChatErrorType.connectionError, null);
    } else if (errorMsg.contains('REQUEST_CANCELLED')) {
      return const ErrorInfo(ChatErrorType.requestCancelled, null);
    } else if (errorMsg.contains('SERVER_ERROR')) {
      final parts = errorMsg.split(':');
      if (parts.length >= 3) {
        return ErrorInfo(ChatErrorType.serverError, {
          'statusCode': parts[1],
          'message': parts.sublist(2).join(':'),
        });
      }
      return ErrorInfo(
          ChatErrorType.serverError, {'statusCode': '?', 'message': errorMsg});
    } else if (errorMsg.contains('NETWORK_ERROR')) {
      final message = errorMsg.replaceFirst('NETWORK_ERROR:', '');
      return ErrorInfo(ChatErrorType.network, {'message': message});
    }
    return const ErrorInfo(ChatErrorType.generic, null);
  }

  void setAnimationCompleted() {
    state = state.copyWith(isFirstDisplay: false);
  }
}

/// Provider for chat state
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return ChatNotifier(chatService);
});
