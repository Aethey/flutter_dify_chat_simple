import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_history.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../../l10n/app_localizations.dart';

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
  
  /// Any error message that occurred (raw error code)
  final String? errorMessage;
  
  /// Error type for localization
  final ChatErrorType? errorType;
  
  /// Additional error parameters
  final Map<String, dynamic>? errorParams;
  
  /// Constructor
  ChatState({
    ChatHistory? chatHistory,
    this.isLoading = false,
    this.errorMessage,
    this.errorType,
    this.errorParams,
  }) : chatHistory = chatHistory ?? ChatHistory();
  
  /// Create a copy of this state with updated fields
  ChatState copyWith({
    ChatHistory? chatHistory,
    bool? isLoading,
    String? errorMessage,
    ChatErrorType? errorType,
    Map<String, dynamic>? errorParams,
  }) {
    return ChatState(
      chatHistory: chatHistory ?? this.chatHistory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      errorType: errorType,
      errorParams: errorParams,
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
        return context.l10n.serverError('{statusCode}', statusCode.toString())
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
  
  /// Send a message to the chat and get response
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    
    // Add user message to chat
    final userMessage = ChatMessage.user(content: message);
    state.chatHistory.addMessage(userMessage);
    
    // Create placeholder for assistant response
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
    );
    
    try {
      // Listen to the streaming response
      _chatService.streamMessage(state.chatHistory).listen(
        (response) {
          // Get the current messages excluding the placeholder
          final messages = List<ChatMessage>.from(state.chatHistory.messages);
          
          // Replace the placeholder with the streaming message
          if (messages.isNotEmpty && messages.last.role == MessageRole.assistant) {
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
          state = state.copyWith(isLoading: false);
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
      
      // Update the placeholder message to show error
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
  
  /// Clear the chat history
  void clearChat() {
    state = ChatState();
  }
  
  /// Parse error message and return error type and params
  ErrorInfo _parseErrorMessage(String errorMsg) {
    if (errorMsg.contains('CONNECTION_TIMEOUT')) {
      return ErrorInfo(ChatErrorType.connectionTimeout, null);
    } else if (errorMsg.contains('RECEIVE_TIMEOUT')) {
      return ErrorInfo(ChatErrorType.receiveTimeout, null);
    } else if (errorMsg.contains('SEND_TIMEOUT')) {
      return ErrorInfo(ChatErrorType.sendTimeout, null);
    } else if (errorMsg.contains('CONNECTION_ERROR')) {
      return ErrorInfo(ChatErrorType.connectionError, null);
    } else if (errorMsg.contains('REQUEST_CANCELLED')) {
      return ErrorInfo(ChatErrorType.requestCancelled, null);
    } else if (errorMsg.contains('SERVER_ERROR')) {
      final parts = errorMsg.split(':');
      if (parts.length >= 3) {
        return ErrorInfo(ChatErrorType.serverError, {
          'statusCode': parts[1],
          'message': parts.sublist(2).join(':'),
        });
      }
      return ErrorInfo(ChatErrorType.serverError, {'statusCode': '?', 'message': errorMsg});
    } else if (errorMsg.contains('NETWORK_ERROR')) {
      final message = errorMsg.replaceFirst('NETWORK_ERROR:', '');
      return ErrorInfo(ChatErrorType.network, {'message': message});
    }
    return ErrorInfo(ChatErrorType.generic, null);
  }
}

/// Provider for chat state
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return ChatNotifier(chatService);
}); 