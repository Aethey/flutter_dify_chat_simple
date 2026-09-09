import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_local_datasource.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  ConversationRepositoryImpl(this._localDataSource);

  final ConversationLocalDataSource _localDataSource;

  @override
  Future<void> save({
    required String userId,
    required String conversationId,
    String? name,
  }) {
    return _localDataSource.save(
      userId: userId,
      conversationId: conversationId,
      name: name,
    );
  }

  @override
  Future<List<Conversation>> list(String userId) {
    return _localDataSource.list(userId);
  }

  @override
  Future<void> delete({
    required String userId,
    required String conversationId,
  }) {
    return _localDataSource.delete(
      userId: userId,
      conversationId: conversationId,
    );
  }
}
