import '../../domain/entities/chat_file_attachment.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_stream_chunk.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/dify_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remoteDataSource);

  final DifyRemoteDataSource _remoteDataSource;

  @override
  Stream<ChatStreamChunk> streamMessage({
    required String query,
    required String userId,
    String? conversationId,
    List<ChatFileAttachment> files = const [],
  }) {
    return _remoteDataSource.streamChatMessage(
      query: query,
      userId: userId,
      conversationId: conversationId,
      files: files,
    );
  }

  @override
  Future<List<ChatMessage>> fetchHistory({
    required String conversationId,
    required String userId,
  }) {
    return _remoteDataSource.fetchConversationHistory(
      conversationId: conversationId,
      userId: userId,
    );
  }
}
