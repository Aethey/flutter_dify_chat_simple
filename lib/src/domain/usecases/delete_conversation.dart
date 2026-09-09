import '../repositories/conversation_repository.dart';

/// Deletes a locally stored conversation.
class DeleteConversation {
  DeleteConversation(this._conversationRepository);

  final ConversationRepository _conversationRepository;

  Future<void> call({
    required String userId,
    required String conversationId,
  }) {
    return _conversationRepository.delete(
      userId: userId,
      conversationId: conversationId,
    );
  }
}
