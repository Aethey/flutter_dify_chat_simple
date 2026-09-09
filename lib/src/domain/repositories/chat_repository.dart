import '../entities/chat_file_attachment.dart';
import '../entities/chat_message.dart';
import '../entities/chat_stream_chunk.dart';

/// Chat conversation operations against Dify.
abstract class ChatRepository {
  Stream<ChatStreamChunk> streamMessage({
    required String query,
    required String userId,
    String? conversationId,
    List<ChatFileAttachment> files,
  });

  Future<List<ChatMessage>> fetchHistory({
    required String conversationId,
    required String userId,
  });
}
