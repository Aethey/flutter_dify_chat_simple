import 'dart:async';

import 'package:chat_bot_sdk/src/core/error/app_exception.dart';
import 'package:chat_bot_sdk/src/domain/entities/chat_file_attachment.dart';
import 'package:chat_bot_sdk/src/domain/entities/chat_history.dart';
import 'package:chat_bot_sdk/src/domain/entities/chat_message.dart';
import 'package:chat_bot_sdk/src/domain/entities/chat_stream_chunk.dart';
import 'package:chat_bot_sdk/src/domain/entities/conversation.dart';
import 'package:chat_bot_sdk/src/domain/repositories/chat_repository.dart';
import 'package:chat_bot_sdk/src/domain/repositories/conversation_repository.dart';
import 'package:chat_bot_sdk/src/domain/usecases/stream_chat_message.dart';
import 'package:chat_bot_sdk/src/presentation/state/chat_notifier.dart';
import 'package:chat_bot_sdk/src/presentation/state/chat_state.dart';
import 'package:chat_bot_sdk/src/presentation/state/providers.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeChatRepository implements ChatRepository {
  List<ChatMessage> history = const [];
  Object? historyError;
  List<ChatStreamChunk> chunks = const [];
  Object? streamError;
  Stream<ChatStreamChunk>? stream;

  @override
  Future<List<ChatMessage>> fetchHistory({
    required String conversationId,
    required String userId,
  }) async {
    if (historyError != null) throw historyError!;
    return history;
  }

  @override
  Stream<ChatStreamChunk> streamMessage({
    required String query,
    required String userId,
    String? conversationId,
    List<ChatFileAttachment> files = const [],
  }) {
    if (stream != null) return stream!;
    if (streamError != null) return Stream.error(streamError!);
    return Stream.fromIterable(chunks);
  }
}

class _FakeConversationRepository implements ConversationRepository {
  final deleted = <String>[];
  List<Conversation> items = const [];

  @override
  Future<void> save({
    required String userId,
    required String conversationId,
    String? name,
  }) async {}

  @override
  Future<List<Conversation>> list(String userId) async => items;

  @override
  Future<void> delete({
    required String userId,
    required String conversationId,
  }) async {
    deleted.add(conversationId);
  }
}

class _ThrowingStreamChatMessage extends StreamChatMessage {
  _ThrowingStreamChatMessage()
    : super(_FakeChatRepository(), _FakeConversationRepository());

  @override
  Stream<ChatStreamChunk> call({
    required String query,
    required String userId,
    String? conversationId,
    List<ChatFileAttachment> files = const [],
  }) {
    throw const AppException(code: 'NETWORK_ERROR', message: 'down');
  }
}

({
  ProviderContainer container,
  _FakeChatRepository chat,
  _FakeConversationRepository conversations,
})
_createContainer({StreamChatMessage? streamChatMessage}) {
  final chat = _FakeChatRepository();
  final conversations = _FakeConversationRepository();
  final container = ProviderContainer(
    overrides: [
      chatRepositoryProvider.overrideWithValue(chat),
      conversationRepositoryProvider.overrideWithValue(conversations),
      if (streamChatMessage != null)
        streamChatMessageUseCaseProvider.overrideWithValue(streamChatMessage),
    ],
  );
  addTearDown(container.dispose);
  return (container: container, chat: chat, conversations: conversations);
}

