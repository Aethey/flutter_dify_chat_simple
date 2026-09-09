import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/sdk_config.dart';
import '../../domain/entities/chat_file_attachment.dart';
import '../../domain/entities/chat_history.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_stream_chunk.dart';
import '../../domain/entities/conversation.dart';
import '../widgets/assistant_text.dart';
import 'chat_state.dart';
import 'providers.dart';

/// Chat notifier to manage chat state
class ChatNotifier extends Notifier<ChatState> {
  StreamSubscription<ChatStreamChunk>? _streamSub;

  @override
  ChatState build() {
    ref.onDispose(() {
      _streamSub?.cancel();
    });
    return ChatState(chatHistory: ChatHistory());
  }

  Future<void> loadConversationHistory(
    String conversationId,
    String userId,
  ) async {
    if (conversationId.isEmpty) return;

    state = state.copyWith(
      isLoadingHistory: true,
      conversationId: conversationId,
      chatHistory: ChatHistory(),
      errorMessage: null,
      errorType: null,
      errorParams: null,
    );

    try {
      final messages = await ref.read(loadConversationHistoryUseCaseProvider)(
        conversationId: conversationId,
        userId: userId,
      );

      final chatHistory = ChatHistory();
      for (final message in messages) {
        chatHistory.addMessage(message);
      }

      state = state.copyWith(
        chatHistory: chatHistory,
        isLoadingHistory: false,
        conversationId: conversationId,
      );
    } catch (e) {
      final errorInfo = _parseErrorMessage(e.toString());
      state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: e.toString(),
        errorType: errorInfo.type,
        errorParams: errorInfo.params,
      );
    }
  }

  Future<void> sendMessage(
    String message,
    String userID, {
    String? conversationId,
    List<ChatFileAttachment> files = const [],
  }) async {
    if (message == 'clear_history') {
      clearChat();
      return;
    }

    if (message == 'new_conversation_with_animation') {
      clearChat();
      Future.delayed(const Duration(seconds: 1), () {
        if (!ref.mounted) return;
        final initialMessage =
            SdkConfig.instance.initialMessage ??
            'Hello! How can I help you today?';
        final chatHistory = ChatHistory();
        chatHistory.addMessage(ChatMessage.assistant(content: initialMessage));
        state = ChatState(chatHistory: chatHistory, isFirstDisplay: false);
      });
      return;
    }

    if (files.isEmpty &&
        conversationId == null &&
        message.trim().isEmpty &&
        state.conversationId != null) {
      state = ChatState(chatHistory: ChatHistory());
      return;
    }

    if (files.isEmpty &&
        message.trim().isEmpty &&
        conversationId == null &&
        state.conversationId == null) {
      return;
    }

    if (files.isEmpty && message.trim().isEmpty && conversationId != null) {
      await loadConversationHistory(conversationId, userID);
      return;
    }

    final currentConversationId = conversationId ?? state.conversationId;
    final userMessage = ChatMessage.user(content: message, attachments: files);
    state.chatHistory.addMessage(userMessage);

    final assistantMessage = ChatMessage.assistant(
      content: '',
      status: MessageStatus.sending,
    );
    state.chatHistory.addMessage(assistantMessage);

    state = state.copyWith(
      chatHistory: state.chatHistory,
      isLoading: true,
      errorMessage: null,
      errorType: null,
      errorParams: null,
      conversationId: currentConversationId,
    );

    await _streamSub?.cancel();

    try {
      _streamSub = ref
          .read(streamChatMessageUseCaseProvider)(
            query: message,
            userId: userID,
            conversationId: currentConversationId,
            files: files,
          )
          .listen(
            (chunk) {
              final messages = List<ChatMessage>.from(
                state.chatHistory.messages,
              );
              if (messages.isNotEmpty &&
                  messages.last.role == MessageRole.assistant) {
                messages.last = messages.last.copyWith(
                  content: chunk.message.content,
                  status: chunk.message.status,
                );
              } else {
                messages.add(chunk.message);
              }

              state = state.copyWith(
                chatHistory: state.chatHistory.copyWith(messages: messages),
                isLoading:
                    chunk.message.status == MessageStatus.streaming ||
                    chunk.message.status == MessageStatus.sending,
                conversationId: chunk.conversationId ?? state.conversationId,
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
              if (state.errorType != null || state.errorMessage != null) {
                return;
              }
              final messages = List<ChatMessage>.from(
                state.chatHistory.messages,
              );
              if (messages.isNotEmpty &&
                  messages.last.role == MessageRole.assistant) {
                final last = messages.last;
                if (last.status == MessageStatus.streaming ||
                    last.status == MessageStatus.sending) {
                  final visible = visibleAssistantContent(
                    last.content,
                    streaming: false,
                  );
                  final empty = visible.isEmpty;
                  messages.last = last.copyWith(
                    status: empty ? MessageStatus.error : MessageStatus.sent,
                  );
                  state = state.copyWith(
                    chatHistory: state.chatHistory.copyWith(messages: messages),
                    isLoading: false,
                    errorMessage: empty ? 'EMPTY_ASSISTANT_REPLY' : null,
                    errorType: empty ? ChatErrorType.emptyAssistantReply : null,
                  );
                  return;
                }
              }
              state = state.copyWith(isLoading: false);
            },
          );
    } catch (e) {
      final errorInfo = _parseErrorMessage(e.toString());
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        errorType: errorInfo.type,
        errorParams: errorInfo.params,
      );

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

  Future<List<Conversation>> loadConversations(String userId) {
    return ref.read(listConversationsUseCaseProvider)(userId);
  }

  Future<void> deleteConversation(String userId, String conversationId) {
    return ref.read(deleteConversationUseCaseProvider)(
      userId: userId,
      conversationId: conversationId,
    );
  }

  void setConversationId(String? conversationId) {
    state = state.copyWith(conversationId: conversationId);
  }

  void clearChat() {
    state = ChatState(chatHistory: ChatHistory(), isFirstDisplay: true);
  }

  void setInitialState(ChatState newState) {
    state = newState;
  }

  void setAnimationCompleted() {
    state = state.copyWith(isFirstDisplay: false);
  }

  ErrorInfo _parseErrorMessage(String errorMsg) {
    if (errorMsg.contains('CONNECTION_TIMEOUT')) {
      return const ErrorInfo(type: ChatErrorType.connectionTimeout);
    } else if (errorMsg.contains('RECEIVE_TIMEOUT')) {
      return const ErrorInfo(type: ChatErrorType.receiveTimeout);
    } else if (errorMsg.contains('SEND_TIMEOUT')) {
      return const ErrorInfo(type: ChatErrorType.sendTimeout);
    } else if (errorMsg.contains('CONNECTION_ERROR')) {
      return const ErrorInfo(type: ChatErrorType.connectionError);
    } else if (errorMsg.contains('REQUEST_CANCELLED')) {
      return const ErrorInfo(type: ChatErrorType.requestCancelled);
    } else if (errorMsg.contains('SERVER_ERROR')) {
      final parts = errorMsg.split(':');
      if (parts.length >= 3) {
        return ErrorInfo(
          type: ChatErrorType.serverError,
          params: {
            'statusCode': parts[1],
            'message': parts.sublist(2).join(':'),
          },
        );
      }
      return ErrorInfo(
        type: ChatErrorType.serverError,
        params: {'statusCode': '?', 'message': errorMsg},
      );
    } else if (errorMsg.contains('NETWORK_ERROR')) {
      final message = errorMsg.replaceFirst('NETWORK_ERROR:', '');
      return ErrorInfo(
        type: ChatErrorType.network,
        params: {'message': message},
      );
    }
    return const ErrorInfo(type: ChatErrorType.generic);
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
