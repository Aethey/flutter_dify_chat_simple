import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dify_api_client.dart';
import '../../data/datasources/conversation_local_datasource.dart';
import '../../data/datasources/dify_remote_datasource.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../data/repositories/file_repository_impl.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../../domain/repositories/file_repository.dart';
import '../../domain/usecases/delete_conversation.dart';
import '../../domain/usecases/list_conversations.dart';
import '../../domain/usecases/load_conversation_history.dart';
import '../../domain/usecases/stream_chat_message.dart';
import '../../domain/usecases/transcribe_audio.dart';
import '../../domain/usecases/upload_chat_file.dart';

final difyApiClientProvider = Provider<DifyApiClient>((ref) {
  return DifyApiClient();
});

final difyRemoteDataSourceProvider = Provider<DifyRemoteDataSource>((ref) {
  return DifyRemoteDataSource(ref.watch(difyApiClientProvider));
});

final conversationLocalDataSourceProvider =
    Provider<ConversationLocalDataSource>((ref) {
      return ConversationLocalDataSource();
    });

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(difyRemoteDataSourceProvider));
});

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  return ConversationRepositoryImpl(
    ref.watch(conversationLocalDataSourceProvider),
  );
});

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  return FileRepositoryImpl(ref.watch(difyRemoteDataSourceProvider));
});

final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  return AudioRepositoryImpl(ref.watch(difyRemoteDataSourceProvider));
});

final streamChatMessageUseCaseProvider = Provider<StreamChatMessage>((ref) {
  return StreamChatMessage(
    ref.watch(chatRepositoryProvider),
    ref.watch(conversationRepositoryProvider),
  );
});

final loadConversationHistoryUseCaseProvider =
    Provider<LoadConversationHistory>((ref) {
      return LoadConversationHistory(ref.watch(chatRepositoryProvider));
    });

final listConversationsUseCaseProvider = Provider<ListConversations>((ref) {
  return ListConversations(ref.watch(conversationRepositoryProvider));
});

final deleteConversationUseCaseProvider = Provider<DeleteConversation>((ref) {
  return DeleteConversation(ref.watch(conversationRepositoryProvider));
});

final uploadChatFileUseCaseProvider = Provider<UploadChatFile>((ref) {
  return UploadChatFile(ref.watch(fileRepositoryProvider));
});

final transcribeAudioUseCaseProvider = Provider<TranscribeAudio>((ref) {
  return TranscribeAudio(ref.watch(audioRepositoryProvider));
});
