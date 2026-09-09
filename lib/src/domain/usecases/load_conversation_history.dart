import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

/// Loads an existing Dify conversation.
class LoadConversationHistory {
  LoadConversationHistory(this._chatRepository);

  final ChatRepository _chatRepository;

  Future<List<ChatMessage>> call({
    required String conversationId,
    required String userId,
  }) {
    return _chatRepository.fetchHistory(
      conversationId: conversationId,
      userId: userId,
    );
  }
}
