import 'dart:async';

import '../entities/chat_file_attachment.dart';
import '../entities/chat_stream_chunk.dart';
import '../repositories/chat_repository.dart';
import '../repositories/conversation_repository.dart';

/// Streams a chat reply and persists the conversation id locally.
class StreamChatMessage {
  StreamChatMessage(this._chatRepository, this._conversationRepository);

  final ChatRepository _chatRepository;
  final ConversationRepository _conversationRepository;

  Stream<ChatStreamChunk> call({
    required String query,
    required String userId,
    String? conversationId,
    List<ChatFileAttachment> files = const [],
  }) async* {
    String? savedId;
    await for (final chunk in _chatRepository.streamMessage(
      query: query,
      userId: userId,
      conversationId: conversationId,
      files: files,
    )) {
      yield chunk;
      final id = chunk.conversationId;
      if (id == null || id.isEmpty || id == savedId) continue;
      savedId = id;
      // Do not await: pausing this stream pauses Dio's SSE download.
      unawaited(
        _conversationRepository.save(
          userId: userId,
          conversationId: id,
        ),
      );
    }
  }
}
