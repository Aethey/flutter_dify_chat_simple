import '../entities/conversation.dart';
import '../repositories/conversation_repository.dart';

/// Lists locally stored conversations for a user.
class ListConversations {
  ListConversations(this._conversationRepository);

  final ConversationRepository _conversationRepository;

  Future<List<Conversation>> call(String userId) {
    return _conversationRepository.list(userId);
  }
}
