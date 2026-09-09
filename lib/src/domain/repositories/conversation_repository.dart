import '../entities/conversation.dart';

/// Local conversation list persistence.
abstract class ConversationRepository {
  Future<void> save({
    required String userId,
    required String conversationId,
    String? name,
  });

  Future<List<Conversation>> list(String userId);

  Future<void> delete({
    required String userId,
    required String conversationId,
  });
}
