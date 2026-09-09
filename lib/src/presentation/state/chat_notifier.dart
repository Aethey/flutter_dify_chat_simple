import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
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

      state = state.copyWith(
        chatHistory: ChatHistory(messages: messages),
        isLoadingHistory: false,
        conversationId: conversationId,
      );
    } catch (e) {
      final info = _errorInfo(e);
      state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: _errorMessage(e, info),
        errorType: info.type,
        errorParams: info.params,
      );
    }
  }

  /// Starts a brand-new conversation and restores the welcome message.
  void startNewConversation(String initialMessage) {
    clearChat();
    Future.delayed(const Duration(seconds: 1), () {
      if (!ref.mounted) return;
      state = ChatState(
        chatHistory: ChatHistory(
          messages: [ChatMessage.assistant(content: initialMessage)],
        ),
        isFirstDisplay: false,
      );
    });
  }

  Future<void> sendMessage(
    String message,
    String userID, {
    String? conversationId,
    List<ChatFileAttachment> files = const [],
  }) async {
    if (files.isEmpty && message.trim().isEmpty) return;

    final currentConversationId = conversationId ?? state.conversationId;
    final userMessage = ChatMessage.user(content: message, attachments: files);
    final assistantMessage = ChatMessage.assistant(
      content: '',
      status: MessageStatus.sending,
    );

    state = state.copyWith(
      chatHistory: state.chatHistory.copyWith(
        messages: [
          ...state.chatHistory.messages,
          userMessage,
          assistantMessage,
        ],
      ),
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
            _applyChunk,
            onError: _onStreamError,
            onDone: _onStreamDone,
          );
    } catch (e) {
      _onStreamError(e);
      _markLastAssistantFailed();
    }
  }

  /// Applies one streamed chunk to the trailing assistant message.
  void _applyChunk(ChatStreamChunk chunk) {
    final messages = state.chatHistory.messages;
    final bool isAssistantTrailing =
        messages.isNotEmpty && messages.last.role == MessageRole.assistant;

    final updated = isAssistantTrailing
        ? [
            ...messages.sublist(0, messages.length - 1),
            messages.last.copyWith(
              content: chunk.message.content,
              status: chunk.message.status,
            ),
          ]
        : [...messages, chunk.message];

    state = state.copyWith(
      chatHistory: state.chatHistory.copyWith(messages: updated),
      isLoading:
          chunk.message.status == MessageStatus.streaming ||
          chunk.message.status == MessageStatus.sending,
      conversationId: chunk.conversationId ?? state.conversationId,
    );
  }

  void _onStreamError(Object error) {
    final info = _errorInfo(error);
    state = state.copyWith(
      isLoading: false,
      errorMessage: _errorMessage(error, info),
      errorType: info.type,
      errorParams: info.params,
    );
  }

  void _onStreamDone() {
    if (state.errorType != null || state.errorMessage != null) {
      return;
    }
    final messages = state.chatHistory.messages;
    if (messages.isNotEmpty && messages.last.role == MessageRole.assistant) {
      final last = messages.last;
      if (last.status == MessageStatus.streaming ||
          last.status == MessageStatus.sending) {
        final visible = visibleAssistantContent(last.content, streaming: false);
        final empty = visible.isEmpty;
        state = state.copyWith(
          chatHistory: state.chatHistory.copyWith(
            messages: [
              ...messages.sublist(0, messages.length - 1),
              last.copyWith(
                status: empty ? MessageStatus.error : MessageStatus.sent,
              ),
            ],
          ),
          isLoading: false,
          errorMessage: empty ? 'EMPTY_ASSISTANT_REPLY' : null,
          errorType: empty ? ChatErrorType.emptyAssistantReply : null,
        );
        return;
      }
    }
    state = state.copyWith(isLoading: false);
  }

  void _markLastAssistantFailed() {
    final messages = state.chatHistory.messages;
    if (messages.isEmpty || messages.last.role != MessageRole.assistant) {
      return;
    }
    state = state.copyWith(
      chatHistory: state.chatHistory.copyWith(
        messages: [
          ...messages.sublist(0, messages.length - 1),
          ChatMessage.assistant(
            content: 'Error: Failed to get response',
            status: MessageStatus.error,
          ),
        ],
      ),
    );
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

  ErrorInfo _errorInfo(Object error) {
    if (error is AppException) {
      switch (error.code) {
        case 'CONNECTION_TIMEOUT':
          return const ErrorInfo(type: ChatErrorType.connectionTimeout);
        case 'RECEIVE_TIMEOUT':
          return const ErrorInfo(type: ChatErrorType.receiveTimeout);
        case 'SEND_TIMEOUT':
          return const ErrorInfo(type: ChatErrorType.sendTimeout);
        case 'CONNECTION_ERROR':
          return const ErrorInfo(type: ChatErrorType.connectionError);
        case 'REQUEST_CANCELLED':
          return const ErrorInfo(type: ChatErrorType.requestCancelled);
        case 'SERVER_ERROR':
          return ErrorInfo(
            type: ChatErrorType.serverError,
            params: {
              'statusCode': '${error.statusCode ?? '?'}',
              'message': error.message ?? '',
            },
          );
        case 'NETWORK_ERROR':
          return ErrorInfo(
            type: ChatErrorType.network,
            params: {'message': error.message ?? ''},
          );
        default:
          return ErrorInfo(
            type: ChatErrorType.api,
            params: {'code': error.code, 'message': error.message ?? ''},
          );
      }
    }
    return const ErrorInfo(type: ChatErrorType.generic);
  }

  String _errorMessage(Object error, ErrorInfo info) {
    if (error is AppException) {
      final message = error.message;
      if (message != null && message.isNotEmpty) return message;
      return error.code;
    }
    return error.toString();
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
