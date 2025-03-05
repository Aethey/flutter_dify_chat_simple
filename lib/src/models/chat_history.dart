import 'package:uuid/uuid.dart';
import 'message.dart';

/// Represents a complete chat session with multiple messages
class ChatHistory {
  /// Unique identifier for the conversation
  final String id;
  
  /// List of messages in the conversation
  final List<ChatMessage> messages;
  
  /// Timestamp when the conversation was created
  final DateTime createdAt;
  
  /// Latest update timestamp
  DateTime updatedAt;
  
  /// Constructor
  ChatHistory({
    String? id,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? const Uuid().v4(),
    messages = messages ?? [],
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
  
  /// Add a new message to the conversation
  void addMessage(ChatMessage message) {
    messages.add(message);
    updatedAt = DateTime.now();
  }
  
  /// Get the most recent message in the conversation
  ChatMessage? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }
  
  /// Get the most recent user message
  ChatMessage? get lastUserMessage {
    final userMessages = messages.where(
      (msg) => msg.role == MessageRole.user
    ).toList();
    
    if (userMessages.isEmpty) return null;
    return userMessages.last;
  }
  
  /// Get the most recent assistant message
  ChatMessage? get lastAssistantMessage {
    final assistantMessages = messages.where(
      (msg) => msg.role == MessageRole.assistant
    ).toList();
    
    if (assistantMessages.isEmpty) return null;
    return assistantMessages.last;
  }
  
  /// Convert to a format suitable for API requests
  List<Map<String, dynamic>> toApiMessages() {
    return messages.map((msg) => {
      'role': msg.role.toString().split('.').last,
      'content': msg.content,
    }).toList();
  }
  
  /// Create a copy of this history with updated fields
  ChatHistory copyWith({
    List<ChatMessage>? messages,
  }) {
    return ChatHistory(
      id: id,
      messages: messages ?? List.from(this.messages),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 