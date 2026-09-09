import 'chat_message.dart';

/// One SSE update from POST /chat-messages in streaming mode.
class ChatStreamChunk {
  final ChatMessage message;
  final String? conversationId;

  const ChatStreamChunk({required this.message, this.conversationId});
}