void main() {
  test('loadConversationHistory ignores an empty conversation id', () async {
    final env = _createContainer();
    final notifier = env.container.read(chatProvider.notifier);

    await notifier.loadConversationHistory('', 'user-1');

    final state = env.container.read(chatProvider);
    expect(state.isLoadingHistory, isFalse);
    expect(state.chatHistory.messages, isEmpty);
  });

  test('loadConversationHistory fills messages and clears loading', () async {
    final env = _createContainer();
    env.chat.history = [
      ChatMessage.user(content: 'Hi'),
      ChatMessage.assistant(content: 'Hello'),
    ];
    final notifier = env.container.read(chatProvider.notifier);

    await notifier.loadConversationHistory('c1', 'user-1');

    final state = env.container.read(chatProvider);
    expect(state.isLoadingHistory, isFalse);
    expect(state.conversationId, 'c1');
    expect(state.chatHistory.messages.map((m) => m.content), ['Hi', 'Hello']);
  });

  test('loadConversationHistory maps CONNECTION_TIMEOUT', () async {
    final env = _createContainer();
    env.chat.historyError = const AppException(code: 'CONNECTION_TIMEOUT');
    final notifier = env.container.read(chatProvider.notifier);

    await notifier.loadConversationHistory('c1', 'user-1');

    final state = env.container.read(chatProvider);
    expect(state.isLoadingHistory, isFalse);
    expect(state.errorType, ChatErrorType.connectionTimeout);
  });

  test('clearChat resets the session', () async {
    final env = _createContainer();
    final notifier = env.container.read(chatProvider.notifier);
    notifier.setInitialState(
      ChatState(
        chatHistory: ChatHistory(messages: [ChatMessage.user(content: 'old')]),
        isFirstDisplay: false,
        conversationId: 'c1',
      ),
    );

    notifier.clearChat();

    final state = env.container.read(chatProvider);
    expect(state.chatHistory.messages, isEmpty);
    expect(state.isFirstDisplay, isTrue);
    expect(state.conversationId, isNull);
  });

  test('sendMessage empty text is a no-op without a conversation', () async {
    final env = _createContainer();
    final notifier = env.container.read(chatProvider.notifier);

    await notifier.sendMessage('   ', 'user-1');

    expect(env.container.read(chatProvider).chatHistory.messages, isEmpty);
  });

  test('sendMessage streams assistant text and conversation id', () async {
    final env = _createContainer();
    env.chat.chunks = [
      ChatStreamChunk(
        message: ChatMessage.assistant(
          content: 'Hel',
          status: MessageStatus.streaming,
        ),
        conversationId: 'c1',
      ),
      ChatStreamChunk(
        message: ChatMessage.assistant(
          content: 'Hello',
          status: MessageStatus.sent,
        ),
        conversationId: 'c1',
      ),
    ];
    final notifier = env.container.read(chatProvider.notifier);

    await notifier.sendMessage('Hi', 'user-1');
    await pumpEventQueue();

    final state = env.container.read(chatProvider);
    expect(state.isLoading, isFalse);
    expect(state.conversationId, 'c1');
    expect(state.chatHistory.messages.length, 2);
    expect(state.chatHistory.messages.first.content, 'Hi');
    expect(state.chatHistory.messages.last.content, 'Hello');
    expect(state.chatHistory.messages.last.status, MessageStatus.sent);
  });

  test('sendMessage marks an empty streamed reply as an error', () async {
    final env = _createContainer();
    env.chat.chunks = [
      ChatStreamChunk(
        message: ChatMessage.assistant(
          content: '<think>hidden</think>',
          status: MessageStatus.streaming,
        ),
      ),
    ];
    final notifier = env.container.read(chatProvider.notifier);

    await notifier.sendMessage('Hi', 'user-1');
    await pumpEventQueue();

    final state = env.container.read(chatProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorType, ChatErrorType.emptyAssistantReply);
    expect(state.chatHistory.messages.last.status, MessageStatus.error);
  });

  test('sendMessage maps stream errors', () async {
    final env = _createContainer();
    env.chat.streamError = const AppException(code: 'RECEIVE_TIMEOUT');
    final notifier = env.container.read(chatProvider.notifier);

    await notifier.sendMessage('Hi', 'user-1');
    await pumpEventQueue();

    final state = env.container.read(chatProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorType, ChatErrorType.receiveTimeout);
  });

  test('sendMessage catch path maps NETWORK_ERROR', () async {
    final env = _createContainer(
      streamChatMessage: _ThrowingStreamChatMessage(),
    );
    final notifier = env.container.read(chatProvider.notifier);

    await notifier.sendMessage('Hi', 'user-1');

    final state = env.container.read(chatProvider);
    expect(state.isLoading, isFalse);
    expect(state.errorType, ChatErrorType.network);
    expect(state.errorParams?['message'], 'down');
    expect(state.chatHistory.messages.last.content, contains('Failed'));
    expect(state.chatHistory.messages.last.status, MessageStatus.error);
  });

  test('sendMessage parses SERVER_ERROR details', () async {
    final env = _createContainer();
    env.chat.streamError = const AppException(
      code: 'SERVER_ERROR',
      statusCode: 500,
      message: 'boom',
    );
    final notifier = env.container.read(chatProvider.notifier);

    await notifier.sendMessage('Hi', 'user-1');
    await pumpEventQueue();

    final state = env.container.read(chatProvider);
    expect(state.errorType, ChatErrorType.serverError);
    expect(state.errorParams?['statusCode'], '500');
    expect(state.errorParams?['message'], 'boom');
  });

  test('sendMessage maps remaining error codes', () async {
    Future<ChatErrorType> typeFor(Object error) async {
      final env = _createContainer();
      env.chat.streamError = error;
      final notifier = env.container.read(chatProvider.notifier);
      await notifier.sendMessage('Hi', 'user-1');
      await pumpEventQueue();
      return env.container.read(chatProvider).errorType!;
    }

    expect(
      await typeFor(const AppException(code: 'SEND_TIMEOUT')),
      ChatErrorType.sendTimeout,
    );
    expect(
      await typeFor(const AppException(code: 'CONNECTION_ERROR')),
      ChatErrorType.connectionError,
    );
    expect(
      await typeFor(const AppException(code: 'REQUEST_CANCELLED')),
      ChatErrorType.requestCancelled,
    );
    expect(await typeFor(Exception('nope')), ChatErrorType.generic);
  });

  test('sendMessage maps unknown Dify codes to the api error type', () async {
    final env = _createContainer();
    env.chat.streamError = const AppException(
      code: 'provider_quota_exceeded',
      message: 'quota exceeded',
    );
    final notifier = env.container.read(chatProvider.notifier);

    await notifier.sendMessage('Hi', 'user-1');
    await pumpEventQueue();

    final state = env.container.read(chatProvider);
    expect(state.errorType, ChatErrorType.api);
    expect(state.errorParams?['code'], 'provider_quota_exceeded');
    expect(state.errorParams?['message'], 'quota exceeded');
  });

  test('startNewConversation restores the welcome message', () {
    fakeAsync((async) {
      final env = _createContainer();
      final notifier = env.container.read(chatProvider.notifier);
      notifier.startNewConversation('Welcome back');
      expect(env.container.read(chatProvider).chatHistory.messages, isEmpty);

      async.elapse(const Duration(seconds: 1));
      final state = env.container.read(chatProvider);
      expect(state.isFirstDisplay, isFalse);
      expect(state.chatHistory.messages.single.content, 'Welcome back');
    });
  });

  test('conversation helpers and local setters', () async {
    final env = _createContainer();
    env.conversations.items = const [
      Conversation(id: 'c1', name: 'A', createdAt: 1, updatedAt: 2),
    ];
    final notifier = env.container.read(chatProvider.notifier);

    final listed = await notifier.loadConversations('user-1');
    expect(listed.single.id, 'c1');

    await notifier.deleteConversation('user-1', 'c1');
    expect(env.conversations.deleted, ['c1']);

    notifier.setConversationId('c2');
    notifier.setAnimationCompleted();
    expect(env.container.read(chatProvider).conversationId, 'c2');
    expect(env.container.read(chatProvider).isFirstDisplay, isFalse);
  });
}
